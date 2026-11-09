# CSC325 CI/CD Pipeline

## Setup / Verification

Use Python 3.14. For initial setup, run from the repository root:

```sh
python3.14 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
```
Then run all local verification steps:

- Bash Script (tested on Linux)
```sh
./verify.sh
```
- Manually
```sh
source .venv/bin/activate
python -m pip check
python -m ruff check --config ruff.toml backend
python -m bandit -r backend -x backend/myapp/tests.py
cd backend
python manage.py check
python manage.py test --noinput --verbosity 2
```
### Endpoint testing:

```sh
cd backend/
python manage.py runserver
```
Open http://127.0.0.1:8000/api/hello

## AI disclosure

| Tool | Use | Verification |
| --- | --- | --- |
| Codex | Drafting .yml file | Changed Ubuntu version to fixed version (24.04) instead of latest, added timeouts, used Ruff & Bandit for making CICD more robust |
| Codex | Assisted in removing secrets from Django app based on tutorial, and applying them to an .env file | Reviewed the workflow configuration, ran Ruff, Bandit, and the test suite locally, and confirmed the GitHub Actions checks passed. | 
| Codex | Assisted with planning, generating the API endpoint and automated tests. | Reviewed the generated code, opened /api/hello/ locally to confirm its response, and ran all six automated tests successfully. |
| Codex | Updated bash script to be used for both local testing, and by the yml file | Verified that changes worked while running the script locally, local CICD, and GitHub Actions |