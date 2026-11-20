#!/usr/bin/env bash
# Usage: bash scripts/apply-flavour.sh <flavour>   e.g. node-docker
set -euo pipefail
f="${1:?flavour name required}"
src="flavours/$f"
[ -d "$src" ] || { echo "unknown flavour: $f (available: $(cd flavours && echo *))"; exit 1; }
cp -r "$src"/. .
rm -rf flavours
echo "applied flavour $f; flavours/ removed"
