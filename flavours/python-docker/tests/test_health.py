from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health() -> None:
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json() == {"status": "ok"}


def test_health_db() -> None:
    """Needs a reachable Postgres (docker compose up db, or the CI service)."""
    r = client.get("/health/db")
    assert r.status_code == 200
