# python-docker flavour

FastAPI + SQLAlchemy + Alembic + Postgres service. Dependencies are managed with uv; `uv.lock` is committed and is what the Docker image installs (`uv sync --frozen`) and what osv-scanner scans, so the scan covers exactly what ships. Lint and format with ruff (rules E, F, W, I, S, B, UP, C4, SIM), tests with pytest against a real Postgres. The image is digest-pinned, runs as a non-root user and has a healthcheck. Modelled on the `accpac` repo. Image publishing is deliberately not included.

Local development: `uv sync`, `docker compose up -d db`, then `uv run pytest`. After changing dependencies run `uv lock`.
