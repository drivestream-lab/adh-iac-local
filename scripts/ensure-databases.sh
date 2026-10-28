#!/usr/bin/env bash
# Create ADH databases if missing (existing postgres_data volumes skip initdb.d).
# Fresh volumes get these from config/postgres/02-init-databases.sh on first init.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=compose-lib.sh
source "$SCRIPT_DIR/compose-lib.sh"

USER="${POSTGRES_USER:-adh}"

if ! docker inspect -f '{{.State.Running}}' adh-postgres 2>/dev/null | grep -q true; then
  echo "ERROR: adh-postgres is not running. Run: make infra-up" >&2
  exit 1
fi

for db in litellm buzz hermes ledger realworld; do
  echo "Ensuring database '$db' exists (user=$USER)..."
  exists="$(compose_infra exec -T postgres \
    psql -U "$USER" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname = '$db'" | tr -d '[:space:]')"
  if [[ "$exists" == "1" ]]; then
    echo "  $db already exists."
  else
    compose_infra exec -T postgres psql -U "$USER" -d postgres -c "CREATE DATABASE $db"
    compose_infra exec -T postgres psql -U "$USER" -d postgres -c "GRANT ALL PRIVILEGES ON DATABASE $db TO $USER"
    echo "  created $db."
  fi
  compose_infra exec -T postgres psql -U "$USER" -d "$db" -c "CREATE EXTENSION IF NOT EXISTS vector" >/dev/null
done
