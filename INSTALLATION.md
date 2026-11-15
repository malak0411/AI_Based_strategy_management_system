
# Installation Guide

## 1. Overview

This guide explains how to install and run the AI-Based Strategy Management System on a new Windows development computer.

The system consists of:

- Laravel web application.
- Python FastAPI backend.
- MySQL database.
- XGBoost prediction model.
- Ollama language-model service.

## 2. Prerequisites

Install the following software before starting:

| Software | Required version |
|---|---|
| PHP | 8.3 or later |
| Composer | Current stable version |
| Python | 3.11 recommended |
| MySQL | 8.0 or compatible |
| Node.js | 22 LTS |
| npm | Included with Node.js |
| Git | Current stable version |
| Ollama | Required for language-model features |

PHP must have the extensions required by Laravel and the database driver enabled, including PDO MySQL, OpenSSL, Mbstring, Tokenizer, XML, Ctype, JSON, and Fileinfo.

## 3. Download the Project

Clone the repository:

```bash
git clone -b deployment-preparation https://github.com/malak0411/AI_basedStrategy.git
```

Enter the project directory:

```bash
cd AI_basedStrategy
```

## 4. Create the MySQL Database

Start MySQL using the installed MySQL server or XAMPP.

Open phpMyAdmin or a MySQL client.

Create a database named:

```sql
CREATE DATABASE strategic_management_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
```

Select the database and import the approved schema file:

`database/schema/full_schema.sql`

After the schema import succeeds, import:

`database/seeders/data_seed.sql`

Verify that the expected 40 tables and the required initial configuration records exist.

Important:

The repository SQL files must contain the approved clean schema and safe seed data before installation. Do not use the original operational database dump.

Do not run Laravel migrations or destructive database commands during initial installation.

## 5. Configure the Python Backend

Open a terminal:

```bash
cd backend
```

Create a virtual environment:

```bash
python -m venv .venv
```

Activate the environment:

```powershell
.venv\Scripts\activate
```

Create the environment file:

```powershell
copy .env.example .env
```

Open `backend/.env` and configure:

- Database host.
- Database port.
- Database username.
- Database password.
- Database name.
- JWT secret.
- Allowed web origins.
- Ollama address and model.
- SMTP settings if email functionality is required.

Generate a secure random JWT secret. Do not use the example placeholder.

Install Python dependencies:

```bash
python -m pip install --upgrade pip
pip install -r requirements.txt
```

Verify the required model files exist in:

`backend/models/`

Required delay prediction artifacts:

- `delay_model.pkl`
- `delay_feature_engineer.pkl`

## 6. Configure Ollama

Install Ollama and start the service.

Download the configured model:

```bash
ollama pull qwen2.5:3b
```

Verify installation:

```bash
ollama list
```

The default service address is:

`http://127.0.0.1:11434`

## 7. Start the Python Backend

From the `backend` directory, activate the virtual environment if it is not already active.

Start FastAPI:

```bash
uvicorn app.main:app --host 127.0.0.1 --port 8200
```

Open:

- API: http://127.0.0.1:8200
- Swagger: http://127.0.0.1:8200/docs
- Health: http://127.0.0.1:8200/health

Use a single worker while the application scheduler is initialized from the FastAPI startup event.

## 8. Configure the Laravel Application

Open another terminal:

```bash
cd frontend
```

Install Composer dependencies:

```bash
composer install
```

Create the environment file:

```powershell
copy .env.example .env
```

Configure the following values in `frontend/.env`:

- `APP_NAME`
- `APP_ENV`
- `APP_KEY`
- `APP_DEBUG`
- `APP_URL`
- `DB_CONNECTION`
- `DB_HOST`
- `DB_PORT`
- `DB_DATABASE`
- `DB_USERNAME`
- `DB_PASSWORD`
- `API_BASE_URL`

Use the FastAPI address reachable from the Laravel server.

For local development:

```dotenv
API_BASE_URL=http://127.0.0.1:8200
```

Generate the Laravel application key:

```bash
php artisan key:generate
```

Install JavaScript dependencies:

```bash
npm install
```

Build frontend assets:

```bash
npm run build
```

Clear cached configuration:

```bash
php artisan optimize:clear
```

## 9. Start Laravel

From the `frontend` directory:

```bash
php artisan serve --host=127.0.0.1 --port=8000
```

Open:

http://127.0.0.1:8000

## 10. Start the System

The services should be running in this order:

1. MySQL.
2. Ollama, when required.
3. FastAPI.
4. Laravel.

## 11. Initial Verification

Verify the following:

- The MySQL database is accessible.
- The required tables exist.
- The seed data is available.
- FastAPI responds to the health check.
- Laravel can communicate with FastAPI.
- The login page is accessible.
- Authentication works with a valid account.
- Required model files can be loaded.
- Ollama is available for features that depend on it.

## 12. Deployment on Another Computer

When the system is accessed from another computer:

- Configure the Laravel URL using the server's reachable IP address or hostname.
- Configure `API_BASE_URL` using the reachable FastAPI address.
- Add the Laravel origin to the FastAPI CORS allowlist.
- Configure firewall rules for the web and API ports.
- Do not expose MySQL or Ollama directly to untrusted networks.
- Use HTTPS for production deployments.

## 13. Important Warnings

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

The initial database is provided through the approved SQL schema and seed files.

Do not commit `.env` files, passwords, JWT secrets, real operational records, or uploaded attachments.

## 14. Troubleshooting

### MySQL connection failed

Check MySQL service status and database credentials.

### FastAPI does not start

Verify the virtual environment, installed requirements, and backend environment variables.

### Laravel cannot connect to the API

Verify `API_BASE_URL` and confirm that FastAPI is running.

### AI language model is unavailable

Verify Ollama is running and that the configured model has been downloaded.

### Delay prediction fails

Verify that the required model artifacts are present and compatible with the installed Python dependencies.

