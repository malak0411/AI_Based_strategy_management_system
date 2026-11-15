
# 4. Deployment Guide

## 4.1 Introduction

This document describes the deployment requirements and service configuration for the AI-Based Strategy Management System.

The system consists of a Laravel web application, a FastAPI backend, a MySQL database, and AI services.

## 4.2 Deployment Components

The deployment environment requires:

- PHP 8.3 or later.
- Composer.
- Python 3.11.
- MySQL.
- Node.js and npm.
- Ollama for language-model features.
- The required XGBoost model artifacts.

## 4.3 Environment Configuration

The project uses separate environment files for the Laravel and Python services.

### Laravel

Create the local environment file from:

`frontend/.env.example`

Configure:

- Application URL.
- Application key.
- MySQL connection.
- FastAPI base URL.
- Session storage.
- Cache storage.
- Application debug mode.

### FastAPI

Create the local environment file from:

`backend/.env.example`

Configure:

- MySQL connection.
- JWT secret.
- Allowed web origins.
- Debug mode.
- AI model directory.
- Ollama address and model.
- SMTP settings, when email functionality is required.

Do not commit the generated `.env` files.

## 4.4 Database Deployment

Create a MySQL database named:

`strategic_management_db`

Import the approved SQL files in this order:

1. Database schema.
2. Approved seed data.

Verify that the expected 40 tables are available and that the initial configuration records have been imported.

Do not import operational data from the original development database.

Do not run destructive database commands.

Do not run Laravel migrations as a substitute for the approved database schema.

## 4.5 Python Backend Deployment

Open a terminal in the `backend` directory.

Create a virtual environment:

```bash
python -m venv .venv
```

Activate it on Windows:

```powershell
.venv\Scripts\activate
```

Activate it on Linux or macOS:

```bash
source .venv/bin/activate
```

Install dependencies:

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

Start the API:

```bash
uvicorn app.main:app --host 127.0.0.1 --port 8200
```

For access from other devices on a trusted local network, configure the host and firewall appropriately.

The scheduler currently starts during application startup. Until scheduler execution is made safe for multiple processes, run only one FastAPI worker.

## 4.6 Ollama Deployment

Install and start Ollama.

Download the configured language model:

```bash
ollama pull qwen2.5:3b
```

Verify that the model is available:

```bash
ollama list
```

The default Ollama service address is:

`http://127.0.0.1:11434`

AI language-model features require the Ollama service and configured model to be available.

## 4.7 Laravel Deployment

Open a terminal in the `frontend` directory.

Install PHP dependencies:

```bash
composer install
```

Create the environment file if it does not exist:

```bash
copy .env.example .env
```

Generate the application key:

```bash
php artisan key:generate
```

Install frontend dependencies:

```bash
npm install
```

Build frontend assets:

```bash
npm run build
```

Clear cached Laravel configuration after changing environment variables:

```bash
php artisan optimize:clear
```

Start the web application:

```bash
php artisan serve --host=127.0.0.1 --port=8000
```

Do not execute `php artisan migrate`, `php artisan migrate:fresh`, or `php artisan db:wipe` during initial deployment.

## 4.8 Service Startup Order

The recommended startup order is:

1. MySQL.
2. Ollama, when AI language-model functionality is required.
3. FastAPI backend.
4. Laravel web application.

## 4.9 Network Configuration

When the application is accessed from another device:

- Configure the Laravel application URL using an address reachable by the client.
- Configure the Laravel API base URL to point to the reachable FastAPI address.
- Configure FastAPI allowed origins to include the actual Laravel origin.
- Configure firewall rules for the required ports.
- Do not expose MySQL or Ollama publicly.
- Use HTTPS and appropriate access restrictions in production.

## 4.10 File Storage

The backend upload directory is:

`backend/uploads/`

The directory must exist and be writable by the application process.

The repository should contain only an empty `.gitkeep` file in the upload directory. Actual attachments must be stored outside the public source repository.

Back up uploaded files separately when operational attachments must be retained.

## 4.11 Security Checklist

Before deployment:

- Generate a unique JWT secret.
- Generate a Laravel application key.
- Set debug mode to false in production.
- Use strong MySQL credentials.
- Configure trusted CORS origins.
- Protect uploaded files.
- Restrict access to API documentation where required.
- Configure HTTPS.
- Protect SMTP credentials.
- Remove development secrets from source control.
- Review application logs for sensitive information.

## 4.12 AI Model Files

The delay prediction service requires its model and feature-engineering artifacts.

Verify the required files before starting the AI prediction service.

Do not treat empty or placeholder model files as valid artifacts.

## 4.13 Verification

After starting the services, verify:

### FastAPI

Open:

`http://127.0.0.1:8200/health`

### API Documentation

Open:

`http://127.0.0.1:8200/docs`

### Laravel

Open:

`http://127.0.0.1:8000`

### Database

Verify that the application can connect to MySQL and retrieve the expected initial configuration data.

### AI Services

Verify that Ollama is available and that the required model artifacts can be loaded.

## 4.14 Backup and Recovery

Back up the following separately:

- MySQL database.
- Required AI model artifacts.
- Uploaded task attachments.
- Environment configuration, stored securely outside the repository.

Test database restoration before relying on a backup.

## 4.15 Deployment Limitations

The deployment process must be tested on the actual target operating system.

The use of simulated project data does not establish production readiness.

Performance, security, and multi-user deployment behavior require separate validation.

