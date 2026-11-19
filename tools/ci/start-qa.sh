#!/usr/bin/env bash
set -euo pipefail
[[ ${GITHUB_ACTIONS:-} == true ]] || { echo 'Solo para un runner efímero GitHub Actions'; exit 2; }
[[ ${GITHUB_RUN_ID:-} =~ ^[0-9]+$ ]] || exit 2
name="ecologistica-ci-${GITHUB_RUN_ID}-${GITHUB_JOB}"
[[ "$name" =~ ^ecologistica-ci-[0-9]+-[a-zA-Z0-9_-]+$ ]] || exit 2
qa_password=$(openssl rand -hex 32)
qa_key=$(openssl rand -hex 48)
echo "::add-mask::$qa_password"
echo "::add-mask::$qa_key"
export POSTGRES_PASSWORD="$qa_password"
docker run -d --name "$name" --label "ecologistica.ci.run=$GITHUB_RUN_ID" \
  --tmpfs /var/lib/postgresql/data -p 127.0.0.1:5432:5432 \
  -e POSTGRES_PASSWORD -e POSTGRES_USER=qa \
  -e POSTGRES_DB=ecologistica_revision_20261007 postgres:16-alpine > /dev/null
{
  echo "QA_CONTAINER=$name"
  echo "DATABASE_URL=postgresql+psycopg://qa:$qa_password@postgres-qa:5432/ecologistica_revision_20261007"
  echo "E2E_QA_DATABASE_URL=postgresql+psycopg://qa:$qa_password@postgres-qa:5432/ecologistica_revision_20261007"
  echo 'PGHOSTADDR=127.0.0.1'
  echo "SECRET_KEY=$qa_key"
  echo 'BOOTSTRAP_DEMO_USERS=false'
  echo 'PYTHONPATH=backend'
} >> "$GITHUB_ENV"
for attempt in {1..40}; do
  if docker exec "$name" pg_isready -U qa -d ecologistica_revision_20261007 > /dev/null 2>&1; then exit 0; fi
  sleep 1
done
echo 'PostgreSQL QA no respondió'; exit 1
