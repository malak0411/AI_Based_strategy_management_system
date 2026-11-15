@extends('layouts.app')

@section('title', 'اعتماد الحركات المالية')

@push('styles')
<style>
    .kpi-card { border-right: 4px solid; transition: transform 0.2s; }
    .kpi-card:hover { transform: translateY(-3px); }
    .bg-navy { background-color: #1a1a2e; color: white; }
    .text-navy { color: #1a1a2e; }
    .approval-row.warning-row { background: #fff8e1; }
    .approval-row.warning-row:hover { background: #fff3cd; }
    .type-badge { font-size: 11px; padding: 4px 10px; font-weight: 700; }
    .btn-approve { background: #28a745; color: #fff; border: none; }
    .btn-approve:hover { background: #218838; color: #fff; }
    .btn-reject { background: #dc3545; color: #fff; border: none; }
    .btn-reject:hover { background: #c82333; color: #fff; }
    .modal-overlay { z-index: 1060; }
</style>
@endpush

@section('content')
<div class="container-fluid px-4 py-3" dir="rtl">

    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
        <div>
            <h3 class="fw-bold text-navy mb-1">
                <i class="fas fa-stamp ml-2 text-warning"></i>
                اعتماد الحركات المالية
            </h3>
            <p class="text-muted mb-0">مراجعة واعتماد الحركات التي تتجاوز 100,000 ريال</p>
        </div>
        <a href="javascript:history.back()" class="btn btn-outline-secondary">
                <i class="fas fa-arrow-right"></i> العودة
        </a>
    </div>

    @if(session('success'))
        <div class="alert alert-success alert-dismissible fade show">{{ session('success') }}<button class="btn-close" data-bs-dismiss="alert"></button></div>
    @endif
    @if(session('error'))
        <div class="alert alert-danger alert-dismissible fade show">{{ session('error') }}<button class="btn-close" data-bs-dismiss="alert"></button></div>
    @endif

    <div class="row g-3 mb-4">
        <div class="col-md-4">
            <div class="card shadow-sm kpi-card border-warning">
                <div class="card-body d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="text-muted mb-1">طلبات بانتظار الاعتماد</h6>
                        <h3 class="fw-bold text-warning mb-0">{{ $stats['total_pending'] ?? 0 }}</h3>
                    </div>
                    <i class="fas fa-hourglass-half fa-3x text-warning opacity-25"></i>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card shadow-sm kpi-card border-primary">
                <div class="card-body d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="text-muted mb-1">إجمالي المبالغ المعلقة</h6>
                        <h3 class="fw-bold text-primary mb-0">{{ number_format($stats['total_amount_pending'] ?? 0, 2) }} <small>ريال</small></h3>
                    </div>
                    <i class="fas fa-money-bill-wave fa-3x text-primary opacity-25"></i>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card shadow-sm kpi-card border-danger">
                <div class="card-body d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="text-muted mb-1">تحتاج مراجعة (تجاوز رصيد)</h6>
                        <h3 class="fw-bold text-danger mb-0">{{ $stats['overspend_pending'] ?? 0 }}</h3>
                    </div>
                    <i class="fas fa-exclamation-triangle fa-3x text-danger opacity-25"></i>
                </div>
            </div>
        </div>
    </div>

    <div class="card shadow-sm mb-4">
        <div class="card-body py-3">
            <form method="GET" action="{{ route('budget.approvals') }}" class="row g-2 align-items-end">
                <div class="col-md-4">
                    <label class="form-label small fw-bold mb-1">الحد الأدنى للمبلغ</label>
                    <input type="number" name="min_amount" class="form-control form-control-sm"
                           value="{{ $filters['min_amount'] ?? '' }}" min="0" step="1000"
                           placeholder="مثال: 500000">
                </div>
                <div class="col-md-4">
                    <label class="form-label small fw-bold mb-1">نوع البند</label>
                    <select name="budgetable_type" class="form-select form-select-sm">
                        <option value="">كل الأنواع</option>
                        <option value="program" {{ ($filters['budgetable_type'] ?? '') == 'program' ? 'selected' : '' }}>برنامج</option>
                        <option value="initiative" {{ ($filters['budgetable_type'] ?? '') == 'initiative' ? 'selected' : '' }}>مبادرة</option>
                        <option value="major_task" {{ ($filters['budgetable_type'] ?? '') == 'major_task' ? 'selected' : '' }}>مهمة رئيسية</option>
                        <option value="operational_task" {{ ($filters['budgetable_type'] ?? '') == 'operational_task' ? 'selected' : '' }}>مهمة تشغيلية</option>
                    </select>
                </div>
                <div class="col-md-4">
                    <button type="submit" class="btn btn-primary btn-sm"><i class="fas fa-filter"></i> تصفية</button>
                    <a href="{{ route('budget.approvals') }}" class="btn btn-outline-secondary btn-sm"><i class="fas fa-times"></i> مسح</a>
                </div>
            </form>
        </div>
    </div>

    <div class="card shadow-sm">
        <div class="card-body p-0">
            @if(empty($transactions))
                <div class="text-center py-5 text-muted">
                    <i class="fas fa-check-circle fa-4x text-success mb-3"></i>
                    <h5>لا توجد حركات بانتظار الاعتماد</h5>
                    <p class="mb-0">كل الحركات المعلقة تمت معالجتها</p>
                </div>
            @else
                <div class="table-responsive">
                    <table class="table table-hover mb-0 align-middle">
                        <thead class="table-light">
                            <tr>
                                <th style="width:70px">#</th>
                                <th>البند والميزانية</th>
                                <th style="width:120px">النوع</th>
                                <th style="width:130px">المبلغ</th>
                                <th style="width:130px">الرصيد المتبقي</th>
                                <th>الوصف</th>
                                <th style="width:120px">بواسطة</th>
                                <th style="width:110px">التاريخ</th>
                                <th style="width:180px">الإجراءات</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($transactions as $t)
                                <tr class="approval-row {{ empty($t['can_approve']) ? 'warning-row' : '' }}" id="row-{{ $t['transaction_id'] }}">
                                    <td class="fw-bold">#{{ $t['transaction_id'] }}</td>
                                    <td>
                                        <div class="fw-bold" style="font-size:13px;">{{ $t['budgetable_name'] }}</div>
                                        <small class="text-muted d-block">{{ $t['hierarchy'] }}</small>
                                        @if($t['department_name'])
                                            <span class="badge bg-secondary" style="font-size:10px;">
                                                <i class="fas fa-building"></i> {{ $t['department_name'] }}
                                            </span>
                                        @endif
                                    </td>
                                    <td>
                                        @if($t['type_id'] == 2)
                                            <span class="badge bg-danger type-badge"><i class="fas fa-arrow-up"></i> {{ $t['transaction_type'] }}</span>
                                        @elseif($t['type_id'] == 3)
                                            <span class="badge bg-success type-badge"><i class="fas fa-arrow-down"></i> {{ $t['transaction_type'] }}</span>
                                        @else
                                            <span class="badge bg-secondary type-badge">{{ $t['transaction_type'] }}</span>
                                        @endif
                                    </td>
                                    <td class="fw-bold text-danger" style="font-size:15px;">
                                        {{ number_format($t['amount'], 2) }}
                                    </td>
                                    <td class="fw-bold {{ $t['current_remaining'] < 0 ? 'text-danger' : 'text-success' }}">
                                        {{ number_format($t['current_remaining'], 2) }}
                                    </td>
                                    <td>
                                        <div style="font-size:12px;max-width:280px;">
                                            {{ Str::limit($t['description'] ?? '', 100) }}
                                        </div>
                                        @if(!empty($t['warning']))
                                            <small class="text-danger d-block mt-1">
                                                <i class="fas fa-exclamation-triangle"></i> {{ $t['warning'] }}
                                            </small>
                                        @endif
                                    </td>
                                    <td>
                                        <small><i class="fas fa-user"></i> {{ $t['created_by'] }}</small>
                                    </td>
                                    <td>
                                        <small>
                                            {{ $t['transaction_date'] ? \Carbon\Carbon::parse($t['transaction_date'])->format('Y-m-d') : '—' }}
                                        </small>
                                    </td>
                                    <td>
                                        <button class="btn btn-sm btn-outline-info mb-1"
                                                onclick="showDetail({{ $t['transaction_id'] }})"
                                                title="عرض التفاصيل">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                        @if(!empty($t['can_approve']))
                                            <button class="btn btn-sm btn-approve mb-1"
                                                    onclick="approveTransaction({{ $t['transaction_id'] }})"
                                                    title="اعتماد">
                                                <i class="fas fa-check"></i> اعتماد
                                            </button>
                                        @else
                                            <button class="btn btn-sm btn-secondary mb-1" disabled title="{{ $t['warning'] }}">
                                                <i class="fas fa-lock"></i> معطّل
                                            </button>
                                        @endif
                                        <button class="btn btn-sm btn-reject mb-1"
                                                onclick="openRejectModal({{ $t['transaction_id'] }})"
                                                title="رفض">
                                            <i class="fas fa-times"></i> رفض
                                        </button>
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>

                @if(isset($pagination['total_pages']) && $pagination['total_pages'] > 1)
                    <div class="card-footer bg-white">
                        <nav>
                            <ul class="pagination justify-content-center mb-0">
                                @for($i = 1; $i <= $pagination['total_pages']; $i++)
                                    <li class="page-item {{ $i == ($pagination['page'] ?? 1) ? 'active' : '' }}">
                                        <a class="page-link" href="?page={{ $i }}{{ request('min_amount') ? '&min_amount='.request('min_amount') : '' }}{{ request('budgetable_type') ? '&budgetable_type='.request('budgetable_type') : '' }}">{{ $i }}</a>
                                    </li>
                                @endfor
                            </ul>
                        </nav>
                    </div>
                @endif
            @endif
        </div>
    </div>
</div>

<div class="modal fade modal-overlay" id="detailModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-navy text-white">
                <h5 class="modal-title"><i class="fas fa-file-invoice ml-2"></i> تفاصيل الحركة المالية</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" id="detailBody">
                <div class="text-center py-4"><i class="fas fa-spinner fa-spin fa-2x"></i></div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" data-bs-dismiss="modal">إغلاق</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade modal-overlay" id="rejectModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title"><i class="fas fa-ban ml-2"></i> رفض الحركة المالية</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="rejectTransactionId">
                <div class="alert alert-warning small mb-3">
                    <i class="fas fa-info-circle"></i>
                    سيتم حذف الحركة نهائياً من قائمة الانتظار ولن تُطبَّق على رصيد الميزانية.
                </div>
                <label class="form-label fw-bold">سبب الرفض <span class="text-danger">*</span></label>
                <textarea id="rejectReason" class="form-control" rows="4" maxlength="500"
                          placeholder="اذكر سبب الرفض بوضوح (5 أحرف على الأقل)..."></textarea>
                <small class="text-muted d-block mt-1"><span id="rejectCharCount">0</span>/500</small>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" data-bs-dismiss="modal">إلغاء</button>
                <button class="btn btn-danger" onclick="confirmReject()">
                    <i class="fas fa-ban"></i> تأكيد الرفض
                </button>
            </div>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
(function () {
    'use strict';

    const CSRF = '{{ csrf_token() }}';
    const TRANSACTIONS = @json($transactions);

    function findTx(id) {
        return TRANSACTIONS.find(t => String(t.transaction_id) === String(id));
    }

    window.showDetail = function (id) {
        const t = findTx(id);
        if (!t) return;

        const typeBadge = t.type_id == 2
            ? '<span class="badge bg-danger">صرف</span>'
            : t.type_id == 3
                ? '<span class="badge bg-success">استرداد</span>'
                : '<span class="badge bg-secondary">' + (t.transaction_type || '') + '</span>';

        const html = `
            <table class="table table-bordered mb-0">
                <tr><th class="bg-light" style="width:35%;">رقم الحركة</th><td>#${t.transaction_id}</td></tr>
                <tr><th class="bg-light">البند</th><td><strong>${t.budgetable_name}</strong></td></tr>
                <tr><th class="bg-light">الهيكل</th><td><small>${t.hierarchy || '—'}</small></td></tr>
                <tr><th class="bg-light">الإدارة</th><td>${t.department_name || '—'}</td></tr>
                <tr><th class="bg-light">النوع</th><td>${typeBadge}</td></tr>
                <tr><th class="bg-light">المبلغ</th><td class="text-danger fw-bold fs-5">${Number(t.amount).toLocaleString('en', {minimumFractionDigits: 2})} ريال</td></tr>
                <tr><th class="bg-light">الوصف</th><td>${t.description || '—'}</td></tr>
                <tr><th class="bg-light">التاريخ</th><td>${t.transaction_date ? t.transaction_date.substring(0, 10) : '—'}</td></tr>
                <tr><th class="bg-light">أنشأها</th><td>${t.created_by || '—'}</td></tr>
                <tr><th class="bg-light">الميزانية الكلية</th><td>${Number(t.current_allocated).toLocaleString('en', {minimumFractionDigits: 2})}</td></tr>
                <tr><th class="bg-light">المصروف الحالي</th><td class="text-danger">${Number(t.current_spent).toLocaleString('en', {minimumFractionDigits: 2})}</td></tr>
                <tr><th class="bg-light">الرصيد المتبقي</th><td class="${t.current_remaining < 0 ? 'text-danger' : 'text-success'} fw-bold">${Number(t.current_remaining).toLocaleString('en', {minimumFractionDigits: 2})}</td></tr>
                ${t.warning ? `<tr><td colspan="2" class="bg-warning-subtle text-danger"><i class="fas fa-exclamation-triangle"></i> ${t.warning}</td></tr>` : ''}
            </table>
        `;
        document.getElementById('detailBody').innerHTML = html;
        new bootstrap.Modal(document.getElementById('detailModal')).show();
    };

    window.approveTransaction = function (id) {
        if (!confirm('هل تريد اعتماد هذه الحركة المالية؟')) return;

        fetch('/budget/approvals/' + id + '/approve', {
            method: 'POST',
            headers: {
                'X-CSRF-TOKEN': CSRF,
                'Accept': 'application/json',
                'X-Requested-With': 'XMLHttpRequest'
            }
        })
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                const row = document.getElementById('row-' + id);
                if (row) row.style.transition = 'opacity .3s', row.style.opacity = '0';
                setTimeout(() => location.reload(), 350);
            } else {
                alert(data.error || 'فشل الاعتماد');
            }
        })
        .catch(e => alert('خطأ: ' + e.message));
    };

    window.openRejectModal = function (id) {
        document.getElementById('rejectTransactionId').value = id;
        document.getElementById('rejectReason').value = '';
        document.getElementById('rejectCharCount').textContent = '0';
        new bootstrap.Modal(document.getElementById('rejectModal')).show();
    };

    window.confirmReject = function () {
        const id = document.getElementById('rejectTransactionId').value;
        const reason = document.getElementById('rejectReason').value.trim();

        if (reason.length < 5) {
            alert('سبب الرفض مطلوب (5 أحرف على الأقل)');
            return;
        }

        fetch('/budget/approvals/' + id + '/reject', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': CSRF,
                'Accept': 'application/json',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: JSON.stringify({ reason: reason })
        })
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                bootstrap.Modal.getInstance(document.getElementById('rejectModal')).hide();
                const row = document.getElementById('row-' + id);
                if (row) row.style.transition = 'opacity .3s', row.style.opacity = '0';
                setTimeout(() => location.reload(), 350);
            } else {
                alert(data.error || 'فشل الرفض');
            }
        })
        .catch(e => alert('خطأ: ' + e.message));
    };

    const rejectTa = document.getElementById('rejectReason');
    if (rejectTa) {
        rejectTa.addEventListener('input', function () {
            document.getElementById('rejectCharCount').textContent = this.value.length;
        });
    }
})();
</script>
@endpush
