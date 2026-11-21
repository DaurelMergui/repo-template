#!/usr/bin/env bash
# Run lint, migrations and the test suite inside Docker against a throwaway Postgres.
# Needs only Docker: no local Python, uv, or Postgres. Handy where `uv sync` cannot build
# (for example Windows on a pre-release Python). The Python, uv and Postgres images are
# read from Dockerfile and docker-compose.yml, so this cannot drift from what ships.
# Usage: bash scripts/test-in-docker.sh [pytest args]
set -euo pipefail
cd "$(dirname "$0")/.."

py_img=$(sed -n 's/^FROM \(python:[^ ]*\).*/\1/p' Dockerfile | head -n1)
uv_img=$(sed -n 's/^FROM \(ghcr.io\/astral-sh\/uv:[^ ]*\) .*/\1/p' Dockerfile | head -n1)
pg_img=$(sed -n 's/^ *image: \(postgres:[^ ]*\).*/\1/p' docker-compose.yml | head -n1)
for v in "$py_img" "$uv_img" "$pg_img"; do
  [ -n "$v" ] || { echo "could not read image names from Dockerfile / docker-compose.yml"; exit 1; }
done

id=$$
net="app-test-net-$id"
db="app-test-db-$id"
img="app-test-img:$id"
# Git Bash on Windows needs a Windows path for docker bind mounts.
src=$(pwd -W 2>/dev/null || pwd)

cleanup() {
  docker rm -f "$db" >/dev/null 2>&1 || true
  docker network rm "$net" >/dev/null 2>&1 || true
  docker rmi "$img" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker network create "$net" >/dev/null
docker run -d --name "$db" --network "$net" \
  -e POSTGRES_USER=app -e POSTGRES_PASSWORD=app -e POSTGRES_DB=app "$pg_img" >/dev/null
printf 'FROM %s AS uv\nFROM %s\nCOPY --from=uv /uv /usr/local/bin/uv\n' "$uv_img" "$py_img" \
  | docker build -q -t "$img" - >/dev/null

for _ in $(seq 1 30); do
  docker exec "$db" pg_isready -U app -d app >/dev/null 2>&1 && break
  sleep 1
done

docker run --rm --network "$net" -v "$src:/src:ro" \
  -e POSTGRES_HOST="$db" -e UV_PROJECT_ENVIRONMENT=/tmp/venv -e UV_LINK_MODE=copy \
  -e UV_NO_CACHE=1 -e PYTHONDONTWRITEBYTECODE=1 \
  "$img" sh -c '
    set -e
    mkdir /work
    tar -C /src --exclude=.venv --exclude=.git --exclude=__pycache__ -cf - . | tar -C /work -xf -
    cd /work
    uv sync --frozen
    uv run ruff check .
    uv run alembic upgrade head
    uv run pytest "$@"
  ' sh "$@"
