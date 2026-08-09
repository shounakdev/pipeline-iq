#!/usr/bin/env bash
set -euo pipefail

readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly KUBE_CONTEXT="kind-platformiq"
readonly TARGET_NAMESPACE="platformiq-staging"
readonly SERVICE_ACCOUNT="platformiq-chaos-runner"
readonly SERVICE_ACCOUNT_USER="system:serviceaccount:chaos-mesh:${SERVICE_ACCOUNT}"
readonly ACTIVE_CONFIG="${PROJECT_ROOT}/kubeconfig-docker.yaml"
readonly BACKUP_CONFIG="/tmp/kubeconfig-docker.pre-sprint10j.yaml"
readonly ENV_FILE="${PROJECT_ROOT}/.env"

cd "${PROJECT_ROOT}"

[[ "$(kubectl config current-context)" == "${KUBE_CONTEXT}" ]] || {
  echo "Refusing: current context is not ${KUBE_CONTEXT}." >&2
  exit 1
}

[[ "$(kubectl get namespace "${TARGET_NAMESPACE}" -o jsonpath='{.metadata.labels.platformiq\.io/environment}')" == "staging" ]] || {
  echo "Refusing: staging namespace environment label is missing." >&2
  exit 1
}

[[ "$(kubectl get namespace "${TARGET_NAMESPACE}" -o jsonpath='{.metadata.annotations.chaos-mesh\.org/inject}')" == "enabled" ]] || {
  echo "Refusing: Chaos Mesh injection is not enabled in staging." >&2
  exit 1
}

for namespace in platformiq-staging platformiq-dev platformiq-production; do
  permission="$(kubectl auth can-i create podchaos.chaos-mesh.org \
    --namespace "${namespace}" --as "${SERVICE_ACCOUNT_USER}" || true)"
  expected="no"
  [[ "${namespace}" != "platformiq-staging" ]] || expected="yes"
  [[ "${permission}" == "${expected}" ]] || {
    echo "Refusing: ${namespace} permission is ${permission}, expected ${expected}." >&2
    exit 1
  }
done

cp "${ACTIVE_CONFIG}" "${BACKUP_CONFIG}"
temporary_config="$(mktemp)"
temporary_ca="$(mktemp)"
cleanup_temporary_files() {
  rm -f "${temporary_config}" "${temporary_ca}"
}
trap cleanup_temporary_files EXIT

docker_api_server="$(kubectl --kubeconfig="${BACKUP_CONFIG}" config view \
  --raw -o jsonpath='{.clusters[0].cluster.server}')"
kubectl --kubeconfig="${BACKUP_CONFIG}" config view --raw \
  -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' \
  | base64 --decode > "${temporary_ca}"
chaos_token="$(kubectl -n chaos-mesh create token "${SERVICE_ACCOUNT}" \
  --duration=2h)"

kubectl --kubeconfig="${temporary_config}" config set-cluster platformiq \
  --server="${docker_api_server}" \
  --certificate-authority="${temporary_ca}" \
  --embed-certs=true >/dev/null
kubectl --kubeconfig="${temporary_config}" config set-credentials \
  "${SERVICE_ACCOUNT}" --token="${chaos_token}" >/dev/null
kubectl --kubeconfig="${temporary_config}" config set-context \
  platformiq-chaos-staging --cluster=platformiq \
  --user="${SERVICE_ACCOUNT}" --namespace="${TARGET_NAMESPACE}" >/dev/null
kubectl --kubeconfig="${temporary_config}" config use-context \
  platformiq-chaos-staging >/dev/null
unset chaos_token

chmod 600 "${temporary_config}"
cp "${temporary_config}" "${ACTIVE_CONFIG}"
sed -i 's/^CHAOS_ADAPTER=.*/CHAOS_ADAPTER=chaos-mesh/' "${ENV_FILE}"
docker compose up -d --force-recreate backend worker

if ! docker compose exec -T worker python - <<'PY'
from kubernetes import client, config
from kubernetes.config.config_exception import ConfigException

try:
    config.load_incluster_config()
except ConfigException:
    config.load_kube_config()

api = client.AuthorizationV1Api()
expected = {
    "platformiq-staging": True,
    "platformiq-dev": False,
    "platformiq-production": False,
}
for namespace, wanted in expected.items():
    review = client.V1SelfSubjectAccessReview(
        spec=client.V1SelfSubjectAccessReviewSpec(
            resource_attributes=client.V1ResourceAttributes(
                group="chaos-mesh.org",
                resource="podchaos",
                verb="create",
                namespace=namespace,
            )
        )
    )
    allowed = bool(api.create_self_subject_access_review(review).status.allowed)
    print(f"{namespace}: {allowed}")
    if allowed != wanted:
        raise SystemExit(1)
PY
then
  echo "Permission verification failed; restoring the safe configuration." >&2
  cp "${BACKUP_CONFIG}" "${ACTIVE_CONFIG}"
  sed -i 's/^CHAOS_ADAPTER=.*/CHAOS_ADAPTER=mock/' "${ENV_FILE}"
  docker compose up -d --force-recreate backend worker
  exit 1
fi

docker compose exec backend sh -lc 'env | grep "^CHAOS_ADAPTER="'
docker compose exec worker sh -lc 'env | grep "^CHAOS_ADAPTER="'
echo "Staging chaos identity is active for two hours. Do not commit kubeconfig-docker.yaml."
