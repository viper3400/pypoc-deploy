from importlib.metadata import PackageNotFoundError, version

from flask_plugin_platform import create_app

app = create_app()

try:
    app.config.setdefault("PYDO_VERSION", version("flask-plugin-pydo"))
except PackageNotFoundError:
    pass
