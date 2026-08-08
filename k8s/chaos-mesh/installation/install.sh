#!/usr/bin/env bash
set -euo pipefail

readonly CHART_VERSION="2.8.3"
readonly RELEASE_NAME="chaos-mesh"
readonly INSTALL_NAMESPACE="chaos-mesh"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly MANIFEST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

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
    echo "Refusing installation: CHAOS_TARGET_ENVIRONMENT must be development or staging." >&2
    exit 1
    ;;
esac

if ! kubectl config get-contexts "${KUBE_CONTEXT}" >/dev/null 2>&1; then
  echo "kubectl context does not exist: ${KUBE_CONTEXT}" >&2
  exit 1
fi

current_context="$(kubectl config current-context)"
if [[ "${current_context}" != "${KUBE_CONTEXT}" ]]; then
  echo "Refusing installation: current context '${current_context}' is not KUBE_CONTEXT '${KUBE_CONTEXT}'." >&2
  exit 1
fi

# A human must label kube-system once after verifying the cluster identity:
# kubectl label namespace kube-system platformiq.io/environment=development
cluster_environment="$(kubectl --context "${KUBE_CONTEXT}" get namespace kube-system -o jsonpath='{.metadata.labels.platformiq\.io/environment}')"
if [[ "${cluster_environment}" != "${CHAOS_TARGET_ENVIRONMENT}" ]]; then
  echo "Refusing installation: kube-system is labeled '${cluster_environment:-<unset>}', expected '${CHAOS_TARGET_ENVIRONMENT}'." >&2
  exit 1
fi

kubectl --context "${KUBE_CONTEXT}" apply -f "${MANIFEST_DIR}/namespace.yaml"
kubectl --context "${KUBE_CONTEXT}" get namespace "${TARGET_NAMESPACE}" >/dev/null
kubectl --context "${KUBE_CONTEXT}" label namespace "${TARGET_NAMESPACE}" \
  platformiq.io/environment="${CHAOS_TARGET_ENVIRONMENT}" --overwrite
kubectl --context "${KUBE_CONTEXT}" annotate namespace "${TARGET_NAMESPACE}" \
  chaos-mesh.org/inject=enabled --overwrite

# An install for one environment must not leave the other environment enabled.
kubectl --context "${KUBE_CONTEXT}" annotate namespace "${OTHER_NAMESPACE}" \
  chaos-mesh.org/inject- >/dev/null 2>&1 || true
kubectl --context "${KUBE_CONTEXT}" -n "${OTHER_NAMESPACE}" delete \
  rolebinding platformiq-chaos-runner --ignore-not-found
kubectl --context "${KUBE_CONTEXT}" -n "${OTHER_NAMESPACE}" delete \
  role platformiq-chaos-runner --ignore-not-found

helm repo add chaos-mesh https://charts.chaos-mesh.org --force-update
helm repo update chaos-mesh
helm upgrade --install "${RELEASE_NAME}" chaos-mesh/chaos-mesh \
  --kube-context "${KUBE_CONTEXT}" \
  --namespace "${INSTALL_NAMESPACE}" \
  --version "${CHART_VERSION}" \
  --values "${SCRIPT_DIR}/values.yaml" \
  --wait \
  --timeout 10m

kubectl --context "${KUBE_CONTEXT}" apply -f "${MANIFEST_DIR}/service-account.yaml"
kubectl --context "${KUBE_CONTEXT}" apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: platformiq-chaos-runner
  namespace: ${TARGET_NAMESPACE}
rules:
  - apiGroups: ["chaos-mesh.org"]
    resources: ["podchaos", "networkchaos", "stresschaos", "httpchaos", "workflows"]
    verbs: ["create", "get", "list", "watch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: platformiq-chaos-runner
  namespace: ${TARGET_NAMESPACE}
subjects:
  - kind: ServiceAccount
    name: platformiq-chaos-runner
    namespace: chaos-mesh
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: platformiq-chaos-runner
EOF

"${SCRIPT_DIR}/verify.sh"
