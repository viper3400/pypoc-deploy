import os
from pathlib import Path
from importlib.metadata import PackageNotFoundError, version

from flask_plugin_platform import create_app

app = create_app()

configured_data_dir = os.getenv("PYDO_DATA_DIR")
configured_todo_file = os.getenv("PYDO_TODO_FILE")

if configured_data_dir:
    data_dir = Path(configured_data_dir)
    app.instance_path = str(data_dir / "flask-instance")
    data_dir.mkdir(parents=True, exist_ok=True)
    Path(app.instance_path).mkdir(parents=True, exist_ok=True)
    app.config["PYDO_DATA_DIR"] = str(data_dir)

if configured_todo_file:
    app.config["PYDO_TODO_FILE"] = configured_todo_file

try:
    app.config.setdefault("PYDO_VERSION", version("flask-plugin-pydo"))
except PackageNotFoundError:
    pass
