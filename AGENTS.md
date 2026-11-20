# AGENTS.md

Rules for every agent working in this repo.

## Language
- Use the terms in `GLOSSARY.md` and the shared agent glossary exactly; never use words listed under _Avoid_.
- If a request has a word that could mean two things, ask one question before starting.

## Decisions
- ADRs in `docs/adr/` are the source of truth. Read `docs/adr/INDEX.md` first, then only the ADRs a task needs.
- Never contradict an `accepted` ADR. Escalate to the operator instead.
- Agents may propose ADRs (`status: proposed`). Only the operator accepts them.

## Git and GitHub
- Never push or merge to `main`. Work on a branch, open a pull request, and wait for the operator to merge.
- Issues on GitHub are the tracker. Use the triage labels (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`) and tag your issues `agent:<name>`.
- Add a `Co-authored-by` or `Agent: <name>` trailer to commits so attribution survives the shared token.
- Run lint and tests before opening a PR; show the output in the PR.

## Safety
- No secrets in code, commits, issues or chat. Use GitHub Actions secrets or the operator's secret store.
- Any action that could cause downtime, data loss, spend or publication: stop and escalate.

## Context
- Keep sessions under the 200k-token budget: read in ranges, delegate large reads, write a handoff at about 100k tokens.

## Agent skills

### Issue tracker

Issues live in GitHub Issues (use the `gh` CLI). See `docs/agents/issue-tracker.md`.

### Triage labels

Default five-role vocabulary: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `GLOSSARY.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.
