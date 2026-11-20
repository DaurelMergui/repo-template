#!/usr/bin/env bash
# Usage: bash scripts/init.sh <project-name> [github-owner]
set -euo pipefail
name="${1:?project name required}"
owner="${2:-$(gh api user --jq .login)}"
grep -rl -e 'OWNER' -e 'PROJECT' --exclude-dir=.git --exclude-dir=node_modules --exclude=init.sh . | while read -r f; do
  sed -i -e "s/@OWNER/@$owner/g" -e "s/^# PROJECT$/# $name/" "$f"
done
sed -i "s/\"name\": \"project\"/\"name\": \"$name\"/" package.json 2>/dev/null || true
echo "initialised $name for $owner"
