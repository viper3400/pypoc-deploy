# pypoc-deploy

Product deployment repository for the `flask-plugin-platform` app plus the
`pydo` plugin.

## What This Runs

- A single product image built from this repo
- `flask-plugin-platform` from the `pypoc` release `v0.2.0`
- `flask-plugin-pydo` from the `pydo` release `plugin-pydo-v0.1.0`
- Gunicorn on port `8000` inside the container
- Persistent task data mounted at `/app/data`

Plugin discovery is driven by installed Python package entry points. The
container uses a minimal [wsgi.py](/Users/Jan/Documents/Development/pypoc-deploy/wsgi.py:1)
bootstrap and relies on the platform's environment-to-config support for plugin
settings.

## Requirements

- Docker and Docker Compose
- Or Python `3.12` plus `uv` for local non-container runs

## Environment

Create a `.env` file before starting the app:

- `SECRET_KEY`: Flask session secret
- `PYTODO_PASSWORD_HASH`: password hash used by the `pydo` login gate
- `PYDO_UID`: host user id used to run the container process
- `PYDO_GID`: host group id used to run the container process

Optional runtime variables:

- `PORT`: defaults to `8000`
- `GUNICORN_WORKERS`: defaults to `2`
- `PLATFORM_APP_CONFIG_PREFIXES`: set to `PYDO,PYTODO` so pydo-related env vars are copied into `app.config`
- `PLATFORM_INSTANCE_PATH`: defaults to `/app/data/flask-instance`
- `PYDO_DATA_DIR`: defaults to `/app/data` in the container
- `HOME`: defaults to `/app/data` so Gunicorn runtime state is writable for the configured uid/gid

The `pydo` footer version is derived from the installed `flask-plugin-pydo`
package version during app startup.

## Run With Docker Compose

```bash
mkdir -p data
docker compose up --build
```

The app is exposed at `http://127.0.0.1:8080` and stores task data in the local
`./data` directory, mounted into the container as `/app/data`.
The Flask instance path is redirected under `/app/data/flask-instance`, so
the runtime user does not need write access inside `.venv`.

Example `.env`:

```dotenv
SECRET_KEY=change-me
PYTODO_PASSWORD_HASH=change-me
PYDO_UID=1000
PYDO_GID=1000
```

## Run Locally

Install dependencies:

```bash
uv sync
```

Start the server:

```bash
PLATFORM_APP_CONFIG_PREFIXES=PYDO,PYTODO \
PLATFORM_INSTANCE_PATH=./data/flask-instance \
PYDO_DATA_DIR=./data \
uv run gunicorn "flask_plugin_platform:create_app()" --bind 0.0.0.0:8000 --workers 2
```

Or use Flask directly during development:

```bash
PLATFORM_APP_CONFIG_PREFIXES=PYDO,PYTODO \
PLATFORM_INSTANCE_PATH=./data/flask-instance \
PYDO_DATA_DIR=./data \
uv run flask --app flask_plugin_platform.app:create_app run --debug
```

## Dependency Pins

This repo builds the final product image directly from pinned Python package
artifacts:

- `https://github.com/viper3400/pypoc/releases/download/v0.2.0/flask_plugin_platform-0.2.0-py3-none-any.whl`
- `https://github.com/viper3400/pydo/releases/tag/plugin-pydo-v0.1.0`

See [pyproject.toml](/Users/Jan/Documents/Development/pypoc-deploy/pyproject.toml:1)
for the version pins,
[Dockerfile](/Users/Jan/Documents/Development/pypoc-deploy/Dockerfile:1)
for the product image build, and
[docker-compose.yml](/Users/Jan/Documents/Development/pypoc-deploy/docker-compose.yml:1)
for the active runtime configuration.
