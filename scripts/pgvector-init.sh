#!/bin/sh
set -eu

if ! command -v psql >/dev/null 2>&1 || ! command -v pg_isready >/dev/null 2>&1; then
  dnf install -y postgresql16
fi

secret_json=$(aws secretsmanager get-secret-value --region '${aws_region}' --secret-id '${secret_arn}' --query SecretString --output text)

export PGHOST='${database_address}'
export PGPORT='${database_port}'
export PGDATABASE='${database_name}'
PGUSER=$(printf '%s' "$secret_json" | python3 -c 'import json,sys; print(json.load(sys.stdin)["username"])')
PGPASSWORD=$(printf '%s' "$secret_json" | python3 -c 'import json,sys; print(json.load(sys.stdin)["password"])')
export PGUSER PGPASSWORD
export PGSSLMODE=require
export PGCONNECT_TIMEOUT=5
unset secret_json

for attempt in $(seq 1 30); do
  if pg_isready -q; then
    psql -X -w -v ON_ERROR_STOP=1 -c 'CREATE EXTENSION IF NOT EXISTS vector;'
    exit 0
  fi
  sleep 10
done

echo 'RDS PostgreSQL did not become ready for pgvector initialization' >&2
exit 1
