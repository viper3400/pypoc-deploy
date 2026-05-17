FROM python:3.12-slim

ARG PLATFORM_DEPLOYMENT_VERSION=local-dev
ARG PLATFORM_BUILD_SHA=local-dev

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000 \
    GUNICORN_WORKERS=2 \
    HOME=/app/data \
    PLATFORM_DEPLOYMENT_NAME=pypoc-deploy \
    PLATFORM_DEPLOYMENT_VERSION=${PLATFORM_DEPLOYMENT_VERSION} \
    PLATFORM_BUILD_SHA=${PLATFORM_BUILD_SHA}

WORKDIR /app

RUN pip install --no-cache-dir uv

COPY pyproject.toml uv.lock README.md wsgi.py ./

RUN uv sync --locked --no-dev
RUN mkdir -p /app/data

EXPOSE 8000
VOLUME ["/app/data"]

CMD ["sh", "-c", "uv run gunicorn \"wsgi:app\" --bind 0.0.0.0:${PORT:-8000} --workers ${GUNICORN_WORKERS:-2}"]
