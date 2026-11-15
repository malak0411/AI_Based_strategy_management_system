
# 3. API Specification

## 3.1 Introduction

The system provides a REST API implemented using Python FastAPI.

The API acts as the communication interface between the Laravel web application and the backend services.

It provides endpoints for authentication, strategic management, task management, employees, departments, KPIs, budgets, risks, reporting, and AI services.

## 3.2 Base URL

Default local development URL:

`http://127.0.0.1:8200`

API documentation:

`http://127.0.0.1:8200/docs`

Alternative documentation:

`http://127.0.0.1:8200/redoc`

Health endpoint:

`GET /health`

## 3.3 Request and Response Format

The API uses JSON for standard request and response bodies.

The client should send:

```http
Accept: application/json
Content-Type: application/json
```

Authenticated requests must include a bearer token:

```http
Authorization: Bearer <access_token>
```

## 3.4 Authentication

Base path:

`/api/auth`

Available endpoints:

| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/auth/login` | Authenticate an employee. |
| GET | `/api/auth/me` | Retrieve the authenticated employee information. |
| POST | `/api/auth/forgot-password` | Request password reset. |
| POST | `/api/auth/change-password` | Change the authenticated employee password. |

### Login Request

```json
{
  "email": "employee@example.com",
  "password": "your-password"
}
```

### Successful Login Response

```json
{
  "success": true,
  "data": {
    "access_token": "ACCESS_TOKEN",
    "token_type": "bearer",
    "employee_id": 1,
    "full_name": "Employee Name",
    "email": "employee@example.com",
    "department_id": 1,
    "department_name": "Department",
    "roles": [],
    "is_active": true
  }
}
```

The token must be stored securely by the client and sent with subsequent authenticated requests.

## 3.5 Strategic Management

Base path:

`/api/strategic`

Main operations include:

- Retrieve strategic pillars.
- Retrieve and update strategic goals.
- Manage programs.
- Manage initiatives.
- Retrieve initiative major tasks.
- Manage strategic vision.
- Retrieve and update SWOT information.
- Retrieve and update PESTEL information.

Example endpoints:

| Method | Endpoint |
|---|---|
| GET | `/api/strategic/pillars` |
| GET | `/api/strategic/goals` |
| GET | `/api/strategic/programs` |
| GET | `/api/strategic/initiatives` |
| GET | `/api/strategic/vision` |
| GET | `/api/strategic/swot` |
| GET | `/api/strategic/pestel` |

## 3.6 Task Management

Base path:

`/api/tasks`

Main operations include:

- Retrieve employee tasks.
- Retrieve departmental tasks.
- Retrieve delayed tasks.
- Retrieve major tasks.
- Create and update tasks.
- Manage task assignments.
- Manage task dependencies.
- Manage task comments.
- Upload and retrieve attachments.
- Retrieve progress logs.
- Send tasks for review.
- Request task prediction and analysis.

Example endpoints:

| Method | Endpoint |
|---|---|
| GET | `/api/tasks/my-tasks` |
| GET | `/api/tasks/department` |
| GET | `/api/tasks/all` |
| GET | `/api/tasks/delayed` |
| POST | `/api/tasks/` |
| PUT | `/api/tasks/{task_id}` |
| GET | `/api/tasks/{task_id}/assignments` |
| POST | `/api/tasks/{task_id}/assign` |
| GET | `/api/tasks/{task_id}/comments` |
| POST | `/api/tasks/{task_id}/comments` |
| GET | `/api/tasks/{task_id}/progress-logs` |
| PATCH | `/api/tasks/{task_id}/send-to-review` |

## 3.7 Employee and Department Management

Employee base path:

`/api/employees`

Department base path:

`/api/departments`

These services support employee records, department information, and employee-related task statistics.

## 3.8 Dashboard Services

Base path:

`/api/dashboard`

Main dashboard operations include:

- Employee dashboard.
- Manager dashboard.
- Ministry leadership dashboard.
- Department performance.
- Task assignment acceptance and rejection.

## 3.9 KPI Management

Base path:

`/api/kpis`

The API supports:

- KPI retrieval.
- KPI creation and modification.
- KPI deletion.
- KPI measurement creation.
- Measurement history.
- Measurement chart data.

## 3.10 Budget Management

Base path:

`/api/budget`

The API supports:

- Budget options.
- Budget summaries.
- Budget hierarchy.
- Budget records.
- Budget transactions.
- Transaction approvals and rejection.

## 3.11 Risk Management

Base path:

`/api/risks`

The API supports:

- Risk retrieval.
- Risk creation and modification.
- Risk deletion.
- Risk mitigation management.
- Automatic task-related risk detection.
- Risk reassessment.
- AI-assisted recommendations.

## 3.12 AI Services

Base path:

`/api/ai`

### Operational Task Generation

| Method | Endpoint |
|---|---|
| POST | `/api/ai/operational/generate-tasks/{major_task_id}` |
| POST | `/api/ai/operational/edit-tasks/{job_id}` |
| PUT | `/api/ai/operational/tasks/{job_id}` |
| POST | `/api/ai/operational/approve-tasks/{job_id}` |

### Strategic Task Generation

| Method | Endpoint |
|---|---|
| POST | `/api/ai/strategic/generate-major-tasks/{initiative_id}` |
| GET | `/api/ai/strategic/strategic-map/{initiative_id}` |
| POST | `/api/ai/strategic/edit-tasks/{job_id}` |
| PUT | `/api/ai/strategic/tasks/{job_id}` |
| POST | `/api/ai/strategic/approve-tasks/{job_id}` |

### Delay Prediction and Risk Recommendations

| Method | Endpoint |
|---|---|
| GET | `/api/ai/predict-delay/{task_id}` |
| GET | `/api/ai/predict-all-delays` |
| POST | `/api/ai/predict-and-detect/{task_id}` |
| GET | `/api/ai/recommendations/{task_id}` |
| POST | `/api/ai/risk/{risk_id}/recommendations` |
| POST | `/api/ai/risk/{risk_id}/reassess` |
| GET | `/api/ai/risk/{risk_id}/ai-recommendations` |

### AI Job and Model Operations

The AI router also provides job monitoring, scheduler operations, model status, and training-related endpoints.

Refer to the live Swagger documentation for the exact request parameters and response schemas.

## 3.13 Reports

Base path:

`/api/reports`

The reporting API includes:

- Dashboard reports.
- Strategic reports.
- Budget reports.
- Risk reports.
- KPI reports.
- Department reports.
- Employee reports.
- Task reports.

## 3.14 Authorization

The system uses JWT bearer authentication and permission-based authorization.

A valid token identifies the authenticated employee.

Access to protected operations must be determined by the permissions assigned to that employee.

A role name alone should not be treated as proof of authorization.

## 3.15 Error Handling

The API uses standard HTTP status codes.

| Status | Meaning |
|---|---|
| 200 | Request completed successfully. |
| 201 | Resource created, where applicable. |
| 400 | Invalid request or business validation error. |
| 401 | Missing, invalid, or expired authentication. |
| 403 | Access denied or inactive account. |
| 404 | Requested resource not found. |
| 422 | Request validation error. |
| 500 | Internal server error. |

## 3.16 API Reference

The live API documentation is the authoritative source for endpoint parameters, schemas, and response details:

`/docs`

This document summarizes the API groups and selected routes. It is not a replacement for the generated OpenAPI specification.

