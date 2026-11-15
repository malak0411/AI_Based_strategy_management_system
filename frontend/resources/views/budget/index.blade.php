@extends('layouts.app')

@section('title', 'الميزانية والهيكل الاستراتيجي')

@push('styles')
<style>
    .kpi-card { border-right: 4px solid; transition: transform 0.2s; }
    .kpi-card:hover { transform: translateY(-3px); }
    .bg-navy { background-color: #1a1a2e; color: white; }
    .text-navy { color: #1a1a2e; }
    .progress-thin { height: 8px; border-radius: 4px; }
    .budget-node { border-right: 3px solid #cbd5e0; margin-right: 12px; padding-right: 12px; }
    .budget-node.program  { border-color: #1a4a8a; }
    .budget-node.initiative { border-color: #3182ce; }
    .budget-node.major-task { border-color: #d4af37; }
    .budget-node.op-task  { border-color: #38a169; }
    .node-title { font-weight: 700; font-size: 14px; }
    .node-meta { font-size: 11px; color: #6c757d; }
    .mini-rollup { background: #f8fafc; border-radius: 6px; padding: 6px 10px; font-size: 11px; }
    .allocate-btn { font-size: 11px; padding: 3px 10px; }
</style>
@endpush

@section('content')
<div class="container-fluid px-4 py-3" dir="rtl">

    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
        <div>
            <h3 class="fw-bold text-navy mb-1"><i class="fas fa-landmark ml-2"></i> الخريطة المالية والاستراتيجية</h3>
            <p class="text-muted mb-0">تخصيص ومتابعة الميزانيات عبر الهيكل الاستراتيجي</p>
        </div>
        <form action="{{ route('budget.index') }}" method="GET" class="d-flex gap-2">
            <select name="fiscal_year" class="form-select" onchange="this.form.submit()">
                <option value="">كل السنوات المالية</option>
                @foreach($options['fiscal_years'] ?? [] as $year)
                    <option value="{{ $year }}" {{ request('fiscal_year') == $year ? 'selected' : '' }}>سنة {{ $year }}</option>
                @endforeach
            </select>
        </form>
    </div>

    @if(session('success'))
        <div class="alert alert-success alert-dismissible fade show">{{ session('success') }}<button class="btn-close" data-bs-dismiss="alert"></button></div>
    @endif
    @if(session('error'))
        <div class="alert alert-danger alert-dismissible fade show">{{ session('error') }}<button class="btn-close" data-bs-dismiss="alert"></button></div>
    @endif

    <div class="row g-3 mb-4">
        <div class="col-md-3">
            <div class="card shadow-sm kpi-card border-primary">
                <div class="card-body">
                    <h6 class="text-muted mb-1">إجمالي الميزانية المعتمدة</h6>
                    <h4 class="fw-bold text-primary mb-0">{{ number_format($summary['total_allocated'] ?? 0, 2) }} <small>ريال</small></h4>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card shadow-sm kpi-card border-danger">
                <div class="card-body">
                    <h6 class="text-muted mb-1">إجمالي المصروفات</h6>
                    <h4 class="fw-bold text-danger mb-0">{{ number_format($summary['total_spent'] ?? 0, 2) }} <small>ريال</small></h4>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card shadow-sm kpi-card border-success">
                <div class="card-body">
                    <h6 class="text-muted mb-1">الرصيد المتبقي</h6>
                    <h4 class="fw-bold text-success mb-0">{{ number_format($summary['total_remaining'] ?? 0, 2) }} <small>ريال</small></h4>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card shadow-sm kpi-card border-warning">
                <div class="card-body">
                    <h6 class="text-muted mb-1">نسبة التنفيذ الكلية</h6>
                    <h4 class="fw-bold text-warning mb-2">{{ $summary['execution_percentage'] ?? 0 }}%</h4>
                    <div class="progress progress-thin">
                        <div class="progress-bar bg-warning" style="width: {{ min(100, $summary['execution_percentage'] ?? 0) }}%"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    @if(($summary['pending_approvals'] ?? 0) > 0)
        <div class="alert alert-warning d-flex align-items-center">
            <i class="fas fa-hourglass-half ml-2 fa-lg"></i>
            <strong>يوجد {{ $summary['pending_approvals'] }} حركة مالية بانتظار الاعتماد.</strong>
        </div>
    @endif

    <div class="accordion shadow-sm" id="programTree">
        @foreach($tree as $program)
            <div class="accordion-item mb-2 border rounded">
                <h2 class="accordion-header">
                    <button class="accordion-button collapsed bg-white" type="button" data-bs-toggle="collapse" data-bs-target="#prog{{ $program['id'] }}">
                        <div class="d-flex w-100 justify-content-between align-items-center pe-4">
                            <div>
                                <strong class="fs-5 text-navy"><i class="fas fa-layer-group ml-2"></i> {{ $program['name'] }}</strong>
                                <div class="small text-muted mt-1">
                                    <span class="badge bg-secondary">الركيزة: {{ $program['strategic_pillar'] }}</span>
                                    <span class="badge bg-secondary">الهدف: {{ $program['strategic_goal'] }}</span>
                                </div>
                            </div>
                            <div class="text-start ms-4">
                                <div class="mini-rollup">
                                    <div><strong>المخصص الكلي:</strong> <span class="text-primary">{{ number_format($program['total_allocated'], 2) }}</span></div>
                                    <div><strong>المصروف:</strong> <span class="text-danger">{{ number_format($program['total_spent'], 2) }}</span></div>
                                    <div><strong>المتبقي:</strong> <span class="text-success">{{ number_format($program['total_remaining'], 2) }}</span></div>
                                </div>
                            </div>
                        </div>
                    </button>
                </h2>
                <div id="prog{{ $program['id'] }}" class="accordion-collapse collapse">
                    <div class="accordion-body bg-light p-2">
                        <div class="d-flex gap-2 mb-2 flex-wrap">
                            @if($program['budget_id'])
                                <a href="{{ route('budget.transactions', $program['budget_id']) }}" class="btn btn-sm btn-outline-primary">
                                    <i class="fas fa-list"></i> حركات
                                </a>
                                <a href="{{ route('budget.show', $program['budget_id']) }}" class="btn btn-sm btn-outline-info">
                                    <i class="fas fa-file-invoice"></i> كشف
                                </a>
                            @elseif($program['can_allocate'])
                                <a href="{{ route('budget.create', ['type' => 'program', 'id' => $program['id'], 'name' => $program['name']]) }}" class="btn btn-sm btn-outline-success">
                                    <i class="fas fa-plus"></i> تخصيص ميزانية البرنامج
                                </a>
                            @endif
                        </div>

                        @foreach($program['initiatives'] as $init)
                            <div class="budget-node initiative mb-2">
                                <div class="d-flex justify-content-between align-items-center p-2 bg-white rounded">
                                    <div>
                                        <i class="fas fa-flag text-info ml-1"></i>
                                        <strong>{{ $init['name'] }}</strong>
                                        <div class="node-meta">
                                            مخصص ذاتي: {{ number_format($init['direct_allocated'], 2) }}
                                            | إجمالي: <strong class="text-primary">{{ number_format($init['total_allocated'], 2) }}</strong>
                                            | متبقي: <strong class="text-success">{{ number_format($init['total_remaining'], 2) }}</strong>
                                        </div>
                                    </div>
                                    <div class="d-flex gap-1">
                                        @if($init['budget_id'])
                                            <a href="{{ route('budget.transactions', $init['budget_id']) }}" class="btn btn-sm btn-outline-primary">
                                                <i class="fas fa-list"></i>
                                            </a>
                                        @elseif($init['can_allocate'])
                                            <a href="{{ route('budget.create', ['type' => 'initiative', 'id' => $init['id'], 'name' => $init['name']]) }}" class="btn btn-sm btn-outline-success allocate-btn">
                                                <i class="fas fa-plus"></i> ميزانية
                                            </a>
                                        @endif
                                    </div>
                                </div>

                                @if(count($init['major_tasks']) > 0)
                                    <table class="table table-sm table-hover mb-0 text-center mt-2" style="font-size:13px">
                                        <thead class="table-light">
                                            <tr>
                                                <th>المهمة الرئيسية</th>
                                                <th>مخصص ذاتي</th>
                                                <th>إجمالي (مع الأبناء)</th>
                                                <th>مصروف</th>
                                                <th>متبقي</th>
                                                <th>إجراءات</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            @foreach($init['major_tasks'] as $mt)
                                                <tr>
                                                    <td class="text-start">
                                                        <i class="fas fa-tasks text-secondary ml-1"></i> {{ $mt['name'] }}
                                                        <button class="btn btn-link btn-sm p-0 ms-1" data-bs-toggle="collapse" data-bs-target="#mt{{ $mt['id'] }}"><i class="fas fa-eye text-primary"></i></button>
                                                    </td>
                                                    <td>{{ number_format($mt['direct_allocated'], 2) }}</td>
                                                    <td class="text-primary fw-bold">{{ number_format($mt['total_allocated'], 2) }}</td>
                                                    <td class="text-danger">{{ number_format($mt['total_spent'], 2) }}</td>
                                                    <td class="text-success">{{ number_format($mt['total_remaining'], 2) }}</td>
                                                    <td>
                                                        @if($mt['budget_id'])
                                                            <a href="{{ route('budget.transactions', $mt['budget_id']) }}" class="btn btn-sm btn-outline-primary"><i class="fas fa-list"></i></a>
                                                        @elseif($mt['can_allocate'])
                                                            <a href="{{ route('budget.create', ['type' => 'major_task', 'id' => $mt['id'], 'name' => $mt['name']]) }}" class="btn btn-sm btn-outline-success allocate-btn">
                                                                <i class="fas fa-plus"></i> ميزانية
                                                            </a>
                                                        @endif
                                                    </td>
                                                </tr>
                                                <tr class="collapse" id="mt{{ $mt['id'] }}">
                                                    <td colspan="6" class="p-0 bg-white">
                                                        <table class="table table-bordered table-sm mb-0 text-center" style="font-size:12px">
                                                            <thead class="table-secondary">
                                                                <tr>
                                                                    <th>المهمة التشغيلية</th>
                                                                    <th>الإدارة</th>
                                                                    <th>مخصص ذاتي</th>
                                                                    <th>مصروف</th>
                                                                    <th>متبقي</th>
                                                                    <th>إجراءات</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                @foreach($mt['operational_tasks'] as $ot)
                                                                    <tr>
                                                                        <td class="text-start ps-3">{{ $ot['name'] }}</td>
                                                                        <td>{{ $ot['department_name'] }}</td>
                                                                        <td>{{ number_format($ot['direct_allocated'], 2) }}</td>
                                                                        <td class="text-danger">{{ number_format($ot['direct_spent'], 2) }}</td>
                                                                        <td class="text-success">{{ number_format($ot['total_remaining'], 2) }}</td>
                                                                        <td>
                                                                            @if($ot['budget_id'])
                                                                                <a href="{{ route('budget.transactions', $ot['budget_id']) }}" class="btn btn-sm btn-outline-primary py-0"><i class="fas fa-list"></i></a>
                                                                            @elseif($ot['can_allocate'])
                                                                                <a href="{{ route('budget.create', ['type' => 'operational_task', 'id' => $ot['id'], 'name' => $ot['name']]) }}" class="btn btn-sm btn-outline-success py-0 allocate-btn"><i class="fas fa-plus"></i></a>
                                                                            @endif
                                                                        </td>
                                                                    </tr>
                                                                @endforeach
                                                            </tbody>
                                                        </table>
                                                    </td>
                                                </tr>
                                            @endforeach
                                        </tbody>
                                    </table>
                                @endif
                            </div>
                        @endforeach
                    </div>
                </div>
            </div>
        @endforeach
    </div>
</div>
@endsection
