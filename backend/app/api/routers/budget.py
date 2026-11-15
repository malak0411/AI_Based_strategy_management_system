from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import func, desc
from typing import Optional
from datetime import datetime
import logging
from app.models import (
    BudgetLine, BudgetTransaction, DictTransactionType,
    OperationalTask, MajorTask, Initiative, Program,
    StrategicGoal, StrategicPillar, Department, Employee, DictStatus
)
from app.core.dependencies import get_current_user
from app.database import get_db


router = APIRouter(prefix="/api/budget", tags=["Budget"])
logger = logging.getLogger("budget")


STATUS_PROGRAM_ACTIVE = 47
STATUS_INITIATIVE_ACTIVE = 2
STATUS_OPTASK_ACTIVE = 6


APPROVAL_THRESHOLD = 100000.0


PARENT_TYPE_MAP = {
    "initiative": "program",
    "major_task": "initiative",
    "operational_task": "major_task",
}




def _get_item_and_status(db: Session, budgetable_type: str, budgetable_id: int):
    if budgetable_type == "program":
        item = db.query(Program).filter(Program.program_id == budgetable_id).first()
        return item, item.status_id if item else None


    if budgetable_type == "initiative":
        item = db.query(Initiative).filter(Initiative.initiative_id == budgetable_id).first()
        return item, item.status_id if item else None


    if budgetable_type == "major_task":
        item = db.query(MajorTask).filter(MajorTask.major_task_id == budgetable_id).first()
        if not item:
            return None, None
        init = db.query(Initiative).filter(Initiative.initiative_id == item.initiative_id).first()
        return item, init.status_id if init else None


    if budgetable_type == "operational_task":
        item = db.query(OperationalTask).filter(OperationalTask.task_id == budgetable_id).first()
        return item, item.status_id if item else None


    return None, None




def _is_editable(budgetable_type: str, status_id):
    if budgetable_type == "program":
        return status_id == STATUS_PROGRAM_ACTIVE
    if budgetable_type == "initiative":
        return status_id == STATUS_INITIATIVE_ACTIVE
    if budgetable_type == "major_task":
        return status_id == STATUS_INITIATIVE_ACTIVE
    if budgetable_type == "operational_task":
        return status_id == STATUS_OPTASK_ACTIVE
    return False




def _resolve_parent_id(db: Session, budgetable_type: str, budgetable_id: int, fiscal_year: int):
    if budgetable_type == "program":
        return None


    parent_type = PARENT_TYPE_MAP.get(budgetable_type)
    if not parent_type:
        return None


    if budgetable_type == "initiative":
        init = db.query(Initiative).filter(Initiative.initiative_id == budgetable_id).first()
        parent_obj_id = init.program_id if init else None
    elif budgetable_type == "major_task":
        mt = db.query(MajorTask).filter(MajorTask.major_task_id == budgetable_id).first()
        parent_obj_id = mt.initiative_id if mt else None
    elif budgetable_type == "operational_task":
        ot = db.query(OperationalTask).filter(OperationalTask.task_id == budgetable_id).first()
        parent_obj_id = ot.major_task_id if ot else None
    else:
        parent_obj_id = None


    if not parent_obj_id:
        return None


    parent_bl = db.query(BudgetLine).filter(
        BudgetLine.budgetable_type == parent_type,
        BudgetLine.budgetable_id == parent_obj_id,
        BudgetLine.fiscal_year == fiscal_year,
    ).first()


    return parent_bl.budget_id if parent_bl else None




def _recalc_spent(db: Session, budget_line: BudgetLine):
    spent = db.query(func.coalesce(func.sum(BudgetTransaction.amount), 0)).filter(
        BudgetTransaction.budget_id == budget_line.budget_id,
        BudgetTransaction.transaction_type_id == 2,
        BudgetTransaction.approved_at.isnot(None),
    ).scalar() or 0


    refunded = db.query(func.coalesce(func.sum(BudgetTransaction.amount), 0)).filter(
        BudgetTransaction.budget_id == budget_line.budget_id,
        BudgetTransaction.transaction_type_id == 3,
        BudgetTransaction.approved_at.isnot(None),
    ).scalar() or 0


    budget_line.spent_amount = float(spent) - float(refunded)




def _available_to_allocate(db: Session, parent_budget_id: Optional[int], fiscal_year: int):
    if not parent_budget_id:
        return None


    parent = db.query(BudgetLine).filter(BudgetLine.budget_id == parent_budget_id).first()
    if not parent:
        return None


    children = db.query(BudgetLine).filter(
        BudgetLine.parent_budget_id == parent_budget_id,
        BudgetLine.fiscal_year == fiscal_year,
    ).all()
    allocated_to_children = sum(float(c.allocated_amount) for c in children)


    parent_allocated = float(parent.allocated_amount)
    parent_spent = float(parent.spent_amount)
    available = parent_allocated - parent_spent - allocated_to_children


    return {
        "parent_budget_id": parent_budget_id,
        "parent_allocated": parent_allocated,
        "parent_spent": parent_spent,
        "already_allocated_to_children": allocated_to_children,
        "available_to_allocate": max(0, available),
    }




def _rollup_totals(node: dict):
    total_alloc = node.get("direct_allocated", 0) + sum(
        c.get("total_allocated", c.get("direct_allocated", 0))
        for c in node.get("_children", [])
    )
    total_spent = node.get("direct_spent", 0) + sum(
        c.get("total_spent", c.get("direct_spent", 0))
        for c in node.get("_children", [])
    )
    node["total_allocated"] = total_alloc
    node["total_spent"] = total_spent
    node["total_remaining"] = total_alloc - total_spent




def _get_budget_item_display(db: Session, bl: BudgetLine):
    item_name = "غير معروف"
    hierarchy = ""
    item, status_id = _get_item_and_status(db, bl.budgetable_type, bl.budgetable_id)
    if not item:
        return item_name, hierarchy, status_id


    if bl.budgetable_type == "operational_task":
        item_name = item.title
        mt = db.query(MajorTask).filter(MajorTask.major_task_id == item.major_task_id).first()
        if mt:
            init = db.query(Initiative).filter(Initiative.initiative_id == mt.initiative_id).first()
            if init:
                prog = db.query(Program).filter(Program.program_id == init.program_id).first()
                hierarchy = f"{prog.name if prog else ''} / {init.name} / {mt.name}"


    elif bl.budgetable_type == "major_task":
        item_name = item.name
        init = db.query(Initiative).filter(Initiative.initiative_id == item.initiative_id).first()
        if init:
            prog = db.query(Program).filter(Program.program_id == init.program_id).first()
            hierarchy = f"{prog.name if prog else ''} / {init.name}"


    elif bl.budgetable_type == "initiative":
        item_name = item.name
        prog = db.query(Program).filter(Program.program_id == item.program_id).first()
        hierarchy = f"{prog.name if prog else ''}"


    elif bl.budgetable_type == "program":
        item_name = item.name
        hierarchy = "برنامج استراتيجي"


    return item_name, hierarchy, status_id




@router.get("/options")
async def get_budget_options(
    employee_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    departments = db.query(Department).filter(Department.is_active == True).all()
    transaction_types = db.query(DictTransactionType).all()
    years = db.query(BudgetLine.fiscal_year).distinct().all()


    return {
        "departments": [{"id": d.department_id, "name": d.name} for d in departments],
        "transaction_types": [
            {"id": tt.trans_type_id, "name": tt.name_ar, "sign": tt.sign}
            for tt in transaction_types
        ],
        "fiscal_years": sorted([y[0] for y in years if y[0]]),
    }




@router.get("/available")
async def get_available_to_allocate(
    budgetable_type: str = Query(...),
    budgetable_id: int = Query(...),
    fiscal_year: int = Query(...),
    employee_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    parent_id = _resolve_parent_id(db, budgetable_type, budgetable_id, fiscal_year)
    info = _available_to_allocate(db, parent_id, fiscal_year)


    if info is None:
        return {
            "is_top_level": True,
            "available_to_allocate": None,
            "message": "بند على المستوى الأعلى — لا يوجد أب للتحقق",
        }


    return {"is_top_level": False, **info}




@router.get("/summary")
async def get_budget_summary(
    fiscal_year: Optional[int] = Query(None),
    employee_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    q_budget = db.query(BudgetLine)
    if fiscal_year:
        q_budget = q_budget.filter(BudgetLine.fiscal_year == fiscal_year)
    budgets = q_budget.all()


    total_allocated = sum(float(b.allocated_amount) for b in budgets if b.budgetable_type == "program")
    total_spent = sum(float(b.spent_amount) for b in budgets if b.budgetable_type == "program")
    total_remaining = total_allocated - total_spent
    execution_pct = (total_spent / total_allocated * 100) if total_allocated > 0 else 0
    overspent_count = sum(1 for b in budgets if float(b.spent_amount) > float(b.allocated_amount))
    transactions_count = db.query(BudgetTransaction).count()


    pending_approvals = db.query(BudgetTransaction).filter(
        BudgetTransaction.approved_at.is_(None),
        BudgetTransaction.amount >= APPROVAL_THRESHOLD,
    ).count()


    return {
        "total_programs": db.query(Program).count(),
        "total_allocated": total_allocated,
        "total_spent": total_spent,
        "total_remaining": total_remaining,
        "execution_percentage": round(execution_pct, 2),
        "overspent_count": overspent_count,
        "transactions_count": transactions_count,
        "pending_approvals": pending_approvals,
    }




@router.get("/hierarchy")
async def get_budget_hierarchy(
    fiscal_year: Optional[int] = Query(None),
    employee_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    q_budget = db.query(BudgetLine)
    if fiscal_year:
        q_budget = q_budget.filter(BudgetLine.fiscal_year == fiscal_year)
    budgets = q_budget.all()


    budget_map = {(b.budgetable_type, b.budgetable_id): b for b in budgets}


    programs = db.query(Program).all()
    initiatives = db.query(Initiative).all()
    major_tasks = db.query(MajorTask).all()
    op_tasks = db.query(OperationalTask).all()


    goals = {g.goal_id: g for g in db.query(StrategicGoal).all()}
    pillars = {p.pillar_id: p for p in db.query(StrategicPillar).all()}
    depts = {d.department_id: d for d in db.query(Department).all()}


    inits_by_prog = {}
    for i in initiatives:
        inits_by_prog.setdefault(i.program_id, []).append(i)


    mts_by_init = {}
    for mt in major_tasks:
        mts_by_init.setdefault(mt.initiative_id, []).append(mt)


    ots_by_mt = {}
    for ot in op_tasks:
        ots_by_mt.setdefault(ot.major_task_id, []).append(ot)


    def _budget_info(btype, bid):
        b = budget_map.get((btype, bid))
        if not b:
            return 0.0, 0.0, None
        return float(b.allocated_amount), float(b.spent_amount), b.budget_id


    tree = []
    for p in programs:
        p_alloc, p_spent, p_bid = _budget_info("program", p.program_id)


        p_inits = []
        for i in inits_by_prog.get(p.program_id, []):
            i_alloc, i_spent, i_bid = _budget_info("initiative", i.initiative_id)


            i_mts = []
            for mt in mts_by_init.get(i.initiative_id, []):
                mt_alloc, mt_spent, mt_bid = _budget_info("major_task", mt.major_task_id)


                mt_ots = []
                for ot in ots_by_mt.get(mt.major_task_id, []):
                    ot_alloc, ot_spent, ot_bid = _budget_info("operational_task", ot.task_id)


                    mt_ots.append({
                        "id": ot.task_id,
                        "name": ot.title,
                        "status_id": ot.status_id,
                        "department_name": depts.get(ot.department_id).name if ot.department_id and depts.get(ot.department_id) else "غير محدد",
                        "direct_allocated": ot_alloc,
                        "direct_spent": ot_spent,
                        "total_allocated": ot_alloc,
                        "total_spent": ot_spent,
                        "total_remaining": ot_alloc - ot_spent,
                        "budget_id": ot_bid,
                        "can_allocate": ot.status_id == STATUS_OPTASK_ACTIVE and ot_bid is None,
                    })


                node_mt = {
                    "id": mt.major_task_id,
                    "name": mt.name,
                    "status_id": i.status_id,
                    "direct_allocated": mt_alloc,
                    "direct_spent": mt_spent,
                    "budget_id": mt_bid,
                    "operational_tasks": mt_ots,
                    "_children": mt_ots,
                    "can_allocate": i.status_id == STATUS_INITIATIVE_ACTIVE and mt_bid is None,
                }
                _rollup_totals(node_mt)
                del node_mt["_children"]
                i_mts.append(node_mt)


            node_init = {
                "id": i.initiative_id,
                "name": i.name,
                "status_id": i.status_id,
                "direct_allocated": i_alloc,
                "direct_spent": i_spent,
                "budget_id": i_bid,
                "major_tasks": i_mts,
                "_children": i_mts,
                "can_allocate": i.status_id == STATUS_INITIATIVE_ACTIVE and i_bid is None,
            }
            _rollup_totals(node_init)
            del node_init["_children"]
            p_inits.append(node_init)


        goal = goals.get(p.goal_id)
        pillar = pillars.get(goal.pillar_id) if goal else None


        node_prog = {
            "id": p.program_id,
            "name": p.name,
            "status_id": p.status_id,
            "strategic_goal": goal.title if goal else "غير مرتبط بهدف",
            "strategic_pillar": pillar.name if pillar else "غير مرتبط بركيزة",
            "direct_allocated": p_alloc,
            "direct_spent": p_spent,
            "budget_id": p_bid,
            "initiatives": p_inits,
            "_children": p_inits,
            "can_allocate": p.status_id == STATUS_PROGRAM_ACTIVE and p_bid is None,
        }
        _rollup_totals(node_prog)
        del node_prog["_children"]
        tree.append(node_prog)


    return {"success": True, "data": tree}




@router.get("/{budget_id}")
async def get_budget_detail(
    budget_id: int,
    employee_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    bl = db.query(BudgetLine).filter(BudgetLine.budget_id == budget_id).first()
    if not bl:
        raise HTTPException(status_code=404, detail="الميزانية غير موجودة")


    item_name, hierarchy, status_id = _get_budget_item_display(db, bl)


    parent_warning = None
    if bl.parent_budget_id:
        parent = db.query(BudgetLine).filter(BudgetLine.budget_id == bl.parent_budget_id).first()
        if parent:
            expected_parent = PARENT_TYPE_MAP.get(bl.budgetable_type)
            if parent.budgetable_type != expected_parent:
                parent_warning = "تحذير: الميزانية الأب لا تتطابق مع الهيكل التنظيمي."


    available_info = _available_to_allocate(db, bl.parent_budget_id, bl.fiscal_year)


    return {
        "budget_id": bl.budget_id,
        "budgetable_type": bl.budgetable_type,
        "budgetable_name": item_name,
        "status_id": status_id,
        "hierarchy": hierarchy,
        "fiscal_year": bl.fiscal_year,
        "allocated_amount": float(bl.allocated_amount),
        "spent_amount": float(bl.spent_amount),
        "remaining_amount": float(bl.allocated_amount) - float(bl.spent_amount),
        "parent_budget_id": bl.parent_budget_id,
        "parent_warning": parent_warning,
        "department_id": bl.department_id,
        "available_info": available_info,
        "is_editable": _is_editable(bl.budgetable_type, status_id),
    }




@router.post("/")
async def create_budget_line(
    data: dict,
    employee_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    budgetable_type = data.get("budgetable_type")
    budgetable_id = data.get("budgetable_id")
    fiscal_year = data.get("fiscal_year")
    allocated_amount = data.get("allocated_amount")


    if not budgetable_type or not budgetable_id or not fiscal_year:
        raise HTTPException(status_code=400, detail="البيانات المطلوبة ناقصة")


    if budgetable_type not in ("program", "initiative", "major_task", "operational_task"):
        raise HTTPException(status_code=400, detail="نوع البند غير مدعوم")


    try:
        allocated_amount = float(allocated_amount or 0)
    except (TypeError, ValueError):
        raise HTTPException(status_code=400, detail="المبلغ غير صالح")


    if allocated_amount < 0:
        raise HTTPException(status_code=400, detail="المبلغ المخصص لا يمكن أن يكون سالباً")


    item, status_id = _get_item_and_status(db, budgetable_type, int(budgetable_id))
    if not item:
        raise HTTPException(status_code=404, detail="البند غير موجود")


    if not _is_editable(budgetable_type, status_id):
        raise HTTPException(status_code=403, detail="لا يمكن إضافة ميزانية إلا للبنود قيد التنفيذ")


    existing = db.query(BudgetLine).filter(
        BudgetLine.budgetable_type == budgetable_type,
        BudgetLine.budgetable_id == int(budgetable_id),
        BudgetLine.fiscal_year == int(fiscal_year),
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="توجد ميزانية مسجلة مسبقاً لنفس البند والسنة")


    parent_id = _resolve_parent_id(db, budgetable_type, int(budgetable_id), int(fiscal_year))
    if budgetable_type != "program" and not parent_id:
        raise HTTPException(
            status_code=400,
            detail="يجب إنشاء ميزانية الأصل أولاً قبل تخصيص هذا البند",
        )


    avail = _available_to_allocate(db, parent_id, int(fiscal_year))
    if avail and allocated_amount > avail["available_to_allocate"] + 0.01:
        raise HTTPException(
            status_code=400,
            detail=f"المبلغ ({allocated_amount:,.2f}) يتجاوز المتاح من الأصل ({avail['available_to_allocate']:,.2f})",
        )


    new_budget = BudgetLine(
        budgetable_type=budgetable_type,
        budgetable_id=int(budgetable_id),
        department_id=data.get("department_id"),
        fiscal_year=int(fiscal_year),
        allocated_amount=allocated_amount,
        spent_amount=0,
        parent_budget_id=parent_id,
    )
    db.add(new_budget)
    db.commit()
    db.refresh(new_budget)


    return {
        "success": True,
        "message": "تم إنشاء الميزانية بنجاح",
        "budget_id": new_budget.budget_id,
        "parent_budget_id": parent_id,
    }




@router.put("/{budget_id}")
async def update_budget_line(
    budget_id: int,
    data: dict,
    employee_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    bl = db.query(BudgetLine).filter(BudgetLine.budget_id == budget_id).first()
    if not bl:
        raise HTTPException(status_code=404, detail="الميزانية غير موجودة")


    _, status_id = _get_item_and_status(db, bl.budgetable_type, bl.budgetable_id)
    if not _is_editable(bl.budgetable_type, status_id):
        raise HTTPException(status_code=403, detail="لا يمكن تعديل ميزانية بند غير قيد التنفيذ")


    if "allocated_amount" in data:
        new_alloc = float(data["allocated_amount"])
        if new_alloc < 0:
            raise HTTPException(status_code=400, detail="المبلغ لا يمكن أن يكون سالباً")


        if bl.parent_budget_id:
            avail = _available_to_allocate(db, bl.parent_budget_id, bl.fiscal_year)
            if avail:
                other_children = db.query(BudgetLine).filter(
                    BudgetLine.parent_budget_id == bl.parent_budget_id,
                    BudgetLine.budget_id != bl.budget_id,
                ).all()
                already_allocated = sum(float(c.allocated_amount) for c in other_children)
                max_allowed = avail["parent_allocated"] - avail["parent_spent"] - already_allocated
                if new_alloc > max_allowed + 0.01:
                    raise HTTPException(
                        status_code=400,
                        detail=f"المبلغ الجديد يتجاوز المتاح من الأصل ({max_allowed:,.2f})",
                    )


        children = db.query(BudgetLine).filter(BudgetLine.parent_budget_id == bl.budget_id).all()
        total_children = sum(float(c.allocated_amount) for c in children)
        if new_alloc < total_children:
            raise HTTPException(
                status_code=400,
                detail=f"لا يمكن تقليل المخصص أقل من مجموع الأبناء ({total_children:,.2f})",
            )


        bl.allocated_amount = new_alloc


    if "department_id" in data:
        bl.department_id = data["department_id"]
    if "fiscal_year" in data:
        bl.fiscal_year = int(data["fiscal_year"])


    db.commit()
    return {"success": True, "message": "تم تحديث الميزانية بنجاح"}




@router.get("/{budget_id}/transactions")
async def get_budget_transactions(
    budget_id: int,
    page: int = Query(1, ge=1),
    per_page: int = Query(10, ge=1, le=100),
    employee_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    query = db.query(BudgetTransaction).filter(BudgetTransaction.budget_id == budget_id)
    total = query.count()
    transactions = (
        query.order_by(desc(BudgetTransaction.transaction_date))
        .offset((page - 1) * per_page)
        .limit(per_page)
        .all()
    )


    result = []
    for t in transactions:
        trans_type = db.query(DictTransactionType).filter(
            DictTransactionType.trans_type_id == t.transaction_type_id
        ).first()
        created_by = db.query(Employee).filter(Employee.employee_id == t.created_by).first()
        approver = db.query(Employee).filter(Employee.employee_id == t.approved_by).first() if t.approved_by else None


        result.append({
            "transaction_id": t.transaction_id,
            "amount": float(t.amount),
            "transaction_type": trans_type.name_ar if trans_type else "غير محدد",
            "type_id": t.transaction_type_id,
            "description": t.description,
            "transaction_date": t.transaction_date.isoformat() if t.transaction_date else None,
            "created_by": created_by.full_name if created_by else "غير معروف",
            "approved_by": approver.full_name if approver else "معلق",
            "approved_at": t.approved_at.isoformat() if t.approved_at else None,
            "pending_approval": t.approved_at is None and float(t.amount) >= APPROVAL_THRESHOLD,
        })


    return {
        "data": result,
        "total": total,
        "page": page,
        "per_page": per_page,
        "total_pages": (total + per_page - 1) // per_page,
    }




@router.post("/{budget_id}/transactions")
async def create_transaction(
    budget_id: int,
    data: dict,
    employee_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    bl = db.query(BudgetLine).filter(BudgetLine.budget_id == budget_id).first()
    if not bl:
        raise HTTPException(status_code=404, detail="الميزانية غير موجودة")


    _, status_id = _get_item_and_status(db, bl.budgetable_type, bl.budgetable_id)
    if not _is_editable(bl.budgetable_type, status_id):
        raise HTTPException(status_code=403, detail="لا يمكن إضافة عمليات لبند غير قيد التنفيذ")


    try:
        amount = float(data.get("amount", 0))
    except (TypeError, ValueError):
        raise HTTPException(status_code=400, detail="المبلغ غير صالح")


    if amount <= 0:
        raise HTTPException(status_code=400, detail="المبلغ يجب أن يكون أكبر من صفر")


    type_id = int(data.get("transaction_type_id", 0))


    if type_id == 1:
        raise HTTPException(
            status_code=400,
            detail="التخصيص يتم عبر إنشاء الميزانية وليس كعملية مالية.",
        )


    trans_type = db.query(DictTransactionType).filter(
        DictTransactionType.trans_type_id == type_id
    ).first()
    if not trans_type:
        raise HTTPException(status_code=400, detail="نوع العملية غير صحيح")


    if type_id == 2 and amount > float(bl.allocated_amount) - float(bl.spent_amount):
        raise HTTPException(status_code=400, detail="المبلغ يتجاوز الرصيد المتبقي")


    needs_approval = amount >= APPROVAL_THRESHOLD
    approver_id = employee_id if not needs_approval else None
    approved_at = datetime.now() if not needs_approval else None


    new_trans = BudgetTransaction(
        budget_id=budget_id,
        amount=amount,
        transaction_type_id=type_id,
        description=data.get("description"),
        transaction_date=data.get("transaction_date") or datetime.now(),
        created_by=employee_id,
        approved_by=approver_id,
        approved_at=approved_at,
    )
    db.add(new_trans)
    db.flush()


    _recalc_spent(db, bl)
    db.commit()


    return {
        "success": True,
        "message": "تم تسجيل العملية بنجاح" if not needs_approval else "تم تسجيل العملية بانتظار الاعتماد",
        "needs_approval": needs_approval,
        "transaction_id": new_trans.transaction_id,
    }




@router.post("/transactions/{transaction_id}/approve")
async def approve_transaction(
    transaction_id: int,
    employee_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    t = db.query(BudgetTransaction).filter(
        BudgetTransaction.transaction_id == transaction_id
    ).first()
    if not t:
        raise HTTPException(status_code=404, detail="العملية غير موجودة")


    if t.approved_at is not None:
        raise HTTPException(status_code=400, detail="العملية معتمدة مسبقاً")


    bl = db.query(BudgetLine).filter(BudgetLine.budget_id == t.budget_id).first()
    if not bl:
        raise HTTPException(status_code=404, detail="الميزانية غير موجودة")


    if t.transaction_type_id == 2:
        remaining = float(bl.allocated_amount) - float(bl.spent_amount)
        if float(t.amount) > remaining:
            raise HTTPException(
                status_code=400,
                detail=f"لا يمكن الاعتماد: المبلغ ({float(t.amount):,.2f}) يتجاوز المتبقي ({remaining:,.2f})",
            )


    t.approved_by = employee_id
    t.approved_at = datetime.now()


    _recalc_spent(db, bl)
    db.commit()


    logger.info(
        f"APPROVED transaction_id={transaction_id} budget_id={t.budget_id} "
        f"amount={t.amount} by_employee={employee_id}"
    )


    return {"success": True, "message": "تم اعتماد العملية بنجاح"}




@router.delete("/transactions/{transaction_id}")
async def delete_transaction(
    transaction_id: int,
    employee_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    t = db.query(BudgetTransaction).filter(
        BudgetTransaction.transaction_id == transaction_id
    ).first()
    if not t:
        raise HTTPException(status_code=404, detail="العملية غير موجودة")


    if t.approved_at is not None:
        raise HTTPException(status_code=403, detail="لا يمكن حذف عملية معتمدة. أنشئ حركة تعديل بدلاً من ذلك.")


    bl = db.query(BudgetLine).filter(BudgetLine.budget_id == t.budget_id).first()
    if not bl:
        raise HTTPException(status_code=404, detail="الميزانية المرتبطة غير موجودة")


    db.delete(t)
    _recalc_spent(db, bl)
    db.commit()


    return {"success": True, "message": "تم حذف العملية بنجاح"}




@router.get("/transactions/{transaction_id}")
async def get_transaction_detail(
    transaction_id: int,
    employee_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    t = db.query(BudgetTransaction).filter(
        BudgetTransaction.transaction_id == transaction_id
    ).first()
    if not t:
        raise HTTPException(status_code=404, detail="العملية غير موجودة")


    trans_type = db.query(DictTransactionType).filter(
        DictTransactionType.trans_type_id == t.transaction_type_id
    ).first()
    created_by = db.query(Employee).filter(Employee.employee_id == t.created_by).first()
    approver = db.query(Employee).filter(Employee.employee_id == t.approved_by).first() if t.approved_by else None


    return {
        "transaction_id": t.transaction_id,
        "budget_id": t.budget_id,
        "amount": float(t.amount),
        "transaction_type": trans_type.name_ar if trans_type else "غير محدد",
        "type_id": t.transaction_type_id,
        "description": t.description,
        "transaction_date": t.transaction_date.isoformat() if t.transaction_date else None,
        "created_by": created_by.full_name if created_by else "غير معروف",
        "approved_by": approver.full_name if approver else "معلق",
        "approved_at": t.approved_at.isoformat() if t.approved_at else None,
    }




@router.get("/approvals/count")
async def get_approvals_count(
    employee_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    count = db.query(BudgetTransaction).filter(
        BudgetTransaction.approved_at.is_(None),
        BudgetTransaction.amount >= APPROVAL_THRESHOLD,
    ).count()
    return {"success": True, "count": count}




@router.get("/approvals/pending")
async def get_pending_approvals(
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    min_amount: Optional[float] = Query(None),
    budgetable_type: Optional[str] = Query(None),
    employee_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    q = db.query(BudgetTransaction).filter(
        BudgetTransaction.approved_at.is_(None),
        BudgetTransaction.amount >= APPROVAL_THRESHOLD,
    )


    if min_amount is not None:
        q = q.filter(BudgetTransaction.amount >= min_amount)


    if budgetable_type:
        q = q.join(BudgetLine, BudgetLine.budget_id == BudgetTransaction.budget_id).filter(
            BudgetLine.budgetable_type == budgetable_type
        )


    total = q.count()
    transactions = (
        q.order_by(desc(BudgetTransaction.transaction_date))
        .offset((page - 1) * per_page)
        .limit(per_page)
        .all()
    )


    data = []
    total_amount = 0.0


    for t in transactions:
        bl = db.query(BudgetLine).filter(BudgetLine.budget_id == t.budget_id).first()
        if not bl:
            continue


        item_name, hierarchy, status_id = _get_budget_item_display(db, bl)


        trans_type = db.query(DictTransactionType).filter(
            DictTransactionType.trans_type_id == t.transaction_type_id
        ).first()


        creator = db.query(Employee).filter(Employee.employee_id == t.created_by).first()
        dept = db.query(Department).filter(Department.department_id == bl.department_id).first() if bl.department_id else None


        current_allocated = float(bl.allocated_amount)
        current_spent = float(bl.spent_amount)
        current_remaining = current_allocated - current_spent
        amount = float(t.amount)


        can_approve = True
        warning = None
        if t.transaction_type_id == 2 and amount > current_remaining:
            can_approve = False
            warning = f"المبلغ ({amount:,.2f}) يتجاوز الرصيد المتبقي ({current_remaining:,.2f})"


        data.append({
            "transaction_id": t.transaction_id,
            "budget_id": bl.budget_id,
            "budgetable_type": bl.budgetable_type,
            "budgetable_name": item_name,
            "hierarchy": hierarchy,
            "status_id": status_id,
            "department_name": dept.name if dept else None,
            "amount": amount,
            "transaction_type": trans_type.name_ar if trans_type else "غير محدد",
            "transaction_type_en": trans_type.code if trans_type else None,
            "type_id": t.transaction_type_id,
            "description": t.description,
            "transaction_date": t.transaction_date.isoformat() if t.transaction_date else None,
            "created_by": creator.full_name if creator else "غير معروف",
            "current_allocated": current_allocated,
            "current_spent": current_spent,
            "current_remaining": current_remaining,
            "can_approve": can_approve,
            "warning": warning,
        })


        total_amount += amount


    return {
        "success": True,
        "data": data,
        "total": total,
        "page": page,
        "per_page": per_page,
        "total_pages": (total + per_page - 1) // per_page,
        "stats": {
            "total_pending": total,
            "total_amount_pending": total_amount,
            "overspend_pending": sum(1 for d in data if not d["can_approve"]),
        },
    }




@router.post("/approvals/{transaction_id}/reject")
async def reject_transaction(
    transaction_id: int,
    data: dict,
    employee_id: int = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    t = db.query(BudgetTransaction).filter(
        BudgetTransaction.transaction_id == transaction_id
    ).first()
    if not t:
        raise HTTPException(status_code=404, detail="العملية غير موجودة")


    if t.approved_at is not None:
        raise HTTPException(status_code=400, detail="لا يمكن رفض عملية معتمدة مسبقاً")


    reason = (data.get("reason") or "").strip()
    if len(reason) < 5:
        raise HTTPException(status_code=400, detail="سبب الرفض مطلوب (5 أحرف على الأقل)")


    logger.warning(
        f"REJECTED transaction_id={transaction_id} budget_id={t.budget_id} "
        f"amount={t.amount} type_id={t.transaction_type_id} "
        f"by_employee={employee_id} reason={reason}"
    )


    db.delete(t)
    db.commit()


    return {"success": True, "message": "تم رفض العملية وحذفها من قائمة الانتظار"}

