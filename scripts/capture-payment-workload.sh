#!/usr/bin/env bash
set -euo pipefail

API="${API:-http://127.0.0.1:8000}"
DEPLOYMENT_ID="${DEPLOYMENT_ID:?DEPLOYMENT_ID is required}"
WORKLOAD_NAME="${WORKLOAD_NAME:-payment-service}"
NAMESPACE="${NAMESPACE:-platformiq-demo}"

DESIRED=$(kubectl get deployment "$WORKLOAD_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.replicas}')
AVAILABLE=$(kubectl get deployment "$WORKLOAD_NAME" -n "$NAMESPACE" -o jsonpath='{.status.availableReplicas}')

if [ -z "$AVAILABLE" ]; then
  AVAILABLE=0
fi

POD_COUNT=$(kubectl get pods -n "$NAMESPACE" -l app="$WORKLOAD_NAME" --no-headers 2>/dev/null | wc -l)

RESTART_COUNT=$(kubectl get pods -n "$NAMESPACE" -l app="$WORKLOAD_NAME" \
  -o jsonpath='{range .items[*]}{range .status.containerStatuses[*]}{.restartCount}{"\n"}{end}{end}' \
  | awk '{sum += $1} END {print sum + 0}')

WAITING_REASONS=$(kubectl get pods -n "$NAMESPACE" -l app="$WORKLOAD_NAME" \
  -o jsonpath='{range .items[*]}{range .status.containerStatuses[*]}{.state.waiting.reason}{"\n"}{end}{end}' \
  2>/dev/null | grep -E 'ImagePullBackOff|ErrImagePull|InvalidImageName|CrashLoopBackOff|ErrImageNeverPull' || true)

if [ -n "$WAITING_REASONS" ]; then
  STATUS="FAILED"
  FAILURE_REASON=$(echo "$WAITING_REASONS" | head -n 1)
elif [ "$DESIRED" = "$AVAILABLE" ]; then
  STATUS="HEALTHY"
  FAILURE_REASON=""
else
  STATUS="DEGRADED"
  FAILURE_REASON="Available replicas do not match desired replicas"
fi

if [ -z "$FAILURE_REASON" ]; then
  FAILURE_REASON_JSON=null
else
  FAILURE_REASON_JSON=$(jq -Rn --arg reason "$FAILURE_REASON" '$reason')
fi

cat > /tmp/workload-payload.json <<JSON
{
  "workload_name": "$WORKLOAD_NAME",
  "namespace": "$NAMESPACE",
  "kind": "Deployment",
  "desired_replicas": $DESIRED,
  "available_replicas": $AVAILABLE,
  "pod_count": $POD_COUNT,
  "restart_count": $RESTART_COUNT,
  "status": "$STATUS",
  "failure_reason": $FAILURE_REASON_JSON
}
JSON

echo "Payload:"
cat /tmp/workload-payload.json | jq

echo "Posting workload to PlatformIQ..."
curl -s -X POST "$API/api/deployments/$DEPLOYMENT_ID/workloads" \
  -H "Content-Type: application/json" \
  --data @/tmp/workload-payload.json | jq
