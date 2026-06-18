<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\AuditLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $credentials['email'])->first();

        if (!$user || !Hash::check($credentials['password'], $user->password)) {
            AuditLog::log(
                action: 'LOGIN_FAILED',
                description: 'Failed login attempt for email: ' . $credentials['email'],
                userId: null,
                ipAddress: $request->ip()
            );
            
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        if ($user->account_locked) {
            return response()->json(['message' => 'Account is locked'], 403);
        }

        $token = $user->createToken('api-token')->plainTextToken;

        AuditLog::log(
            action: 'LOGIN',
            description: 'User logged in',
            userId: $user->id,
            ipAddress: $request->ip()
        );

        return response()->json([
            'message' => 'Login successful',
            'user' => $user->load('role'),
            'token' => $token,
        ]);
    }

    public function logout(Request $request)
    {
        $user = $request->user();
        
        AuditLog::log(
            action: 'LOGOUT',
            description: 'User logged out',
            userId: $user->id,
            ipAddress: $request->ip()
        );

        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logout successful']);
    }

    public function user(Request $request)
    {
        return response()->json($request->user()->load('role'));
    }
}
