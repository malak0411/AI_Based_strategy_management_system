
from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Employee
from app.core.dependencies import get_current_employee


def require_permission(*permission_names: str):

    if not permission_names:
        raise ValueError("At least one permission is required")

    if any(
        not isinstance(name, str) or not name.strip()
        for name in permission_names
    ):
        raise ValueError("Invalid permission name")

    required_permissions = set(permission_names)

    def permission_checker(
        employee_id: int = Depends(get_current_employee),
        db: Session = Depends(get_db)
    ) -> int:

        employee = db.query(Employee).filter(
            Employee.employee_id == employee_id,
            Employee.is_active == True
        ).first()

        if employee is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Employee account is unavailable"
            )

        granted_permissions = {
            permission.name
            for role in employee.roles
            for permission in role.permissions
        }

        if not required_permissions.intersection(granted_permissions):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to perform this action"
            )

        return employee_id

    return permission_checker
