#!/usr/bin/env bash
# Usage: bash scripts/check-pins.sh
# Dependabot does not update the tool versions pinned inside workflow `run:` steps.
# This lists the ones that are behind the latest release. Exit 1 when any is behind, 2 on a lookup error.
# Needs gh (authenticated), python3, and npm for markdownlint-cli2.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

files=$(ls .github/workflows/*.yml flavours/*/.github/workflows/*.yml 2>/dev/null)
[ -n "$files" ] || { echo "no workflows found"; exit 2; }

behind=0
errors=0

report() { # <name> <pinned> <latest>
  local p="${2#v}" l="${3#v}"
  if [ -z "$l" ]; then echo "ERROR  $1: could not look up the latest version"; errors=$((errors + 1))
  elif [ "$p" = "$l" ]; then echo "ok     $1 $p"
  else echo "BEHIND $1: pinned $p, latest $l"; behind=$((behind + 1)); fi
}

gh_latest() { gh api "repos/$1/releases/latest" --jq .tag_name 2>/dev/null; }

# Container images: <registry/>owner/name:tag@sha256:digest. The GitHub repo is owner/name.
# shellcheck disable=SC2086
images=$(grep -hoE "[a-z0-9./-]+/[a-z0-9._-]+:[v0-9][A-Za-z0-9._-]*@sha256:[0-9a-f]{64}" $files | sort -u)
for ref in $images; do
  path="${ref%%:*}"; path="${path#ghcr.io/}"
  tag="${ref#*:}"; tag="${tag%%@*}"
  report "$path" "$tag" "$(gh_latest "$path")"
done

# Release binary downloaded with gh
# shellcheck disable=SC2086
while read -r _ _ v _ r; do
  report "$r" "$v" "$(gh_latest "$r")"
done < <(grep -hoE "release download v[0-9][0-9.]* -R [A-Za-z0-9._/-]+" $files | sort -u)

# pip and npm tools
# shellcheck disable=SC2086
yv=$(grep -hoE "yamllint==[0-9][0-9.]*" $files | head -1 | sed 's/.*==//')
if [ -n "$yv" ]; then
  yl=$(python3 -c "import json,urllib.request as u; print(json.load(u.urlopen('https://pypi.org/pypi/yamllint/json'))['info']['version'])" 2>/dev/null)
  report yamllint "$yv" "$yl"
fi
# shellcheck disable=SC2086
mv=$(grep -hoE "markdownlint-cli2@[0-9][0-9.]*" $files | head -1 | sed 's/.*@//')
if [ -n "$mv" ]; then
  report markdownlint-cli2 "$mv" "$(npm view markdownlint-cli2 version 2>/dev/null)"
fi

echo
if [ "$errors" -gt 0 ]; then echo "$errors lookup error(s)"; fi
if [ "$behind" -gt 0 ]; then echo "$behind pin(s) behind"; exit 1; fi
[ "$errors" -eq 0 ] && echo "all pins current"
exit $(( errors > 0 ? 2 : 0 ))
