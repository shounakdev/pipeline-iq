#!/usr/bin/env bash
set -euo pipefail

readonly INSTALL_NAMESPACE="chaos-mesh"
readonly SERVICE_ACCOUNT="system:serviceaccount:chaos-mesh:platformiq-chaos-runner"
: "${KUBE_CONTEXT:?Set KUBE_CONTEXT to the exact development or staging kubectl context}"
: "${CHAOS_TARGET_ENVIRONMENT:?Set CHAOS_TARGET_ENVIRONMENT to development or staging}"

case "${CHAOS_TARGET_ENVIRONMENT}" in
  development)
    readonly TARGET_NAMESPACE="platformiq-dev"
    readonly OTHER_NAMESPACE="platformiq-staging"
    ;;
  staging)
    readonly TARGET_NAMESPACE="platformiq-staging"
    readonly OTHER_NAMESPACE="platformiq-dev"
    ;;
  *)
    echo "Invalid CHAOS_TARGET_ENVIRONMENT." >&2
    exit 1
    ;;
esac

k() {
  kubectl --context "${KUBE_CONTEXT}" "$@"
}

echo "Waiting for Chaos Mesh controller, daemon, and dashboard..."
k -n "${INSTALL_NAMESPACE}" rollout status deployment/chaos-controller-manager --timeout=5m
k -n "${INSTALL_NAMESPACE}" rollout status daemonset/chaos-daemon --timeout=5m
k -n "${INSTALL_NAMESPACE}" rollout status deployment/chaos-dashboard --timeout=5m

echo "Checking dashboard Service and ready endpoints..."
k -n "${INSTALL_NAMESPACE}" get service chaos-dashboard
dashboard_type="$(k -n "${INSTALL_NAMESPACE}" get service chaos-dashboard -o jsonpath='{.spec.type}')"
[[ "${dashboard_type}" == "ClusterIP" ]] || {
  echo "Chaos Dashboard must be ClusterIP, found '${dashboard_type}'." >&2
  exit 1
}
ready_addresses="$(k -n "${INSTALL_NAMESPACE}" get endpoints chaos-dashboard -o jsonpath='{.subsets[*].addresses[*].ip}')"
if [[ -z "${ready_addresses}" ]]; then
  echo "Chaos Dashboard has no ready endpoints." >&2
  exit 1
fi

echo "Checking namespace injection boundary..."
target_injection="$(k get namespace "${TARGET_NAMESPACE}" -o jsonpath='{.metadata.annotations.chaos-mesh\.org/inject}')"
[[ "${target_injection}" == "enabled" ]] || {
  echo "Chaos injection is not enabled in ${TARGET_NAMESPACE}." >&2
  exit 1
}
other_injection="$(k get namespace "${OTHER_NAMESPACE}" -o jsonpath='{.metadata.annotations.chaos-mesh\.org/inject}' 2>/dev/null || true)"
[[ -z "${other_injection}" ]] || {
  echo "Chaos injection must be disabled in ${OTHER_NAMESPACE}." >&2
  exit 1
}

echo "Checking required CRDs..."
for crd in \
  podchaos.chaos-mesh.org \
  networkchaos.chaos-mesh.org \
  stresschaos.chaos-mesh.org \
  httpchaos.chaos-mesh.org \
  workflows.chaos-mesh.org; do
  k get crd "${crd}" >/dev/null
done

echo "Checking allowed permissions..."
for namespace in "${TARGET_NAMESPACE}"; do
  for resource in podchaos networkchaos stresschaos httpchaos workflows; do
    for verb in create get list watch delete; do
      answer="$(k auth can-i "${verb}" "${resource}.chaos-mesh.org" --namespace "${namespace}" --as "${SERVICE_ACCOUNT}")"
      [[ "${answer}" == "yes" ]] || {
        echo "Missing permission: ${verb} ${resource} in ${namespace}" >&2
        exit 1
      }
    done
  done
done

echo "Checking production and arbitrary namespaces are blocked..."
for namespace in platformiq-production platformiq-prod default "${OTHER_NAMESPACE}"; do
  answer="$(k auth can-i create podchaos.chaos-mesh.org --namespace "${namespace}" --as "${SERVICE_ACCOUNT}" || true)"
  [[ "${answer}" == "no" ]] || {
    echo "Unsafe permission: PlatformIQ can create PodChaos in ${namespace}" >&2
    exit 1
  }
done

echo "Checking restricted operations remain blocked..."
for namespace in "${TARGET_NAMESPACE}"; do
  for verb in update patch; do
    answer="$(k auth can-i "${verb}" podchaos.chaos-mesh.org --namespace "${namespace}" --as "${SERVICE_ACCOUNT}" || true)"
    [[ "${answer}" == "no" ]] || {
      echo "Unsafe permission: PlatformIQ can ${verb} PodChaos in ${namespace}" >&2
      exit 1
    }
  done
done

echo "Checking the service account with a short-lived TokenRequest credential..."
token="$(k -n "${INSTALL_NAMESPACE}" create token platformiq-chaos-runner --duration=10m)"

token_user="$(
  k create -f - -o jsonpath='{.status.user.username}' <<EOF
apiVersion: authentication.k8s.io/v1
kind: TokenReview
spec:
  token: "${token}"
EOF
)"

[[ "${token_user}" == "${SERVICE_ACCOUNT}" ]] || {
  echo "Token authenticated as '${token_user}', expected '${SERVICE_ACCOUNT}'." >&2
  exit 1
}

token_test_dir="$(mktemp -d)"
token_ca="${token_test_dir}/ca.crt"
token_kubeconfig="${token_test_dir}/kubeconfig"
cleanup_token_test() {
  rm -f "${token_ca}" "${token_kubeconfig}"
  rmdir "${token_test_dir}" 2>/dev/null || true
}
trap cleanup_token_test EXIT

api_server="$(kubectl config view --raw --minify --context="${KUBE_CONTEXT}" -o jsonpath='{.clusters[0].cluster.server}')"
kubectl config view --raw --minify --context="${KUBE_CONTEXT}" \
  -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' \
  | base64 --decode > "${token_ca}"
kubectl config --kubeconfig="${token_kubeconfig}" set-cluster token-test \
  --server="${api_server}" \
  --certificate-authority="${token_ca}" \
  --embed-certs=true >/dev/null
kubectl config --kubeconfig="${token_kubeconfig}" set-credentials platformiq-chaos-runner \
  --token="${token}" >/dev/null
kubectl config --kubeconfig="${token_kubeconfig}" set-context token-test \
  --cluster=token-test \
  --user=platformiq-chaos-runner \
  --namespace="${TARGET_NAMESPACE}" >/dev/null
kubectl config --kubeconfig="${token_kubeconfig}" use-context token-test >/dev/null

kubectl --kubeconfig="${token_kubeconfig}" \
  --namespace "${TARGET_NAMESPACE}" \
  get podchaos.chaos-mesh.org >/dev/null

if kubectl --kubeconfig="${token_kubeconfig}" \
  --namespace "${TARGET_NAMESPACE}" \
  get pods >/dev/null 2>&1; then
  echo "Unsafe permission: PlatformIQ service account can list Pods." >&2
  exit 1
fi

if kubectl --kubeconfig="${token_kubeconfig}" \
  --namespace "${OTHER_NAMESPACE}" \
  get podchaos.chaos-mesh.org >/dev/null 2>&1; then
  echo "Unsafe permission: PlatformIQ service account can list PodChaos in ${OTHER_NAMESPACE}." >&2
  exit 1
fi

echo "Chaos Mesh health, API discovery, and PlatformIQ RBAC checks passed."
