# pypoc-deploy

Thin deployment repository for the `flask-plugin-platform` app plus the `pydo`
plugin.

## What This Runs

- `flask-plugin-platform` from `pypoc` release `v0.1.0`
- `flask-plugin-pydo` from `pydo` release `plugin-pydo-v0.1.0`
- Gunicorn on port `8000` inside the container
- Persistent task data mounted at `/app/data`

The app is created in wsgi.py
and plugin discovery is driven by installed Python package entry points.

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
- `PYDO_DATA_DIR`: defaults to `/app/data` in the container
- `HOME`: defaults to `/app/data` so Gunicorn runtime state is writable for the configured uid/gid

The `pydo` footer version is derived from the installed `flask-plugin-pydo`
package version during app startup.

## Run With Docker Compose

```bash
mkdir -p data
docker compose up --build
```

The app is exposed at `http://127.0.0.1:8081` and stores task data in the local
`./data` directory, mounted into the container as `/app/data`.
The Flask instance path is also redirected under `/app/data/flask-instance`, so
the runtime user does not need write access inside `.venv`.

Example `.env`:

```dotenv
SECRET_KEY=change-me
PYTODO_PASSWORD_HASH=change-me
PYDO_UID=501
PYDO_GID=20
```

## Run Locally

Install dependencies:

```bash
uv sync
```

Start the server:

```bash
uv run gunicorn "wsgi:app" --bind 0.0.0.0:8000 --workers 2
```

Or use Flask directly during development:

```bash
uv run flask --app wsgi:app run --debug
```

## Dependency Pins

This repo intentionally installs the published release wheels directly from
GitHub:

- `https://github.com/viper3400/pypoc/releases/tag/v0.1.0`
- `https://github.com/viper3400/pydo/releases/tag/plugin-pydo-v0.1.0`

See pyproject.toml
for the exact wheel URLs and docker-compose.yml
for the active runtime configuration.
