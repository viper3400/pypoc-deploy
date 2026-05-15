# pypoc-deploy

Thin deployment repository for the `flask-plugin-platform` app plus the `pydo`
plugin.

## What This Runs

- `ghcr.io/viper3400/pypoc:0.2.0` as the base runtime image
- `flask-plugin-pydo` from `pydo` release `plugin-pydo-v0.1.0`
- Gunicorn on port `8000` inside the container
- Persistent task data mounted at `/app/data`

Plugin discovery is driven by installed Python package entry points. The
container uses `flask_plugin_platform:create_app()` directly and relies on the
platform's environment-to-config support for plugin settings.

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

This repo uses the published `pypoc` container image as its base runtime and
installs the `pydo` plugin wheel on top:

- `ghcr.io/viper3400/pypoc:0.2.0`
- `https://github.com/viper3400/pydo/releases/tag/plugin-pydo-v0.1.0`

See [Dockerfile](/Users/Jan/Documents/Development/pypoc-deploy/Dockerfile:1)
for the exact base image and plugin wheel, and
[docker-compose.yml](/Users/Jan/Documents/Development/pypoc-deploy/docker-compose.yml:1)
for the active runtime configuration.
