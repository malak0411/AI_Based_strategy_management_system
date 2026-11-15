<?php

namespace App\Http\Controllers;

use App\Services\ApiClient;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class BudgetController extends Controller
{
    protected $apiClient;

    public function __construct(ApiClient $apiClient)
    {
        $this->apiClient = $apiClient;
    }

    private function isAuthorized(): bool
    {
        $role = session('user_role', 'employee');
        return in_array($role, ['manager', 'general_manager', 'deputy', 'minister', 'admin', 'super_admin']);
    }

    private function isApprover(): bool
    {
        return in_array(session('user_role'), ['minister','deputy']);
    }

    public function index(Request $request)
    {
        try {
            $token = session('jwt_token');
            if (!$token) return redirect()->route('login')->with('error', 'الرجاء تسجيل الدخول أولاً');

            $params = [];
            if ($request->filled('fiscal_year')) $params['fiscal_year'] = $request->fiscal_year;

            $treeResponse = $this->apiClient->get('/api/budget/hierarchy', $token, $params);
            $tree = $treeResponse['data'] ?? [];

            $summaryResponse = $this->apiClient->get('/api/budget/summary', $token, $params);
            $summary = $summaryResponse ?? [];

            $optionsResponse = $this->apiClient->get('/api/budget/options', $token);
            $options = $optionsResponse ?? [];

            return view('budget.index', compact('tree', 'summary', 'options'));
        } catch (\Exception $e) {
            Log::error('Budget index error: ' . $e->getMessage());
            return back()->with('error', 'حدث خطأ أثناء تحميل البيانات المالية');
        }
    }

    public function create(Request $request)
    {
        try {
            $token = session('jwt_token');
            if (!$this->isAuthorized()) {
                return redirect()->route('budget.index')->with('error', 'غير مصرح');
            }

            $options = $this->apiClient->get('/api/budget/options', $token) ?? [];

            $type = $request->query('type');
            $id = $request->query('id');
            $fiscalYear = (int) $request->query('fiscal_year', date('Y'));

            $available = null;
            if ($type && $id) {
                $available = $this->apiClient->get(
                    "/api/budget/available?budgetable_type={$type}&budgetable_id={$id}&fiscal_year={$fiscalYear}",
                    $token
                );
            }

            return view('budget.create', [
                'options' => $options,
                'type' => $type,
                'id' => $id,
                'name' => $request->query('name'),
                'available' => $available,
                'fiscalYear' => $fiscalYear,
            ]);
        } catch (\Exception $e) {
            Log::error('Budget create error: ' . $e->getMessage());
            return back()->with('error', 'حدث خطأ');
        }
    }

    public function available(Request $request)
    {
        try {
            $token = session('jwt_token');
            $type = $request->query('budgetable_type');
            $id = $request->query('budgetable_id');
            $year = $request->query('fiscal_year', date('Y'));

            $response = $this->apiClient->get(
                "/api/budget/available?budgetable_type={$type}&budgetable_id={$id}&fiscal_year={$year}",
                $token
            );
            return response()->json($response);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function store(Request $request)
    {
        try {
            $token = session('jwt_token');
            if (!$this->isAuthorized()) return back()->with('error', 'غير مصرح');

            $request->validate([
                'budgetable_type' => 'required|in:program,initiative,major_task,operational_task',
                'budgetable_id' => 'required|integer',
                'fiscal_year' => 'required|integer',
                'allocated_amount' => 'required|numeric|min:0',
            ]);

            $data = [
                'budgetable_type' => $request->budgetable_type,
                'budgetable_id' => (int) $request->budgetable_id,
                'department_id' => $request->department_id ? (int) $request->department_id : null,
                'fiscal_year' => (int) $request->fiscal_year,
                'allocated_amount' => (float) $request->allocated_amount,
            ];

            $response = $this->apiClient->post('/api/budget', $data, $token);

            if ($response['success'] ?? false) {
                return redirect()->route('budget.index')->with('success', 'تم إنشاء الميزانية بنجاح');
            }

            return back()->withInput()->with('error', $response['detail'] ?? 'فشل الحفظ');
        } catch (\Exception $e) {
            return back()->withInput()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    public function edit($id)
    {
        try {
            $token = session('jwt_token');
            $budget = $this->apiClient->get("/api/budget/{$id}", $token) ?? [];
            $options = $this->apiClient->get('/api/budget/options', $token) ?? [];

            return view('budget.edit', compact('budget', 'options'));
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ');
        }
    }

    public function update(Request $request, $id)
    {
        try {
            $token = session('jwt_token');
            if (!$this->isAuthorized()) return back()->with('error', 'غير مصرح');

            $request->validate([
                'allocated_amount' => 'required|numeric|min:0',
                'fiscal_year' => 'required|integer',
            ]);

            $data = [
                'allocated_amount' => (float) $request->allocated_amount,
                'department_id' => $request->department_id ? (int) $request->department_id : null,
                'fiscal_year' => (int) $request->fiscal_year,
            ];

            $response = $this->apiClient->put("/api/budget/{$id}", $data, $token);

            if ($response['success'] ?? false) {
                return redirect()->route('budget.index')->with('success', 'تم التحديث بنجاح');
            }

            return back()->withInput()->with('error', $response['detail'] ?? 'فشل التحديث');
        } catch (\Exception $e) {
            return back()->withInput()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    public function show($id)
    {
        try {
            $token = session('jwt_token');
            $budget = $this->apiClient->get("/api/budget/{$id}", $token) ?? [];
            $transactionsResponse = $this->apiClient->get("/api/budget/{$id}/transactions", $token);

            return view('budget.show', [
                'budget' => $budget,
                'transactions' => $transactionsResponse['data'] ?? []
            ]);
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ');
        }
    }

    public function transactions($id)
    {
        try {
            $token = session('jwt_token');
            $budget = $this->apiClient->get("/api/budget/{$id}", $token) ?? [];
            $response = $this->apiClient->get("/api/budget/{$id}/transactions", $token);

            return view('budget.transactions', [
                'budget' => $budget,
                'transactions' => $response['data'] ?? [],
                'pagination' => $response
            ]);
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ');
        }
    }

    public function createTransaction($id)
    {
        try {
            $token = session('jwt_token');
            $budget = $this->apiClient->get("/api/budget/{$id}", $token) ?? [];
            $options = $this->apiClient->get('/api/budget/options', $token) ?? [];

            return view('budget.transactions-create', compact('budget', 'options'));
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ');
        }
    }

    public function storeTransaction(Request $request, $id)
    {
        try {
            $token = session('jwt_token');

            $request->validate([
                'amount' => 'required|numeric|min:0.01',
                'transaction_type_id' => 'required|integer',
                'description' => 'required|string|max:500',
                'transaction_date' => 'nullable|date',
            ]);

            $data = [
                'amount' => (float) $request->amount,
                'transaction_type_id' => (int) $request->transaction_type_id,
                'description' => $request->description,
                'transaction_date' => $request->transaction_date ?? date('Y-m-d')
            ];

            $response = $this->apiClient->post("/api/budget/{$id}/transactions", $data, $token);

            if ($response['success'] ?? false) {
                $msg = ($response['needs_approval'] ?? false)
                    ? 'تم تسجيل العملية — بانتظار الاعتماد'
                    : 'تم تسجيل العملية';
                return redirect()->route('budget.transactions', $id)->with('success', $msg);
            }

            return back()->withInput()->with('error', $response['detail'] ?? 'فشل التسجيل');
        } catch (\Exception $e) {
            return back()->withInput()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    public function showTransaction($transactionId)
    {
        try {
            $token = session('jwt_token');
            if (!$token) return redirect()->route('login')->with('error', 'الرجاء تسجيل الدخول أولاً');

            $response = $this->apiClient->get("/api/budget/transactions/{$transactionId}", $token);
            $transaction = $response ?? [];

            if (empty($transaction) || isset($transaction['detail'])) {
                return redirect()->route('budget.index')->with('error', 'العملية غير موجودة');
            }

            return view('budget.transactions-show', compact('transaction'));
        } catch (\Exception $e) {
            Log::error('Budget show transaction error: ' . $e->getMessage());
            return back()->with('error', 'حدث خطأ أثناء تحميل العملية');
        }
    }

    public function destroyTransaction($transactionId)
    {
        try {
            $token = session('jwt_token');
            $response = $this->apiClient->delete("/api/budget/transactions/{$transactionId}", $token);

            if ($response['success'] ?? false) {
                return response()->json(['success' => true, 'message' => 'تم حذف العملية']);
            }

            return response()->json(['success' => false, 'error' => $response['detail'] ?? 'فشل الحذف'], 400);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'error' => $e->getMessage()], 500);
        }
    }

    public function approvalsCount()
    {
        try {
            $token = session('jwt_token');
            if (!$token) return response()->json(['success' => false, 'count' => 0], 401);

            $response = $this->apiClient->get('/api/budget/approvals/count', $token);
            return response()->json(['success' => true, 'count' => $response['count'] ?? 0]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'count' => 0], 500);
        }
    }

    public function approvals(Request $request)
    {
        try {
            $token = session('jwt_token');
            if (!$token) return redirect()->route('login')->with('error', 'الرجاء تسجيل الدخول أولاً');

            if (!$this->isApprover()) {
                return redirect()->route('budget.index')->with('error', 'غير مصرح — هذه الصفحة للوزير فقط');
            }

            $params = [];
            if ($request->filled('page')) $params['page'] = (int) $request->page;
            if ($request->filled('min_amount')) $params['min_amount'] = (float) $request->min_amount;
            if ($request->filled('budgetable_type')) $params['budgetable_type'] = $request->budgetable_type;

            $query = http_build_query($params);
            $url = '/api/budget/approvals/pending' . ($query ? '?' . $query : '');

            $response = $this->apiClient->get($url, $token);

            return view('budget.approvals', [
                'transactions' => $response['data'] ?? [],
                'stats' => $response['stats'] ?? [],
                'pagination' => $response,
                'filters' => [
                    'min_amount' => $request->min_amount,
                    'budgetable_type' => $request->budgetable_type,
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('Budget approvals error: ' . $e->getMessage());
            return back()->with('error', 'حدث خطأ أثناء تحميل طلبات الاعتماد');
        }
    }

    public function approveTransaction($transactionId)
    {
        try {
            $token = session('jwt_token');

            if (!$this->isApprover()) {
                return response()->json(['success' => false, 'error' => 'غير مصرح — الاعتماد للوزير فقط'], 403);
            }

            $response = $this->apiClient->post(
                "/api/budget/transactions/{$transactionId}/approve",
                [],
                $token
            );

            if ($response['success'] ?? false) {
                Log::info('Budget transaction approved', [
                    'transaction_id' => $transactionId,
                    'by' => session('user_id'),
                ]);
                return response()->json(['success' => true, 'message' => $response['message'] ?? 'تم الاعتماد']);
            }

            return response()->json([
                'success' => false,
                'error' => $response['detail'] ?? $response['message'] ?? 'فشل الاعتماد',
            ], 400);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'error' => $e->getMessage()], 500);
        }
    }

    public function rejectTransaction(Request $request, $transactionId)
    {
        try {
            $token = session('jwt_token');

            if (!$this->isApprover()) {
                return response()->json(['success' => false, 'error' => 'غير مصرح — الرفض للوزير فقط'], 403);
            }

            $request->validate([
                'reason' => 'required|string|min:5|max:500',
            ]);

            $response = $this->apiClient->post(
                "/api/budget/approvals/{$transactionId}/reject",
                ['reason' => $request->reason],
                $token
            );

            if ($response['success'] ?? false) {
                Log::warning('Budget transaction rejected', [
                    'transaction_id' => $transactionId,
                    'by' => session('user_id'),
                    'reason' => $request->reason,
                ]);
                return response()->json(['success' => true, 'message' => $response['message'] ?? 'تم الرفض']);
            }

            return response()->json([
                'success' => false,
                'error' => $response['detail'] ?? $response['message'] ?? 'فشل الرفض',
            ], 400);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json(['success' => false, 'error' => $e->getMessage()], 422);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'error' => $e->getMessage()], 500);
        }
    }
}
