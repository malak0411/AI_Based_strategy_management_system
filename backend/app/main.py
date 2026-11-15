
from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.core.dependencies import get_current_employee

from app.api.routers import (
    auth,
    strategic,
    tasks,
    dashboard,
    employees,
    budget,
    risks,
    kpis,
    reports,
)

from app.api.routers import (
    system_config,
    admin,
    location,
    departments as dept_routes,
)

from app.api.routers import dict_router
from app.api.routers import audit_log as audit_log_router

from app.ai.routers.ai_router import router as ai_router


app = FastAPI(
    title="AI Strategy Management System",
    description="نظام إدارة الاستراتيجية الحكومي المعتمد على الذكاء الاصطناعي - وزارة النفط والمعادن",
    version="2.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)


app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type", "Accept"]
)


app.include_router(auth.router)

protected_dependencies = [
    Depends(get_current_employee)
]


app.include_router(
    strategic.router,
    dependencies=protected_dependencies
)

app.include_router(
    tasks.router,
    dependencies=protected_dependencies
)

app.include_router(
    dashboard.router,
    dependencies=protected_dependencies
)

app.include_router(
    employees.router,
    dependencies=protected_dependencies
)

app.include_router(
    budget.router,
    dependencies=protected_dependencies
)

app.include_router(
    risks.router,
    dependencies=protected_dependencies
)

app.include_router(
    kpis.router,
    dependencies=protected_dependencies
)

app.include_router(
    system_config.router,
    dependencies=protected_dependencies
)

app.include_router(
    admin.router,
    dependencies=protected_dependencies
)

app.include_router(
    location.router,
    dependencies=protected_dependencies
)

app.include_router(
    dept_routes.router,
    dependencies=protected_dependencies
)

app.include_router(
    dict_router.router,
    dependencies=protected_dependencies
)

app.include_router(
    ai_router,
    dependencies=protected_dependencies
)

app.include_router(
    reports.router,
    dependencies=protected_dependencies
)

app.include_router(
    audit_log_router.router,
    dependencies=protected_dependencies
)


@app.get("/")
async def root():
    return {
        "message": "AI Strategy Management System API",
        "version": "2.0.0",
        "status": "running",
        "docs": "/docs"
    }


@app.get("/health")
async def health_check():
    return {
        "status": "healthy"
    }


@app.on_event("startup")
async def startup_event():
    from app.ai.services.scheduler import ai_scheduler

    ai_scheduler.start()
    print("تم بدء جدولة AI التلقائية")

