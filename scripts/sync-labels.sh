#!/usr/bin/env bash
# Create or update the labels in .github/labels.yml on the current repo. Needs gh and python3.
set -euo pipefail
python3 - <<'PY' | while IFS=$'\t' read -r name color desc; do
import re, sys, json
for line in open(".github/labels.yml"):
    m = re.match(r'- \{name: "?([^",]+)"?, color: ([0-9a-f]{6}), description: (.*)\}', line.strip())
    if m: print("\t".join(m.groups()))
PY
  gh label create "$name" --color "$color" --description "$desc" --force
done
