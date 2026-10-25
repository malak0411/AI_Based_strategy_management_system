@extends('layouts.app')

@section('title', 'تعديل إجراء معالجة الخطر')

@push('styles')
<style>
    .edit-card {
        background: #fff;
        border: 1px solid #e6e9f2;
        border-radius: 14px;
        padding: 24px;
        max-width: 820px;
        margin: 0 auto;
    }
    .edit-header {
        background: linear-gradient(135deg, #0D1B3E 0%, #1e40af 100%);
        color: #fff;
        border-radius: 14px;
        padding: 20px 24px;
        margin-bottom: 24px;
    }
    .edit-header h4 { margin: 0 0 4px; font-weight: 700; }
    .edit-header .meta { color: #cdd6ee; font-size: .88rem; }
    .form-label { font-weight: 600; color: #0D1B3E; font-size: .88rem; }
    .form-control, .form-select { border-radius: 8px; border-color: #e6e9f2; padding: 10px 14px; }
    .form-control:focus, .form-select:focus {
        border-color: #3b82f6;
        box-shadow: 0 0 0 3px rgba(59,130,246,.15);
    }
    .context-box {
        background: #f7f9fd;
        border-radius: 10px;
        padding: 14px;
        margin-bottom: 20px;
        border-inline-start: 4px solid #3b82f6;
    }
    .context-box .label { font-size: .72rem; color: #5b6580; margin-bottom: 2px; }
    .context-box .value { font-weight: 700; color: #0D1B3E; font-size: .9rem; }
    .status-badge {
        padding: 4px 11px;
        border-radius: 20px;
        font-size: .72rem;
        font-weight: 600;
    }
</style>
@endpush

@section('content')
<div class="container-fluid px-4" dir="rtl">

    <div class="edit-header">
        <div class="d-flex justify-content-between align-items-start flex-wrap gap-2">
            <div>
                <h4><i class="fas fa-edit me-2"></i> تعديل إجراء معالجة الخطر</h4>
                <div class="meta">
                    {{ $risk['name'] ?? $mitigation['risk_name'] ?? '—' }}
                    @if(!empty($mitigation['task_id']))
                        • المهمة رقم #{{ $mitigation['task_id'] }}
                    @endif
                </div>
            </div>
            <a href="{{ url()->previous() }}" class="btn btn-sm btn-outline-light">
                <i class="fas fa-arrow-right me-1"></i> رجوع
            </a>
        </div>
    </div>

    @if(session('error'))
        <div class="alert alert-danger">{{ session('error') }}</div>
    @endif
    @if(session('success'))
        <div class="alert alert-success">{{ session('success') }}</div>
    @endif
    @if($errors->any())
        <div class="alert alert-danger">
            <ul class="mb-0">
                @foreach($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <div class="edit-card">

        <div class="context-box">
            <div class="row g-3">
                <div class="col-md-4">
                    <div class="label">الخطر المرتبط</div>
                    <div class="value">{{ $risk['name'] ?? $mitigation['risk_name'] ?? '—' }}</div>
                </div>
                <div class="col-md-4">
                    <div class="label">الحالة الحالية</div>
                    <div>
                        <span class="status-badge"
                              style="background: {{ $mitigation['status_color'] ?? '#6c757d' }}22;
                                     color: {{ $mitigation['status_color'] ?? '#6c757d' }};">
                            {{ $mitigation['status_ar'] ?? 'غير محدد' }}
                        </span>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="label">تاريخ الإنشاء</div>
                    <div class="value" style="font-size:.82rem;">
                        {{ $mitigation['created_at'] ?? '—' }}
                    </div>
                </div>
            </div>

            @if(!empty($mitigation['completed_at']))
                <div class="alert alert-success py-2 px-3 mt-3 mb-0 small">
                    <i class="fas fa-check-circle"></i>
                    تم الإنجاز في: <strong>{{ $mitigation['completed_at'] }}</strong>
                </div>
            @endif
        </div>

        <form method="POST"
              action="{{ route('risks.mitigations.update', $mitigation['mitigation_id']) }}">
            @csrf
            @method('PUT')

            <div class="mb-3">
                <label class="form-label">
                    الإجراء <span class="text-danger">*</span>
                </label>
                <textarea name="action"
                          class="form-control @error('action') is-invalid @enderror"
                          rows="3"
                          required
                          maxlength="1000"
                          placeholder="وصف الإجراء">{{ old('action', $mitigation['action'] ?? '') }}</textarea>
                @error('action')
                    <div class="invalid-feedback">{{ $message }}</div>
                @enderror
            </div>

            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label">الموظف المسؤول</label>
                    <select name="assigned_to" class="form-select">
                        <option value="">— غير معين —</option>
                        @foreach($employees as $emp)
                            <option value="{{ $emp['employee_id'] }}"
                                {{ old('assigned_to', $mitigation['assigned_to'] ?? '') == $emp['employee_id'] ? 'selected' : '' }}>
                                {{ $emp['full_name'] }}
                                @if(!empty($emp['job_title']))
                                    — {{ $emp['job_title'] }}
                                @endif
                            </option>
                        @endforeach
                    </select>
                </div>

                <div class="col-md-6">
                    <label class="form-label">الحالة</label>
                    <select name="status_id" class="form-select">
                        @foreach($statuses as $st)
                            <option value="{{ $st['status_id'] }}"
                                {{ old('status_id', $mitigation['status_id'] ?? 41) == $st['status_id'] ? 'selected' : '' }}>
                                {{ $st['name_ar'] }}
                            </option>
                        @endforeach
                    </select>
                    <small class="text-muted d-block mt-1">
                        <i class="fas fa-info-circle"></i>
                        تغيير الحالة إلى "مكتمل" يُسجّل تاريخ الإنجاز تلقائيًا.
                    </small>
                </div>

                <div class="col-md-6">
                    <label class="form-label">تاريخ الإنجاز</label>
                    <input type="date"
                           name="due_date"
                           class="form-control"
                           value="{{ old('due_date', $mitigation['due_date'] ?? '') }}">
                </div>
            </div>

            <div class="mt-3 mb-4">
                <label class="form-label">ملاحظات</label>
                <textarea name="notes"
                          class="form-control"
                          rows="3"
                          maxlength="2000"
                          placeholder="ملاحظات إضافية (اختياري)">{{ old('notes', $mitigation['notes'] ?? '') }}</textarea>
            </div>

            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                <div class="d-flex gap-2">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save me-1"></i> حفظ التعديلات
                    </button>
                    <a href="{{ url()->previous() }}" class="btn btn-outline-secondary">
                        إلغاء
                    </a>
                </div>

                @if(isset($mitigation['task_id']) && $mitigation['task_id'])
                    <a href="{{ route('operational.task-detail', $mitigation['task_id']) }}"
                       class="btn btn-outline-primary">
                        <i class="fas fa-tasks me-1"></i> عرض المهمة
                    </a>
                @endif
            </div>
        </form>
    </div>

</div>
@endsection
