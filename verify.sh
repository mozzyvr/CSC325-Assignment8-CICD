#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$repo_root"

# Use the activated environment, or the repository's default virtual environment.
verification_python="${VIRTUAL_ENV:-$repo_root/.venv}/bin/python"
if [[ ! -x "$verification_python" ]]; then
    echo "Activate a Python 3.14 virtual environment or create .venv first." >&2
    echo "Then install dependencies with: python -m pip install -r requirements.txt" >&2
    exit 1
fi

"$verification_python" -m pip check
"$verification_python" -m ruff check --config ruff.toml backend
"$verification_python" -m bandit -r backend -x backend/myapp/tests.py

cd backend
"$verification_python" manage.py check

# Match CI's minimum-test guard so an empty suite cannot report success locally.
"$verification_python" - <<'PY'
import os

import django
from django.conf import settings
from django.test.utils import get_runner

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "backend.settings")
django.setup()
runner = get_runner(settings)(verbosity=0)
count = runner.build_suite().countTestCases()
if count < 2:
    raise SystemExit(f"Expected at least 2 tests; discovered {count}.")
PY

"$verification_python" manage.py test --noinput --verbosity 2
echo "Local verification passed."
