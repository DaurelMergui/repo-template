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
- Public repos: branch protection requires a PR, one approval and passing CI.
- Private repos on a free plan cannot use branch protection. The `main-guard` workflow detects direct pushes to `main` and fails; `AGENTS.md` forbids them. Upgrade to GitHub Pro to enforce.

## 3. Issues and labels
- GitHub Issues is the tracker. Issue forms: bug and enhancement.
- State labels: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`.
- Type labels: `bug`, `enhancement`. Owner labels: `agent:<name>`.
- New issues start `needs-triage`.

## 4. Continuous integration
- `ci.yml` runs on every pull request and on pushes to `main`. The base job checks the repo structure; a **Flavour** replaces or extends it with lint, test and build.
- Workflow `permissions` default to `contents: read`; widen per job only.
- Third-party actions are pinned to a major version at minimum.

## 5. Releases
- Semver tags `vMAJOR.MINOR.PATCH`. Pushing a tag creates a GitHub Release with notes generated from merged PR titles.
- PR titles are written as the change, in the imperative ("Add health check").

## 6. Secrets
- Never in the repo. Use GitHub Actions secrets. `.env` is git-ignored; ship `.env.example` with names only.

## 7. Agents
- Agents authenticate with the operator's token (ADR in the shared project). Attribution comes from commit trailers and `agent:<name>` labels.
- Agents follow `AGENTS.md`. Context budget: 200k tokens, handoff at about 100k.

## 8. Definition of done for a new repo
The repo was created from the template, `scripts/init.sh` was run, labels exist, CI is green on `main`, and the first ADR is recorded.
