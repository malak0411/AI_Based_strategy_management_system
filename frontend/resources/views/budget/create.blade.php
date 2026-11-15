@extends('layouts.app')

@section('title', 'إضافة ميزانية')

@section('content')
<div class="container py-4" dir="rtl">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card shadow border-0">
                <div class="card-header bg-navy text-white">
                    <h5 class="mb-0"><i class="fas fa-file-invoice-dollar ml-2"></i> تخصيص ميزانية جديدة</h5>
                </div>
                <div class="card-body p-4">

                    @if(session('error'))
                        <div class="alert alert-danger">{{ session('error') }}</div>
                    @endif
                    @if($errors->any())
                        <div class="alert alert-danger">
                            <ul class="mb-0">@foreach($errors->all() as $e)<li>{{ $e }}</li>@endforeach</ul>
                        </div>
                    @endif

                    <div class="alert alert-info border-info">
                        <strong>البند المرتبط:</strong> {{ $name }} ({{ $type }})
                    </div>

                    @if($available && !($available['is_top_level'] ?? true))
                        <div class="alert alert-secondary">
                            <div class="d-flex justify-content-between">
                                <span><strong>المتاح من الأصل:</strong></span>
                                <span class="fw-bold text-success fs-5">{{ number_format($available['available_to_allocate'] ?? 0, 2) }} ريال</span>
                            </div>
                            <small class="text-muted d-block mt-1">
                                الأصل مُخصص: {{ number_format($available['parent_allocated'] ?? 0, 2) }}
                                | مصروف: {{ number_format($available['parent_spent'] ?? 0, 2) }}
                                | موزع على أبناء آخرين: {{ number_format($available['already_allocated_to_children'] ?? 0, 2) }}
                            </small>
                        </div>
                    @elseif($available && ($available['is_top_level'] ?? false))
                        <div class="alert alert-primary">
                            <i class="fas fa-crown ml-1"></i> هذا بند على المستوى الأعلى — لا يوجد مبلغ أب للتحقق منه.
                        </div>
                    @endif

                    <form action="{{ route('budget.store') }}" method="POST" id="budgetForm">
                        @csrf
                        <input type="hidden" name="budgetable_type" value="{{ $type }}">
                        <input type="hidden" name="budgetable_id" value="{{ $id }}">

                        <div class="row mb-4">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">السنة المالية</label>
                                <input type="number" name="fiscal_year" class="form-control" value="{{ old('fiscal_year', $fiscalYear) }}" required min="2000" max="2100">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">المبلغ المخصص (ريال)</label>
                                <input type="number" step="0.01" name="allocated_amount" id="allocatedAmount" class="form-control" value="{{ old('allocated_amount') }}" required min="0" placeholder="0.00">
                                @if($available && !($available['is_top_level'] ?? true))
                                    <small id="maxHint" class="text-danger fw-bold d-none mt-1">
                                        <i class="fas fa-exclamation-triangle"></i> المبلغ يتجاوز المتاح من الأصل!
                                    </small>
                                @endif
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label fw-bold">الإدارة المسؤولة</label>
                            <select name="department_id" class="form-select">
                                <option value="">-- بدون إدارة --</option>
                                @foreach($options['departments'] ?? [] as $dept)
                                    <option value="{{ $dept['id'] }}" {{ old('department_id') == $dept['id'] ? 'selected' : '' }}>{{ $dept['name'] }}</option>
                                @endforeach
                            </select>
                        </div>

                        <div class="d-flex justify-content-end gap-2 border-top pt-3">
                            <a href="{{ route('budget.index') }}" class="btn btn-light border">إلغاء</a>
                            <button type="submit" class="btn btn-primary px-4" id="submitBtn">حفظ الميزانية</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
(function () {
    'use strict';
    const maxAvailable = {{ $available['available_to_allocate'] ?? 'null' }};
    const input = document.getElementById('allocatedAmount');
    const hint = document.getElementById('maxHint');
    const form = document.getElementById('budgetForm');
    const btn = document.getElementById('submitBtn');

    if (maxAvailable !== null && input && hint) {
        input.addEventListener('input', function () {
            const v = parseFloat(this.value) || 0;
            if (v > maxAvailable + 0.01) {
                hint.classList.remove('d-none');
                input.classList.add('is-invalid');
            } else {
                hint.classList.add('d-none');
                input.classList.remove('is-invalid');
            }
        });
    }

    if (form && btn) {
        form.addEventListener('submit', function (e) {
            if (maxAvailable !== null) {
                const v = parseFloat(input.value) || 0;
                if (v > maxAvailable + 0.01) {
                    e.preventDefault();
                    alert('المبلغ يتجاوز المتاح من الأصل');
                    return;
                }
            }
            btn.disabled = true;
            btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> جاري الحفظ...';
        });
    }
})();
</script>
@endpush
