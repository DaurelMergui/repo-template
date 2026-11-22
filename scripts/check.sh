#!/usr/bin/env bash
# Usage: bash scripts/check.sh
# Runs the CI lint and security gates locally, so a push does not turn the CI red.
# Tool versions are read from .github/workflows/ci.yml: there is no second copy of the pins to drift.
# Needs Docker. Node (npx) is used for markdownlint when present. A gate whose tool is
# missing from ci.yml is skipped, not failed. Repo-specific extras: scripts/check-extra.sh.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

CI=.github/workflows/ci.yml
[ -f "$CI" ] || { echo "no $CI"; exit 2; }
command -v docker >/dev/null || { echo "docker is required"; exit 2; }

failed=()
ran=0

pin() { grep -hoE "[a-z0-9./-]*$1:[A-Za-z0-9._-]+@sha256:[0-9a-f]{64}" "$CI" | head -1 | sed 's|^/*||'; }
ver() { grep -hoE "$1[=@]+[0-9][0-9A-Za-z.]*" "$CI" | head -1 | sed -E 's/^[^=@]*[=@]+//'; }

# gate <name> <command...>: runs the command, records the result.
gate() {
  local name="$1"; shift
  ran=$((ran + 1))
  echo "== $name"
  if "$@"; then echo "   ok: $name"; else echo "   FAILED: $name"; failed+=("$name"); fi
}
skip() { echo "== $1"; echo "   skipped: $2"; }

img=$(pin rhysd/actionlint)
if [ -n "$img" ]; then
  wf=$(ls .github/workflows/*.yml flavours/*/.github/workflows/*.yml 2>/dev/null)
  # shellcheck disable=SC2086
  gate actionlint docker run --rm -v "$PWD:/repo" -w /repo "$img" -color $wf
else skip actionlint "not pinned in $CI"; fi

sc=$(ls scripts/*.sh flavours/*/scripts/*.sh 2>/dev/null)
if [ -n "$sc" ]; then
  # shellcheck disable=SC2086
  gate shellcheck docker run --rm -v "$PWD:/mnt" -w /mnt koalaman/shellcheck-alpine:stable shellcheck $sc
fi

yv=$(ver yamllint)
if [ -n "$yv" ]; then
  gate yamllint docker run --rm -v "$PWD:/repo" -w /repo python:3-slim sh -c "pip install --quiet --root-user-action=ignore yamllint==$yv && yamllint -c .yamllint.yml ."
else skip yamllint "not pinned in $CI"; fi

mv=$(ver markdownlint-cli2)
if [ -n "$mv" ] && command -v npx >/dev/null; then
  gate markdownlint npx --yes "markdownlint-cli2@$mv" "**/*.md"
else skip markdownlint "needs npx and a pin in $CI"; fi

img=$(pin gitleaks/gitleaks)
if [ -n "$img" ]; then
  gate gitleaks docker run --rm -v "$PWD:/repo" -w /repo "$img" git --no-banner --redact --verbose /repo
else skip gitleaks "not pinned in $CI"; fi

img=$(pin zizmorcore/zizmor)
if [ -n "$img" ]; then
  gate zizmor docker run --rm -v "$PWD:/repo" -w /repo "$img" --offline .
else skip zizmor "not pinned in $CI"; fi

img=$(pin hadolint/hadolint)
if [ -n "$img" ]; then
  for df in Dockerfile flavours/*/Dockerfile; do
    [ -f "$df" ] || continue
    hadolint_one() { docker run --rm -i "$img" < "$1"; }
    gate "hadolint $df" hadolint_one "$df"
  done
else skip hadolint "not pinned in $CI"; fi

img=$(pin aquasecurity/trivy)
if [ -n "$img" ]; then
  gate "trivy config" docker run --rm -v "$PWD:/work" -w /work "$img" config --exit-code 1 --severity HIGH,CRITICAL .
else skip "trivy config" "not pinned in $CI"; fi

skip pinact "runs in CI only (needs a release binary and a token)"

if [ -f scripts/check-extra.sh ]; then gate "check-extra" bash scripts/check-extra.sh; fi

echo
if [ "${#failed[@]}" -gt 0 ]; then
  echo "FAILED (${#failed[@]} of $ran): ${failed[*]}"
  exit 1
fi
echo "all $ran gates passed"
