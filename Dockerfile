FROM ghcr.io/viper3400/pypoc:0.2.0

ARG PYDO_PLUGIN_WHEEL_URL="https://github.com/viper3400/pydo/releases/download/plugin-pydo-v0.1.0/flask_plugin_pydo-0.1.0-py3-none-any.whl"

ENV PORT=8000 \
    GUNICORN_WORKERS=2 \
    HOME=/app/data

WORKDIR /app

RUN python -m pip install --no-cache-dir "${PYDO_PLUGIN_WHEEL_URL}"
RUN mkdir -p /app/data

EXPOSE 8000
VOLUME ["/app/data"]

CMD ["sh", "-c", "gunicorn \"flask_plugin_platform:create_app()\" --bind 0.0.0.0:${PORT:-8000} --workers ${GUNICORN_WORKERS:-2}"]
