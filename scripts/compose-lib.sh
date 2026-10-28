#!/usr/bin/env bash
# Shared compose helpers for ADH local infra.
# Sourced by Makefile targets.

set -euo pipefail

IAC_LOCAL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$IAC_LOCAL_ROOT"

INFRA_PROJECT="${INFRA_PROJECT:-adh-infra}"
INFRA_FILE="${INFRA_FILE:-docker-compose.local-infra.yml}"
BUZZ_FILE="${BUZZ_FILE:-docker-compose.buzz.yml}"
ENV_FILE="${ENV_FILE:-.env}"

ensure_env_file() {
  if [[ ! -f "$ENV_FILE" ]]; then
    echo "Creating $ENV_FILE from .env.example (local defaults; not committed)."
    cp "$IAC_LOCAL_ROOT/.env.example" "$IAC_LOCAL_ROOT/$ENV_FILE"
  fi
}

ensure_shared_resources() {
  if ! docker network inspect adh_local >/dev/null 2>&1; then
    echo "Creating network adh_local..."
    docker network create adh_local >/dev/null
  fi
}

compose_infra() {
  local args=(-p "$INFRA_PROJECT" -f "$INFRA_FILE")
  if [[ -f "$ENV_FILE" ]]; then
    args+=(--env-file "$ENV_FILE")
  fi
  docker compose "${args[@]}" "$@"
}

compose_buzz() {
  local args=(-p "$INFRA_PROJECT" -f "$INFRA_FILE" -f "$BUZZ_FILE")
  if [[ -f "$ENV_FILE" ]]; then
    args+=(--env-file "$ENV_FILE")
  fi
  docker compose "${args[@]}" "$@"
}

wait_container_healthy() {
  local name="$1"
  local timeout="${2:-120}"
  local elapsed=0
  echo "Waiting for $name healthy (timeout ${timeout}s)..."
  while (( elapsed < timeout )); do
    local status
    status="$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "$name" 2>/dev/null || echo missing)"
    if [[ "$status" == "healthy" ]]; then
      echo "  $name: $status"
      return 0
    fi
    echo "  $name: $status"
    sleep 3
    elapsed=$((elapsed + 3))
  done
  echo "ERROR: $name not healthy within ${timeout}s (last=$status)" >&2
  return 1
}

wait_infra_core() {
  wait_container_healthy adh-postgres 90
  wait_container_healthy adh-redis 60
  wait_container_healthy adh-litellm 180
}
