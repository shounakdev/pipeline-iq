#!/usr/bin/env bash
set -euo pipefail

readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly BACKUP_CONFIG="/tmp/kubeconfig-docker.pre-sprint10j.yaml"

cd "${PROJECT_ROOT}"
[[ -f "${BACKUP_CONFIG}" ]] || {
  echo "Backup not found: ${BACKUP_CONFIG}" >&2
  exit 1
}

cp "${BACKUP_CONFIG}" kubeconfig-docker.yaml
sed -i 's/^CHAOS_ADAPTER=.*/CHAOS_ADAPTER=mock/' .env
docker compose up -d --force-recreate backend worker
docker compose exec backend sh -lc 'env | grep "^CHAOS_ADAPTER="'
docker compose exec worker sh -lc 'env | grep "^CHAOS_ADAPTER="'
echo "Restored the pre-validation kubeconfig and mock adapter."
