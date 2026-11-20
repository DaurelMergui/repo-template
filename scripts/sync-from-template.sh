#!/usr/bin/env bash
# Compare this repo with the files the template manages (.github/template-managed.txt).
# Usage: bash scripts/sync-from-template.sh [--apply] [ref]
#   ref      template tag or branch. Default: latest release tag, else main.
#   --apply  overwrite drifted or missing files with the template's copy.
# Env: TEMPLATE_REPO (default DaurelMergui/repo-template), TEMPLATE_DIR (use a local checkout, for tests).
# Exit: 0 in sync (or applied), 1 drift found, 2 usage or fetch error.
set -euo pipefail

apply=0
if [ "${1:-}" = "--apply" ]; then apply=1; shift; fi
template="${TEMPLATE_REPO:-DaurelMergui/repo-template}"
ref="${1:-}"

if [ -n "${TEMPLATE_DIR:-}" ]; then
  src="$TEMPLATE_DIR"
  ref="local"
else
  if [ -z "$ref" ]; then
    ref=$(gh release view -R "$template" --json tagName --jq .tagName 2>/dev/null || echo main)
  fi
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  # Git Bash on Windows: native git needs a Windows path for the same folder.
  gitdir="$tmp"
  if command -v cygpath >/dev/null 2>&1; then gitdir=$(cygpath -m "$tmp"); fi
  git -c advice.detachedHead=false clone -q --depth 1 --branch "$ref" "https://github.com/$template.git" "$gitdir/t" || { echo "cannot fetch $template at $ref"; exit 2; }
  src="$tmp/t"
fi

list="$src/.github/template-managed.txt"
[ -f "$list" ] || { echo "$template at $ref has no .github/template-managed.txt (needs a release that includes it; try: sync-from-template.sh main)"; exit 2; }

drift=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  if [ ! -f "$f" ]; then
    echo "missing: $f"; drift=1
  elif ! cmp -s "$src/$f" "$f"; then
    echo "differs: $f"; drift=1
  else
    continue
  fi
  if [ "$apply" -eq 1 ]; then
    mkdir -p "$(dirname "$f")"
    cp "$src/$f" "$f"
    echo "  updated from $template@$ref"
  fi
done < "$list"

if [ "$drift" -eq 0 ]; then
  echo "in sync with $template@$ref"
elif [ "$apply" -eq 1 ]; then
  echo "applied; review with git diff and open a PR"
  exit 0
else
  echo "drift from $template@$ref; run: bash scripts/sync-from-template.sh --apply $ref"
  exit 1
fi
