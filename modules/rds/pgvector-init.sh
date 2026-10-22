#!/bin/sh
set -eu

dnf install -y postgresql16

secret_json=''
for attempt in $(seq 1 12); do
  if secret_json=$(aws secretsmanager get-secret-value --region '${aws_region}' --secret-id '${secret_arn}' --query SecretString --output text 2>/dev/null); then
    break
  fi
  sleep 5
done
if [ -z "$secret_json" ]; then
  echo 'Could not retrieve RDS credentials' >&2
  exit 1
fi

export PGHOST='${database_address}'
export PGPORT='${database_port}'
export PGDATABASE='${database_name}'
PGUSER=$(printf '%s' "$secret_json" | python3 -c 'import json,sys; print(json.load(sys.stdin)["username"])')
PGPASSWORD=$(printf '%s' "$secret_json" | python3 -c 'import json,sys; print(json.load(sys.stdin)["password"])')
export PGUSER PGPASSWORD
export PGSSLMODE=require
unset secret_json

for attempt in $(seq 1 30); do
  if pg_isready -q && psql -w -v ON_ERROR_STOP=1 -c 'CREATE EXTENSION IF NOT EXISTS vector;'; then
    echo 'pgvector initialized'
    exit 0
  fi
  sleep 10
done

echo 'pgvector initialization failed' >&2
exit 1
