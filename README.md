# repo-template

Starting point for new repositories. Implements the [scaffold standard](docs/SCAFFOLD-STANDARD.md).

## Use it

1. On GitHub: **Use this template**, or `gh repo create <name> --template DaurelMergui/repo-template --private`.
2. Pick a flavour: `bash scripts/apply-flavour.sh node-docker` or `python-docker` (copies `flavours/<name>/` into the root and removes `flavours/`). Flavours: `node-docker` (Node, eslint, `node --test`), `python-docker` (FastAPI + Postgres, uv, ruff, pytest).
3. Replace `OWNER`/`PROJECT` placeholders: `bash scripts/init.sh <project-name>`.
4. Create the labels: `bash scripts/sync-labels.sh`.
5. Fill in `GLOSSARY.md`, then record the first decisions as ADRs in `docs/adr/`.

## What is in the base

| Path | Purpose |
|---|---|
| `AGENTS.md` | Rules every agent follows in this repo |
| `GLOSSARY.md` | Project vocabulary (global terms live in the shared agent glossary) |
| `docs/adr/` | Architecture Decision Records, canonical home |
| `docs/SCAFFOLD-STANDARD.md` | The written standard |
| `.github/` | Issue forms, PR template, CODEOWNERS, labels, CI, release and guard workflows |
| `scripts/` | Flavour apply, init, label sync |
