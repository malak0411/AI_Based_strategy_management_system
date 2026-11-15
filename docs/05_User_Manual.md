
# 5. User Manual

## 5.1 Introduction

This manual explains the main functions of the AI-Based Strategy Management System and provides guidance for its different users.

The system provides an integrated environment for strategic management, operational task execution, performance monitoring, risk management, and budget tracking.

The available functions depend on the permissions assigned to the authenticated user.

## 5.2 Accessing the System

1. Open the system URL using a web browser.
2. Enter your registered email address.
3. Enter your password.
4. Select the login option.
5. After successful authentication, the system redirects you to the appropriate dashboard.

Users must have an active account to access the system.

## 5.3 User Roles and Permissions

The system supports different organizational responsibilities.

### System Administrator

The administrator may have permissions to:

- Manage employee accounts.
- Manage departments.
- Manage roles and permissions.
- Manage system configuration.
- Manage dictionaries.
- Review audit logs.

### Employee

Depending on assigned permissions, employees may:

- View assigned tasks.
- Review task details.
- Accept or reject assignments.
- Update task progress.
- Add comments.
- Upload task attachments.
- Submit tasks for review.

### Manager

Depending on assigned permissions, managers may:

- Monitor departmental tasks.
- Review task progress.
- Manage assignments.
- Monitor major and operational tasks.
- Review risks and performance information.
- Access permitted management dashboards.

### Ministry Leadership

Users with the required permissions may:

- View strategic dashboards.
- Monitor institutional performance.
- Review departmental performance.
- Access strategic and operational reports.
- Monitor major strategic indicators.

The available operations are controlled by permissions and may differ between users.

## 5.4 Dashboard

The dashboard provides a summary of information relevant to the authenticated user.

Depending on permissions, dashboard information may include:

- Task status.
- Task progress.
- Delayed tasks.
- Departmental performance.
- Strategic performance indicators.
- Risk information.
- Budget information.

## 5.5 Strategic Management

Authorized users can manage the strategic structure.

The hierarchy includes:

1. Strategic vision.
2. Strategic pillars.
3. Strategic goals.
4. Programs.
5. Initiatives.
6. Major tasks.
7. Operational tasks.

Users should maintain the relationships between these elements to support strategic alignment.

## 5.6 SWOT and PESTEL Analysis

Authorized users can access the strategic analysis functions.

### SWOT

SWOT analysis organizes information into:

- Strengths.
- Weaknesses.
- Opportunities.
- Threats.

### PESTEL

PESTEL analysis considers:

- Political factors.
- Economic factors.
- Social factors.
- Technological factors.
- Environmental factors.
- Legal factors.

The information should be reviewed and updated by authorized users.

## 5.7 Major Task Management

Major tasks represent significant activities associated with initiatives.

Authorized users can:

- View major tasks.
- Review task details.
- Create or update major tasks.
- Monitor related operational tasks.
- Review task progress.

## 5.8 Operational Task Management

Operational tasks represent smaller activities used to execute major tasks.

Authorized users can:

- Create operational tasks.
- Assign employees.
- Define task details.
- Manage task dependencies.
- Review progress.
- Add comments.
- Upload attachments.
- Monitor task status.

## 5.9 AI-Assisted Task Generation

The system provides AI-assisted functions for generating proposed tasks.

The general workflow is:

1. Select the relevant initiative or major task.
2. Start the AI generation operation.
3. Wait for the generation job to complete.
4. Review the generated content.
5. Edit or regenerate the proposal when necessary.
6. Approve the content through the authorized workflow.

AI-generated tasks must not be treated as approved operational instructions until an authorized user completes the approval process.

## 5.10 Task Assignment

Authorized users can assign tasks to employees.

Employees may receive assignment requests and perform the available assignment actions.

Assignment status and responsibility information should be reviewed before task execution.

## 5.11 Task Progress and Review

Employees update the progress of tasks according to their assigned responsibilities.

The operational workflow includes task execution and submission for review.

The responsible employee submits the task for review when the required work is ready.

Authorized reviewers inspect the submitted work and perform the available review actions.

## 5.12 Task Delay Prediction

The system provides an AI-based service for estimating potential task delays.

The prediction is intended to support monitoring and early management attention.

A prediction should be interpreted as decision-support information, not as a guaranteed outcome.

## 5.13 Risk Management

Authorized users can:

- View registered risks.
- Create and update risks.
- Review risk details.
- Manage mitigation actions.
- Review risk recommendations.
- Reassess risks when necessary.

AI-assisted recommendations should be reviewed before being used in management decisions.

## 5.14 KPI Management

Authorized users can:

- View KPIs.
- Create or update KPI definitions.
- Record measurements.
- Review measurement history.
- View available performance charts.

KPIs are associated with strategic goals.

## 5.15 Budget Management

Authorized users can:

- View budget information.
- Review budget allocation.
- View transactions.
- Create transactions where permitted.
- Submit transactions for approval.
- Review approval status.

Budget operations depend on the user's assigned permissions.

## 5.16 Reports

The system provides reports for different management areas, including:

- Strategic management.
- Tasks.
- Employees.
- Departments.
- KPIs.
- Budgets.
- Risks.

The available reports depend on the user's access permissions.

## 5.17 Profile and Password Management

Users should protect their account credentials.

Available account operations may include:

- Viewing profile information.
- Changing the password.
- Requesting password recovery through the configured email service.
- Logging out.

Users should never share their passwords or authentication tokens.

## 5.18 Attachments and Comments

Where permitted, users can attach supporting files to operational tasks and add comments.

Users should upload only files relevant to the task and follow their organization's information-security requirements.

## 5.19 Troubleshooting

### Unable to log in

- Verify the email address.
- Verify the password.
- Check whether the account is active.
- Contact the system administrator if the issue continues.

### API connection error

- Verify that the FastAPI service is running.
- Verify the configured API base URL.
- Verify network access and firewall settings.

### AI generation is unavailable

- Verify that the FastAPI service is running.
- Verify Ollama availability when the requested feature uses it.
- Verify that the required AI model is installed.
- Review the application logs.

### Database connection error

- Verify that MySQL is running.
- Verify the database name.
- Verify database credentials.
- Verify network access to the database server.

## 5.20 Security Recommendations

- Use a strong password.
- Do not share account credentials.
- Log out after completing work on shared devices.
- Upload only authorized files.
- Review task information before approval.
- Treat AI-generated content as a proposal requiring human review.

## 5.21 Conclusion

This manual provides an overview of the main system operations. Users should perform only the operations permitted by their assigned permissions and follow their organization's administrative and information-security procedures.

