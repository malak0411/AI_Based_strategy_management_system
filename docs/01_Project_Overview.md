
# 1. Project Overview

## 1.1 Introduction

The AI-Based Strategy Management System is a web-based platform designed to support the management of government strategies through an integrated digital environment.

The system aims to connect strategic planning with operational execution by organizing strategic objectives into programs, initiatives, major tasks, and operational tasks. It also provides tools for monitoring performance, managing risks, tracking budgets, and supporting management decisions through AI-assisted services.

The project was developed in the context of the Yemen Ministry of Oil and Minerals.

## 1.2 Background

Government institutions need a clear connection between their strategic direction and the activities performed by their departments.

When departments prepare work plans independently, it can become difficult to maintain alignment between daily activities and the institution's strategic objectives.

The system addresses this challenge by providing a structured strategic hierarchy and a centralized environment for managing responsibilities, activities, progress, and performance information.

## 1.3 Problem Statement

The main problem addressed by the project is the difficulty of maintaining a consistent relationship between institutional strategic objectives and departmental operational plans.

The absence of an integrated management environment may lead to:

- Fragmented departmental work plans.
- Weak alignment between operational activities and strategic goals.
- Difficulty monitoring task progress.
- Limited visibility into performance indicators.
- Challenges in identifying and reassessing risks.
- Difficulty tracking budget execution.
- Additional effort in preparing and reviewing work plans.

## 1.4 Project Objectives

The main objectives are:

1. Provide a centralized platform for managing institutional strategies.
2. Connect strategic goals with programs, initiatives, and tasks.
3. Support operational task assignment and progress monitoring.
4. Provide AI-assisted generation of strategic and operational tasks.
5. Support task delay prediction.
6. Improve risk monitoring and reassessment.
7. Support KPI and budget monitoring.
8. Provide role- and permission-based access control.
9. Improve access to strategic and operational information through dashboards and reports.

## 1.5 Scope

The project covers the following functional areas:

### Strategic Management

- Strategic vision management.
- Strategic pillars.
- Strategic goals.
- Programs.
- Initiatives.
- SWOT analysis.
- PESTEL analysis.

### Task Management

- Major task management.
- Operational task generation.
- Task assignment.
- Task dependencies.
- Progress tracking.
- Task review and approval.
- Attachments and comments.

### AI Services

- AI-assisted strategic task generation.
- AI-assisted operational task generation.
- Task delay prediction.
- Risk-related recommendations.
- AI job monitoring.

### Performance Management

- KPI management.
- KPI measurements.
- Performance dashboards.
- Departmental performance monitoring.

### Risk Management

- Risk registration.
- Risk detection.
- Risk reassessment.
- Mitigation management.
- Recommendations.

### Budget Management

- Budget records.
- Budget transactions.
- Transaction approvals.
- Budget monitoring.

### Administration

- Employee management.
- Department management.
- Roles and permissions.
- System configuration.
- Audit logs.
- Dictionary management.

## 1.6 Strategic Hierarchy

The system organizes strategic execution through the following hierarchy:

```text
Vision
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

KPIs are associated directly with strategic goals.

## 1.7 System Architecture

The system follows a layered architecture.

### Presentation Layer

The presentation layer provides the web interface using Laravel and Blade.

### Application and Service Layer

The application layer includes:

- Laravel controllers and services.
- FastAPI endpoints.
- Authentication and authorization.
- AI task generation.
- Delay prediction.
- Risk detection and reassessment.
- Reporting services.

### Data Layer

MySQL stores the system's strategic, operational, administrative, and monitoring information.

## 1.8 Artificial Intelligence Components

### Strategic Planner

Supports the generation of proposed major tasks based on strategic initiatives and available context.

### Operational Planner

Supports the decomposition of major tasks into smaller operational tasks.

### Delay Prediction

Uses an XGBoost-based classification model to estimate whether a task may be delayed.

### Risk Services

Support risk detection, reassessment, and recommendations using rule-based and AI-assisted approaches.

AI-generated outputs are proposals and require review and approval by authorized users.

## 1.9 User Categories

The system supports different access levels through roles and permissions.

The main user categories include:

- System administrators.
- Employees.
- Managers.
- Ministry leadership.

Access is determined by assigned permissions rather than relying only on a user's display role.

## 1.10 Project Data and Limitations

The project uses a simulated strategy scenario derived from the institutional context of the Yemen Ministry of Oil and Minerals.

The project does not claim to use live operational ministry records or to have a live connection with ministry systems.

The availability of a prediction model does not, by itself, establish its predictive accuracy. Formal model evaluation requires an appropriate real-world labeled dataset and documented evaluation procedures.

## 1.11 Expected Benefits

The system is intended to:

- Improve strategic alignment.
- Support coordinated departmental planning.
- Improve task visibility.
- Facilitate performance monitoring.
- Support early identification of potential delays and risks.
- Improve access to management information.
- Provide AI-assisted decision support.

## 1.12 Conclusion

The AI-Based Strategy Management System provides an integrated technical environment for connecting strategic planning with operational execution. By combining strategic management, task monitoring, performance measurement, risk management, and AI-assisted services, the system aims to support more coordinated and informed institutional management.

