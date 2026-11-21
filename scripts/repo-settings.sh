#!/usr/bin/env bash
# Apply repo settings the standard expects. Run once per repo. Needs gh, authenticated with admin rights on the repo.
set -euo pipefail
repo="${1:-$(gh repo view --json nameWithOwner --jq .nameWithOwner)}"
# Merged PR branches are deleted automatically.
gh api -X PATCH "repos/$repo" -F delete_branch_on_merge=true --jq '"\(.full_name): delete_branch_on_merge=\(.delete_branch_on_merge)"'
