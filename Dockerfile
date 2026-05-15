FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PORT=8000 \
    GUNICORN_WORKERS=2 \
    HOME=/app/data \
    VIRTUAL_ENV=/app/.venv \
    PATH="/app/.venv/bin:$PATH"

WORKDIR /app

RUN addgroup --system app && adduser --system --ingroup app --home /home/app app
RUN pip install --no-cache-dir uv

COPY pyproject.toml uv.lock wsgi.py ./
RUN uv sync --locked --no-dev
RUN mkdir -p /app/data && chown -R app:app /app

USER app

EXPOSE 8000
VOLUME ["/app/data"]

CMD ["sh", "-c", "gunicorn \"wsgi:app\" --bind 0.0.0.0:${PORT:-8000} --workers ${GUNICORN_WORKERS:-2}"]
