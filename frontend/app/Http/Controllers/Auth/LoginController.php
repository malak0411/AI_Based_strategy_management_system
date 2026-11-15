
<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Services\ApiClient;
use Illuminate\Http\Request;

class LoginController extends Controller
{
    protected $apiClient;

    public function __construct()
    {
        $this->apiClient = new ApiClient();
    }

    public function showLoginForm()
    {
        return view('auth.login');
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $response = $this->apiClient->post('/api/auth/login', [
            'email' => $request->email,
            'password' => $request->password,
        ]);

        $data = $response['data'] ?? [];
        $token = $data['access_token'] ?? null;

        if ($token) {
            $roles = $data['roles'] ?? [];

            $roleType = match (true) {
                in_array('وزير / قيادة العليا', $roles) => 'minister',
                in_array('وكيل وزارة', $roles) => 'deputy',
                in_array('مدير عام', $roles) => 'general_manager',
                in_array('مدير إدارة', $roles) => 'manager',
                in_array('مشرف النظام', $roles) => 'super_admin',
                in_array('Super Admin', $roles) => 'super_admin',
                default => 'employee',
            };

            $request->session()->regenerate();

            session([
                'jwt_token' => $token,
                'user_role' => $roleType,
                'user_name' => $data['full_name'] ?? 'مستخدم',
                'user_email' => $data['email'] ?? $request->email,
                'user_department' => $data['department_name'] ?? '',
                'user_department_id' => $data['department_id'] ?? '',
                'user_id' => $data['employee_id'] ?? '',
            ]);

            if (in_array($roleType, ['general_manager', 'manager'])) {
                return redirect()->route('dashboard.manager');
            }

            if (in_array($roleType, ['minister', 'deputy'])) {
                return redirect()->route('dashboard.minister');
            }

            return redirect()->route('dashboard.employee');
        }

        return back()->withErrors([
            'email' => $response['detail'] ?? 'بيانات الدخول غير صحيحة',
        ])->withInput($request->except('password'));
    }

    public function logout()
    {
        session()->flush();

        return redirect()->route('login')->with(
            'success',
            'تم تسجيل الخروج'
        );
    }
}

