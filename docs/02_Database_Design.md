
# 2. Database Design

## 2.1 Introduction

The system uses MySQL as its primary relational database management system.

The database is designed to store strategic planning information, operational tasks, employee records, assignments, performance indicators, budget information, risks, and AI-related records.

The database name used by the application is:

`strategic_management_db`

## 2.2 Database Structure

The approved database schema contains 40 tables.

The tables are organized into functional groups according to the responsibilities of the system.

The main functional groups are:

1. Strategic planning.
2. Programs and initiatives.
3. Major and operational tasks.
4. Task assignments and dependencies.
5. Employees and departments.
6. Roles and permissions.
7. Performance indicators.
8. Budget management.
9. Risk management.
10. AI jobs, predictions, and recommendations.
11. System configuration and dictionaries.
12. Monitoring and audit records.

The exact table names, column definitions, indexes, and foreign-key relationships must be taken from the approved SQL schema.

## 2.3 Strategic Data Model

The strategic management structure follows this hierarchy:

```text
Strategic Vision
      |
Strategic Pillars
      |
Strategic Goals
      |
Programs
      |
Initiatives
      |
Major Tasks
      |
Operational Tasks
```

This structure supports the relationship between institutional strategy and operational execution.

KPIs are linked directly to strategic goals through the goal-to-KPI relationship.

## 2.4 Employee and Organizational Data

The database stores organizational information required by the system, including:

- Employees.
- Departments.
- Roles.
- Permissions.
- Employee-role assignments.
- Role-permission assignments.

The authorization model is permission-based.

A user may have additional permissions depending on assigned responsibilities. Therefore, access to a function should be determined by the permissions assigned to the authenticated user.

## 2.5 Task Management Data

Task-related records support:

- Major tasks.
- Operational tasks.
- Task assignments.
- Assignment roles.
- Task dependencies.
- Task progress logs.
- Task comments.
- Task attachments.
- Task status tracking.

Task dependencies support the following relationship types:

- Finish-to-Start (FS).
- Start-to-Start (SS).
- Finish-to-Finish (FF).
- Start-to-Finish (SF).

Assignments include responsibility information and assignment status.

## 2.6 KPI Data

KPI-related records support:

- KPI definitions.
- Strategic goal relationships.
- KPI measurements.
- Measurement history.
- Performance reporting.

KPIs are associated directly with strategic goals rather than being linked through programs or initiatives.

## 2.7 Budget Data

Budget-related information supports:

- Budget allocation.
- Budget lines.
- Transactions.
- Approval operations.
- Budget monitoring.

Budget lines may be associated with different supported business entities.

Budget status is determined according to the relationship between allocated and spent amounts.

## 2.8 Risk Management Data

Risk-related records support:

- Risk registration.
- Risk classification.
- Risk status.
- Risk mitigation.
- Reassessment.
- Recommendations.

The system supports rule-based risk detection and reassessment services.

## 2.9 AI Data

AI-related records support the tracking of:

- AI jobs.
- Prediction records.
- AI recommendations.
- Model-related operations.

These records help maintain the relationship between AI processing requests and their results.

## 2.10 Database Constraints and Relationships

The database uses relational constraints to maintain data integrity.

The approved schema includes:

- Primary keys.
- Foreign-key relationships.
- Indexes.
- Database triggers.
- Supported table engines.

The clean schema reference includes two triggers.

The existing schema contains 33 InnoDB tables and 7 MyISAM tables. Their engines must not be changed without a separate database migration and compatibility assessment.

## 2.11 Database Initialization

The database must be initialized using the approved SQL files.

The required order is:

1. Create the database `strategic_management_db`.
2. Import the clean schema.
3. Import the approved seed data.
4. Verify the required tables and initial records.
5. Configure the application database credentials.

The seed data is intended to provide the initial system configuration and dictionary records.

The approved seed package contains data for eight tables and 159 records.

Do not use the original operational database dump as a public deployment seed.

## 2.12 Important Database Rules

- Do not rename existing tables.
- Do not rename existing columns.
- Do not remove existing relationships.
- Do not change table engines.
- Do not execute destructive initialization commands.
- Do not run Laravel migrations against the initialized database unless a separately reviewed migration plan explicitly requires them.
- Keep database credentials outside source control.

## 2.13 Database Documentation Source

The final database documentation must be synchronized with the approved clean SQL schema.

The repository's SQL files must contain the actual validated schema and seed data. Empty or placeholder SQL files are not valid deployment artifacts.

