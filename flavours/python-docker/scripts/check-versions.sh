#!/usr/bin/env bash
# Fail when the Python and uv versions declared in different files disagree.
# Dependabot bumps only the Dockerfile, so the rest drifts unless something checks it.
# Usage: bash scripts/check-versions.sh   (run from anywhere; checks the repo this script is in)
set -euo pipefail
cd "$(dirname "$0")/.."

py_docker=$(sed -n 's/^FROM python:\([0-9]*\.[0-9]*\).*/\1/p' Dockerfile | head -n1)
uv_docker=$(sed -n 's#^FROM ghcr.io/astral-sh/uv:\([0-9.]*\)@.*#\1#p' Dockerfile | head -n1)
py_file=$(tr -d '[:space:]' < .python-version)
py_requires=$(sed -n 's/^requires-python = ">=\([0-9]*\.[0-9]*\).*/\1/p' pyproject.toml | head -n1)
py_ruff=$(sed -n 's/^target-version = "py\([0-9]\)\([0-9]*\)".*/\1.\2/p' pyproject.toml | head -n1)
uv_ci=$(sed -n 's/^ *version: "\([0-9.]*\)".*/\1/p' .github/workflows/ci.yml | head -n1)

printf '%-34s %s\n' \
  "Dockerfile python image" "$py_docker" \
  ".python-version" "$py_file" \
  "pyproject requires-python (>=)" "$py_requires" \
  "pyproject ruff target-version" "$py_ruff" \
  "Dockerfile uv image" "$uv_docker" \
  "ci.yml setup-uv version" "$uv_ci"

status=0
for v in "$py_docker" "$py_file" "$py_requires" "$py_ruff" "$uv_docker" "$uv_ci"; do
  [ -n "$v" ] || { echo "FAIL: a version could not be read (see blanks above)"; exit 1; }
done
for v in "$py_file" "$py_requires" "$py_ruff"; do
  [ "$v" = "$py_docker" ] || { echo "FAIL: Python version $v does not match the Dockerfile ($py_docker)"; status=1; }
done
[ "$uv_ci" = "$uv_docker" ] || { echo "FAIL: setup-uv $uv_ci does not match the Dockerfile uv image ($uv_docker)"; status=1; }
[ "$status" -eq 0 ] && echo "versions agree"
exit "$status"
