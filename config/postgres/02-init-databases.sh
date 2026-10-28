#!/bin/bash
# Create ADH application databases on first Postgres cluster init.
# Idempotent ensure for existing volumes: scripts/ensure-databases.sh
set -euo pipefail

psql=(psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER")

for db in litellm buzz hermes ledger realworld; do
  "${psql[@]}" --dbname postgres -tc "SELECT 1 FROM pg_database WHERE datname = '$db'" | grep -q 1 \
    || "${psql[@]}" --dbname postgres -c "CREATE DATABASE $db"
  "${psql[@]}" --dbname postgres -c "GRANT ALL PRIVILEGES ON DATABASE $db TO $POSTGRES_USER"
  "${psql[@]}" --dbname "$db" -c "CREATE EXTENSION IF NOT EXISTS vector"
done
