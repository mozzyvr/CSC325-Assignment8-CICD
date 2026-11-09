#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$repo_root"

# CI supplies VERIFY_PYTHON; locally prefer an active environment or .venv.
verification_python="${VERIFY_PYTHON:-${VIRTUAL_ENV:-$repo_root/.venv}/bin/python}"
if ! verification_python="$(command -v -- "$verification_python")"; then
    echo "Set VERIFY_PYTHON to a Python 3.14 executable, activate a virtual environment, or create .venv." >&2
    echo "Then install dependencies with: python -m pip install -r requirements.txt" >&2
    exit 1
fi
# Resolve relative executable paths before changing into backend/.
if [[ "$verification_python" != /* ]]; then
    verification_python="$repo_root/$verification_python"
fi

"$verification_python" -m pip check
"$verification_python" -m ruff check --config ruff.toml backend
"$verification_python" -m bandit -r backend -x backend/myapp/tests.py

cd backend
"$verification_python" manage.py check

# Require the assignment's minimum test count in both local and CI runs.
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
echo "Verification passed."
