
# AI-Based Strategy Management System
## Installation Guide

This guide describes how to install the project on a new Windows development computer.

The system consists of:

- Laravel web application.
- Python FastAPI backend.
- MySQL database.
- XGBoost delay prediction model.
- Ollama language model service for AI features that depend on it.

## 1. Prerequisites

Install the following software:

| Software | Required version |
|---|---|
| PHP | 8.3 or later |
| Composer | Current stable version |
| Python | 3.11 |
| MySQL | 8.0 or compatible |
| Node.js | 22.12 or later |
| npm | Included with Node.js |
| Git | Current stable version |
| Ollama | Required only for Ollama-based features |

Enable the PHP extensions required by Laravel, including:

- PDO
- PDO MySQL
- OpenSSL
- Mbstring
- Tokenizer
- XML
- Ctype
- JSON
- Fileinfo

## 2. Clone the Repository

Open Git Bash or a terminal and run:

```bash
git clone -b main https://github.com/malak0411/AI_Based_strategy_management_system.git
cd AI_Based_strategy_management_system
```

The installation instructions refer to the `main` branch.

## 3. Create the MySQL Database

Start the MySQL server.

Create an empty database:

```sql
CREATE DATABASE strategic_management_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
```

Import the schema file:

`database/schema/full_schema_clean.sql`

Then import the reference data:

`database/seeders/data_seed.sql`

The schema file creates the database tables and triggers.

The seed file inserts reference and permission data. It does not create employee accounts or default login credentials.

Important:

- Import the files only into a newly created empty database.
- Do not import the original operational database dump.
- Do not run Laravel migrations during initial installation.
- Do not run destructive database commands.
- The schema contains 40 table definitions and includes MyISAM tables. Do not convert storage engines without testing.

## 4. Configure the Python Backend

Open a terminal:

```bash
cd backend
```

Create a Python virtual environment:

```bash
py -3.11 -m venv .venv
```

Activate it:

```powershell
.venv\Scripts\activate
```

Create the environment file:

```powershell
copy .env.example .env
```

Edit `backend/.env` and configure:

- DB_HOST
- DB_PORT
- DB_USER
- DB_PASSWORD
- DB_NAME
- SECRET_KEY
- ALLOWED_ORIGINS
- OLLAMA_HOST
- OLLAMA_MODEL
- SMTP settings if email functionality is required

Generate a strong random JWT secret. Do not use the example placeholder.

Install dependencies:

```bash
python -m pip install --upgrade pip
pip install -r requirements.txt
```

Verify dependency consistency:

```bash
pip check
```

The expected result is:

`No broken requirements found.`

## 5. Verify the AI Model Files

Check that the required model artifacts are present in:

`backend/models/`

The delay prediction service requires the model artifacts used by the project, including:

- `delay_model.pkl`
- `delay_feature_engineer.pkl`

Do not delete, rename, or replace these files without verifying the corresponding model-loading code.

The installed Python package versions must remain compatible with the saved model artifacts.

## 6. Configure Ollama

Ollama is required for features that use the local language model.

Install Ollama, start its service, and download the configured model:

```bash
ollama pull qwen2.5:3b
```

Verify the model:

```bash
ollama list
```

The default service address is:

`http://127.0.0.1:11434`

If Ollama is not installed or running, Ollama-dependent features will not be available.

## 7. Start FastAPI

From the `backend` directory, with the virtual environment activated:

```bash
uvicorn app.main:app --host 127.0.0.1 --port 8200
```

Keep this terminal open.

Verify the service:

- API: http://127.0.0.1:8200
- Swagger: http://127.0.0.1:8200/docs
- Health: http://127.0.0.1:8200/health

Use one worker unless the scheduler lifecycle has been changed and verified for multiple workers.

## 8. Configure Laravel

Open another terminal:

```bash
cd frontend
```

Create the environment file:

```powershell
copy .env.example .env
```

Edit `frontend/.env`.

Configure the application and database values:

- APP_ENV
- APP_DEBUG
- APP_URL
- DB_HOST
- DB_PORT
- DB_DATABASE
- DB_USERNAME
- DB_PASSWORD

Configure the FastAPI connection:

```dotenv
API_BASE_URL=http://127.0.0.1:8200
FASTAPI_URL=http://127.0.0.1:8200/api
```

For a different server or computer, replace `127.0.0.1` with the reachable server address.

Install PHP dependencies:

```bash
composer install
```

Generate the Laravel application key:

```bash
php artisan key:generate
```

Install frontend dependencies:

```bash
npm install
```

Build the frontend assets:

```bash
npm run build
```

Clear Laravel cached configuration:

```bash
php artisan optimize:clear
```

For a production deployment, set `APP_ENV=production` and `APP_DEBUG=false`.

## 9. Start Laravel

From the `frontend` directory:

```bash
php artisan serve --host=127.0.0.1 --port=8000
```

Open:

http://127.0.0.1:8000

## 10. Start the Services

Start the services in this order:

1. MySQL.
2. Ollama, if required.
3. FastAPI.
4. Laravel.

Keep the FastAPI and Laravel terminals running.

## 11. Initial Account Setup

The supplied schema and seed files do not create an employee account.

Although the seed file inserts the system roles and permissions, it does not provide a username or password for the first administrator.

A secure first-administrator creation procedure must be implemented and verified before this project can be considered ready for independent installation.

Do not assume that a default username or password exists.

Do not insert a plaintext password into the employees table.

## 12. Initial Verification

After the account bootstrap procedure is available, verify:

- MySQL is accessible.
- All 40 expected tables exist.
- Reference and permission data are available.
- FastAPI responds to the health check.
- Laravel can communicate with FastAPI.
- The login page is accessible.
- Authentication works with a valid account.
- The required XGBoost model files can be loaded.
- Ollama-dependent features work when Ollama is installed.

## 13. Deployment on Another Computer

When the system is accessed from another computer:

- Configure APP_URL using the reachable Laravel server address.
- Configure API_BASE_URL and FASTAPI_URL using the reachable FastAPI server address.
- Add the Laravel origin to the FastAPI CORS allowlist.
- Configure the required firewall rules.
- Do not expose MySQL or Ollama directly to untrusted networks.
- Use HTTPS for production deployments.
- Keep all secret values in local environment files, never in Git.

## 14. Database Safety

Do not execute:

```bash
php artisan migrate:fresh
```

Do not execute:

```bash
php artisan db:wipe
```

Do not execute:

```bash
php artisan migrate --force
```

The initial database is installed using the approved schema and seed files.

These SQL files are not an in-place upgrade mechanism.

## 15. Troubleshooting

### MySQL connection failed

Check the MySQL service, database name, port, username, and password.

### FastAPI does not start

Check the Python version, virtual environment, installed dependencies, and `backend/.env`.

### Laravel cannot connect to FastAPI

Check that FastAPI is running and that API_BASE_URL and FASTAPI_URL point to the correct address.

### Ollama is unavailable

Check that Ollama is running and that the configured model has been downloaded.

### Delay prediction fails

Verify the model artifacts and compatibility with the installed Python packages.

