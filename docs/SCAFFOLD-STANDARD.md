# Scaffold Standard

Every repo created from this template follows these rules. Words in bold are defined in the shared agent glossary.

## 1. Layout
- Root has `README.md`, `AGENTS.md`, `GLOSSARY.md`, `LICENSE`, `.gitignore`, `.editorconfig`.
- Decisions live in `docs/adr/`. This is the canonical home for the project's **ADRs**.
- Automation lives in `.github/`; helper scripts in `scripts/`.
- A **Flavour** adds stack files (Dockerfile, lint config, source layout) on top of the **Base**.

## 2. Branches and merging
- `main` is always releasable. Nobody, human or agent, commits to it directly.
- All changes arrive by pull request. Only the **Operator** merges.
- Public repos: branch protection requires a PR and passing CI, and applies to admins too (so an agent using the operator token cannot push to `main`). Required approvals are 0 because a sole owner cannot approve their own PR; the operator's merge is the approval.
- `main-guard` skips root commits (no parent), which exist only when a repo is first created.
- Private repos on a free plan cannot use branch protection. The `main-guard` workflow detects direct pushes to `main` and fails; `AGENTS.md` forbids them. Upgrade to GitHub Pro to enforce.

## 3. Issues and labels
- GitHub Issues is the tracker. Issue forms: bug and enhancement.
- State labels: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`.
- Type labels: `bug`, `enhancement`. Owner labels: `agent:<name>`.
- New issues start `needs-triage`.
- `docs/agents/` configures the engineering skills (tracker, triage labels, domain docs). Wayfinder labels (`wayfinder:map`, `wayfinder:<type>`) exist for large plans.

## 4. Continuous integration
- `ci.yml` runs on every pull request and on pushes to `main`. The base job checks the repo structure; a **Flavour** replaces or extends it with lint, test and build.
- Workflow `permissions` default to `contents: read`; widen per job only.
- Third-party actions are pinned to a full commit SHA with the version in a trailing comment (`uses: owner/action@<sha> # v1.2.3`). Tags can be force-moved; a SHA cannot. Docker actions are pinned by digest.
- `.github/dependabot.yml` keeps those pins, and npm and Docker dependencies, current with weekly PRs. A flavour ships its own `dependabot.yml`; a repo with no flavour keeps only the `github-actions` entry (delete the `/flavours/...` entries).

## 5. Releases
- Semver tags `vMAJOR.MINOR.PATCH`. Pushing a tag creates a GitHub Release with notes generated from merged PR titles.
- PR titles are written as the change, in the imperative ("Add health check").

## 6. Secrets
- Never in the repo. Use GitHub Actions secrets. `.env` is git-ignored; ship `.env.example` with names only.

## 7. Agents
- Agents authenticate with the operator's token (ADR in the shared project). Attribution comes from commit trailers and `agent:<name>` labels.
- Agents follow `AGENTS.md`. Context budget: 200k tokens, handoff at about 100k.

## 8. Throwaway repos
- Repos made only to test the template are named `<name>-smoke-test`. The agent token cannot delete repos (least privilege), so archive them when finished: `gh repo archive <owner>/<name> --yes`. The operator deletes them in the GitHub UI.

## 9. Staying in sync
- `.github/template-managed.txt` lists the files every repo keeps identical to the template (labels, workflows, issue and PR templates, `docs/agents/`, helper scripts). `AGENTS.md`, `GLOSSARY.md`, `CODEOWNERS` and flavour files are the repo's own.
- `bash scripts/sync-from-template.sh` reports drift against the latest template release (exit 1 on drift); `--apply` overwrites drifted files, then open a PR.
- `template-drift.yml` runs it weekly and opens a `needs-triage` issue when a repo has drifted. Releases are how template changes reach repos: tag a release, then run the script.

## 10. Definition of done for a new repo
The repo was created from the template, `scripts/init.sh` was run, labels exist, CI is green on `main`, and the first ADR is recorded.
