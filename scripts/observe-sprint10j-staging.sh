#!/usr/bin/env bash
set -euo pipefail

readonly API_URL="${API_URL:-http://127.0.0.1:8000}"
readonly NAMESPACE="${NAMESPACE:-platformiq-staging}"
readonly SERVICE_NAME="${SERVICE_NAME:-payment-service}"
readonly SERVICE_ID="${SERVICE_ID:?Set SERVICE_ID to the PlatformIQ service UUID}"
readonly POLL_SECONDS="${POLL_SECONDS:-1}"

command -v kubectl >/dev/null || {
  echo "kubectl is required." >&2
  exit 1
}
command -v curl >/dev/null || {
  echo "curl is required." >&2
  exit 1
}

kubectl get namespace "${NAMESPACE}" >/dev/null
kubectl -n "${NAMESPACE}" get deployment "${SERVICE_NAME}" >/dev/null

echo "Observing ${NAMESPACE}/${SERVICE_NAME} for PlatformIQ service ${SERVICE_ID}."
echo "Press Ctrl+C after the experiment reaches a terminal state."

previous_state=""
while true; do
  desired="$(kubectl -n "${NAMESPACE}" get deployment "${SERVICE_NAME}" \
    -o jsonpath='{.spec.replicas}')"
  available="$(kubectl -n "${NAMESPACE}" get deployment "${SERVICE_NAME}" \
    -o jsonpath='{.status.availableReplicas}')"
  available="${available:-0}"
  restarts="$(kubectl -n "${NAMESPACE}" get pods \
    -l "app=${SERVICE_NAME}" \
    -o jsonpath='{range .items[*]}{range .status.containerStatuses[*]}{.restartCount}{"\n"}{end}{end}' \
    | awk '{total += $1} END {print total + 0}')"

  state="${desired}:${available}:${restarts}"
  if [[ "${state}" != "${previous_state}" ]]; then
    payload="$(printf '%s\n' \
      "{\"service_id\":\"${SERVICE_ID}\",\"service_name\":\"${SERVICE_NAME}\",\"environment\":\"staging\",\"pod_restart_count\":${restarts},\"replica_count\":${desired},\"available_replicas\":${available}}")"
    response="$(curl --fail --silent --show-error \
      -X POST "${API_URL}/api/observability/health-snapshots/manual" \
      -H 'Content-Type: application/json' \
      --data "${payload}")"
    echo "$(date --iso-8601=seconds) desired=${desired} available=${available} restarts=${restarts} ${response}"
    previous_state="${state}"
  fi
  sleep "${POLL_SECONDS}"
done