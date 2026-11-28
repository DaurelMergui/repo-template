FROM ghcr.io/astral-sh/uv:0.13.10@sha256:a3ea1357342c1a4bf9a0c53a3deb1b55379aefa037338d8113d5771efa01774f AS uv

FROM python:3.15-slim@sha256:65a65fc7b30b06cb6df4930fd4650697cb23f4c2698ab81fc87e4b031bc36928
# Base images lag Debian security fixes; pick them up at build time.
# hadolint ignore=DL3005
RUN apt-get update \
    && apt-get -y upgrade \
    && rm -rf /var/lib/apt/lists/*
# The service runs from a uv-built venv, not the system pip; the pip in the base image
# vendors msgpack, urllib3 and setuptools copies that carry their own CVEs.
RUN python -m pip uninstall -y pip
COPY --from=uv /uv /usr/local/bin/uv
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_LINK_MODE=copy \
    UV_NO_CACHE=1 \
    UV_PYTHON_DOWNLOADS=never \
    PATH="/srv/app/.venv/bin:$PATH"
WORKDIR /srv/app
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev
COPY app ./app
COPY alembic.ini ./
COPY migrations ./migrations
USER 1000
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s CMD ["python", "-c", "import urllib.request as u; u.urlopen('http://localhost:8000/health', timeout=2)"]
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
