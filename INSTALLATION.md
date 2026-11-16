
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


## 3. Create and Initialize the MySQL Database

Start the MySQL server and create a new empty database:

```sql
CREATE DATABASE strategic_management_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
```

Import the following SQL files in the exact order shown:

1. `database/schema/full_schema_clean.sql`
   - Creates the database tables and triggers.

2. `database/seeders/data_seed.sql`
   - Inserts reference data, system roles, and permissions.

3. `database/seeders/demo_data_seed.sql`
   - Inserts selected sample departments, employees, strategic plans, goals, programs, initiatives, tasks, KPIs, budgets, assignments, and risk records.
   - Creates four demonstration login accounts.

The third file is intended for demonstration and testing installations. It is not required for a production database.

You can import the files using phpMyAdmin:

1. Open the `strategic_management_db` database.
2. Select the Import tab.
3. Choose the first SQL file and import it.
4. Repeat for the second and third files, in the specified order.

Important:

- Import these files only into a newly created empty database.
- Do not import the original operational database dump.
- Do not run Laravel migrations during initial installation.
- Do not import `demo_data_seed.sql` into an existing database containing project data.
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


## 11. Demonstration Login Accounts

When `database/seeders/demo_data_seed.sql` has been imported successfully, the following demonstration accounts are available:

| Role | Email | Password |
|---|---|---|
| Super Admin | admin@example.com | AdminDemo@2026! |
| Minister | minister@example.com | MinisterDemo@2026! |
| Manager | manager@example.com | ManagerDemo@2026! |
| Employee | employee@example.com | EmployeeDemo@2026! |

These accounts are provided for local demonstration and testing only.

Important security notes:

- The passwords are stored as bcrypt hashes in the database.
- These are public demonstration credentials and must never be used for production deployment.
- Change all demonstration passwords before using the system in a real environment.
- Do not use these accounts to store real organizational information.
- The Manager account represents a department manager in the sample data.



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
- Demonstration departments and employee records are available when the demo seed is imported.
- The four demonstration accounts can authenticate successfully.
- Each account has the expected role and permissions.
- Role-based access and dashboard redirection work as expected.
- Strategic goals, tasks, KPIs, budgets, and risk records are displayed correctly.


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

