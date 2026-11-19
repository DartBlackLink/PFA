#!/usr/bin/env bash
# Remote execution only after production approval. No database reset or prune.
set -euo pipefail
umask 077
root=${1:?Deployment root required}
sha=${2:?Tested commit required}
[[ "$root" =~ ^/srv/[a-zA-Z0-9_-]+$ && "$sha" =~ ^[a-f0-9]{40}$ ]] || exit 2
[[ -f "$root/.env" ]] || { echo 'Production private .env must already exist'; exit 2; }
release="$root/releases/$sha"
[[ ! -e "$release" ]] || { echo 'Release already exists; investigate before repeating migrations'; exit 2; }
mkdir -p "$root/releases" "$root/private/backups" "$release"
archive="/tmp/ecologistica-$sha.tar.gz"
# Refuse unexpected archive paths before extracting code received from CI.
while IFS= read -r item; do
  [[ "$item" != /* && "$item" != *..* ]] || exit 2
done < <(tar -tzf "$archive")
tar -xzf "$archive" -C "$release" --no-same-owner
backup="$root/private/backups/pre-$sha.dump"
# The operator provisions the existing production PostgreSQL and external volume.
# Keep credentials in the container environment and dumps outside the release.
docker exec ecologistica-postgres sh -c 'pg_dump -Fc -U "$POSTGRES_USER" "$APP_DB_NAME"' > "$backup"
test -s "$backup"
docker exec -i ecologistica-postgres pg_restore --list < "$backup" > /dev/null
cd "$release"
compose=(docker compose --env-file "$root/.env" -f docker-compose.yml)
"${compose[@]}" build api web
"${compose[@]}" up -d --no-deps api web
for attempt in {1..60}; do
  if curl --fail --silent --max-time 2 http://127.0.0.1:8000/api/v1/health > /dev/null \
    && curl --fail --silent --max-time 2 http://127.0.0.1:8080/healthz > /dev/null; then
    ln -sfn "$release" "$root/current"
    echo "Deployment healthy: $sha; private pre-migration backup retained"
    exit 0
  fi
  sleep 2
done
echo 'Health check failed. Preserve backup and releases; inspect migration compatibility before rollback.'
exit 1
