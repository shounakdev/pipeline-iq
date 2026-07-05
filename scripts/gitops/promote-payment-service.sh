#!/usr/bin/env bash
set -euo pipefail

PIPELINE_ID="${1:-}"

if [ -z "$PIPELINE_ID" ]; then
  echo "Usage: scripts/gitops/promote-payment-service.sh <pipeline-id>"
  exit 1
fi

PLATFORMIQ_API_URL="${PLATFORMIQ_API_URL:-http://localhost:8000}"
GIT_BRANCH="$(git branch --show-current)"
VALUES_FILE="infrastructure/gitops/environments/staging/payment-service-values.yaml"

echo "Reading pipeline result from PlatformIQ..."
PIPELINE_JSON=$(curl -sS "$PLATFORMIQ_API_URL/pipeline/$PIPELINE_ID")

STATUS=$(echo "$PIPELINE_JSON" | jq -r '.status // empty')
RISK_LEVEL=$(echo "$PIPELINE_JSON" | jq -r '.risk_level // "UNKNOWN"')
COMMIT_SHA=$(echo "$PIPELINE_JSON" | jq -r '.commit_sha // empty')

echo "Pipeline status: $STATUS"
echo "Risk level: $RISK_LEVEL"
echo "Commit SHA: $COMMIT_SHA"

if [ "$STATUS" != "SUCCESS" ]; then
  echo "Pipeline is not successful. Deployment blocked."
  exit 1
fi

if [ "$RISK_LEVEL" = "CRITICAL" ]; then
  echo "Risk level is CRITICAL. Deployment blocked."
  exit 1
fi

if [ -n "$COMMIT_SHA" ] && [ "$COMMIT_SHA" != "null" ]; then
  IMAGE_TAG="${COMMIT_SHA:0:12}"
else
  IMAGE_TAG="${PIPELINE_ID:0:12}"
fi

IMAGE="platformiq/payment-service:$IMAGE_TAG"

echo "Building image: $IMAGE"
docker build -t "$IMAGE" demo-services/payment-service

echo "Loading image into Kind..."
kind load docker-image "$IMAGE" --name platformiq

echo "Updating GitOps values file..."
sed -i -E "s|tag: \".*\"|tag: \"$IMAGE_TAG\"|" "$VALUES_FILE"

echo "Git diff:"
git diff "$VALUES_FILE"

echo "Committing GitOps image update..."
git add "$VALUES_FILE"
git commit -m "chore(gitops): promote payment-service $IMAGE_TAG from pipeline $PIPELINE_ID"

echo "Pushing to branch: $GIT_BRANCH"
git push origin "$GIT_BRANCH"

echo "Refreshing Argo CD..."
kubectl annotate application payment-service -n argocd argocd.argoproj.io/refresh=hard --overwrite

echo "Promotion submitted."
echo "New image: $IMAGE"
