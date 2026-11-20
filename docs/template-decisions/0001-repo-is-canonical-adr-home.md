---
status: accepted
---
# For projects with a repo, the repo's docs/adr is the canonical ADR home

Two ADR homes (shared folder and repo) would drift apart. We chose the repo as the single source of truth; the shared folder keeps only the project card and a pointer, and any local copy is synced from the repo, never the reverse.

Exception: the template repo's own ADRs would be copied into every new repo, so they live in `docs/template-decisions/` in repo-template (deleted by init.sh); the shared folder keeps a copy as pointer.
