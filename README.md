
# AI-Based Strategy Management System

An AI-Based Strategy Management System designed to support government strategic planning, execution, monitoring, and evaluation.

The system provides an integrated environment for connecting strategic objectives with programs, initiatives, major tasks, and operational tasks. It also supports performance monitoring, risk management, budget tracking, and AI-assisted task planning.

## Project Context

The project was developed in the context of the Yemen Ministry of Oil and Minerals.

The project uses a simulated strategy scenario based on the ministry context. The repository does not contain live ministry operational data and the system does not provide live integration with ministry information systems.

## Main Features

- Strategic vision, pillars, goals, programs, and initiatives management.
- Major task and operational task management.
- AI-assisted generation of strategic and operational tasks.
- Human review, editing, and approval of AI-generated tasks.
- Operational task assignment and progress tracking.
- Task delay prediction using an XGBoost-based model.
- Risk registration, detection, reassessment, and recommendations.
- KPI management and performance monitoring.
- Budget management and transaction tracking.
- Role- and permission-based access control.
- Employee-facing web interface.
- REST API for communication between the Laravel application and AI services.

## System Architecture

The system consists of three main layers:

### 1. Presentation Layer

- Laravel Blade web application.
- Web interface for administrators, employees, managers, and ministry leadership.

### 2. Application and AI Services Layer

- Laravel application services and controllers.
- Python FastAPI REST API.
- XGBoost delay prediction.
- Ollama-based language model services.
- Rule-based risk detection and reassessment.

### 3. Data Layer

- MySQL database.
- Strategic, operational, employee, budget, risk, KPI, and AI-related records.

## Technology Stack

| Component | Technology |
|---|---|
| Web application | Laravel 13 |
| Backend language | PHP 8.3 or later |
| Web interface | Blade |
| AI API | Python, FastAPI |
| Python server | Uvicorn |
| Database | MySQL |
| ORM | SQLAlchemy |
| Delay prediction | XGBoost |
| Language model service | Ollama |
| Frontend assets | Vite, Node.js, npm |

## Repository Structure

```text
AI_basedStrategy/
├── backend/
│   ├── app/
│   │   ├── api/
│   │   ├── ai/
│   │   ├── core/
│   │   └── models/
│   ├── models/
│   ├── uploads/
│   ├── requirements.txt
│   ├── run.py
│   └── .env.example
├── database/
│   ├── schema/
│   │   └── full_schema.sql
│   └── seeders/
│       └── data_seed.sql
├── docs/
│   ├── 01_Project_Overview.md
│   ├── 02_Database_Design.md
│   ├── 03_API_Specification.md
│   ├── 04_Deployment_Guide.md
│   └── 05_User_Manual.md
├── frontend/
│   ├── app/
│   ├── public/
│   ├── resources/
│   ├── routes/
│   ├── composer.json
│   └── package.json
├── .gitignore
├── INSTALLATION.md
└── README.md
```

## Requirements

- PHP 8.3 or later.
- Composer.
- Python 3.11 recommended.
- MySQL 8.0 or compatible version.
- Node.js 22 LTS and npm.
- Ollama, when AI language-model features are required.
- Git.

## Installation

For detailed installation instructions, see:

- [Installation Guide](INSTALLATION.md)
- [Project Overview](docs/01_Project_Overview.md)
- [Database Design](docs/02_Database_Design.md)
- [API Specification](docs/03_API_Specification.md)
- [Deployment Guide](docs/04_Deployment_Guide.md)
- [User Manual](docs/05_User_Manual.md)

## Service Addresses

Default local development addresses:

| Service | Address |
|---|---|
| Laravel Web Application | http://127.0.0.1:8000 |
| FastAPI | http://127.0.0.1:8200 |
| FastAPI Swagger UI | http://127.0.0.1:8200/docs |
| FastAPI Health Check | http://127.0.0.1:8200/health |
| Ollama | http://127.0.0.1:11434 |

These are default development addresses and may be changed through the deployment configuration.

## Database Setup

The application uses the existing `strategic_management_db` database structure.

Import the validated schema before importing the approved seed data.

Do not run Laravel migrations, `migrate:fresh`, or `db:wipe` as part of the initial installation. The database is initialized from the supplied SQL files.

The SQL files must be reviewed and populated with the approved clean schema and safe seed data before deployment.

## AI Models

The delay prediction service depends on the required model artifacts stored in `backend/models/`.

The Ollama service is used for language-model-assisted operations. The required model must be available locally before using features that depend on it.

## Security

- Never commit `.env` files.
- Never commit passwords, API keys, JWT secrets, or SMTP credentials.
- Do not publish real employee records or operational attachments.
- Use a unique secret key for each installation.
- Restrict API access to trusted origins and networks.
- Use HTTPS in production.

## Important Notes

- AI-generated content requires authorized human review and approval.
- AI predictions and recommendations should be treated as decision-support information.
- The repository does not claim independently validated model accuracy or production performance results.
- The system must be tested in the target deployment environment before operational use.

## License

Specify the applicable project license before public distribution.

