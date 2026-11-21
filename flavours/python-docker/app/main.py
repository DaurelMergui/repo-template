"""FastAPI entry point."""

from fastapi import FastAPI
from sqlalchemy import text

from app.db import engine

app = FastAPI(title="app")


@app.get("/health")
def health() -> dict[str, str]:
    """Liveness: the process is up. Does not touch the database."""
    return {"status": "ok"}


@app.get("/health/db")
def health_db() -> dict[str, str]:
    """Readiness: the database answers a query."""
    with engine.connect() as conn:
        conn.execute(text("SELECT 1"))
    return {"status": "ok"}
