<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\AuditLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    public function index(Request $request)
    {
        // Only admins can view all users
        if ($request->user()->role_id !== 1) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return response()->json(User::with('role')->paginate());
    }

    public function store(Request $request)
    {
        // Only admins can create users
        if ($request->user()->role_id !== 1) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users',
            'password' => 'required|string|min:8',
            'role_id' => 'required|in:1,2,3',
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'role_id' => $validated['role_id'],
        ]);

        AuditLog::log(
            action: 'USER_CREATED',
            description: "User created: {$user->name} ({$user->email})",
            userId: $request->user()->id,
            ipAddress: $request->ip()
        );

        return response()->json($user->load('role'), 201);
    }

    public function show(User $user)
    {
        return response()->json($user->load('role'));
    }

    public function update(Request $request, User $user)
    {
        // Only admins can update users
        if ($request->user()->role_id !== 1) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'name' => 'string|max:255',
            'email' => 'email|unique:users,email,' . $user->id,
            'role_id' => 'in:1,2,3',
            'account_locked' => 'boolean',
        ]);

        $user->update($validated);

        AuditLog::log(
            action: 'USER_UPDATED',
            description: "User updated: {$user->name}",
            userId: $request->user()->id,
            ipAddress: $request->ip()
        );

        return response()->json($user->load('role'));
    }

    public function destroy(Request $request, User $user)
    {
        // Only admins can delete users
        if ($request->user()->role_id !== 1) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        AuditLog::log(
            action: 'USER_DELETED',
            description: "User deleted: {$user->name}",
            userId: $request->user()->id,
            ipAddress: $request->ip()
        );

        $user->delete();
        return response()->json(['message' => 'User deleted']);
    }
}
