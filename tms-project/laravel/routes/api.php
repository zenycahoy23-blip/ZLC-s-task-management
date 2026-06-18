<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\TaskController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\ActivityLogController;

// Public endpoints
Route::post('/login', [AuthController::class, 'login']);
Route::get('/health', function () {
    return response()->json(['status' => 'healthy']);
});

// Protected endpoints
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);

    Route::get('/dashboard/stats', [DashboardController::class, 'stats']);

    Route::apiResource('/tasks', TaskController::class);
    Route::patch('/tasks/{task}/status', [TaskController::class, 'updateStatus']);
    
    Route::apiResource('/categories', CategoryController::class);
    Route::apiResource('/users', UserController::class);

    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::put('/notifications/{notification}/read', [NotificationController::class, 'markAsRead']);
    Route::get('/notifications/unread-count', [NotificationController::class, 'unreadCount']);

    Route::get('/audit-logs', [ActivityLogController::class, 'index']);
});

// Metrics endpoint for Prometheus
Route::get('/metrics', function () {
    // Prometheus metrics endpoint
    $totalTasks = \App\Models\Task::count();
    $totalUsers = \App\Models\User::count();
    $completedTasks = \App\Models\Task::where('status', 'done')->count();
    
    $metrics = "# HELP tms_total_tasks Total number of tasks\n";
    $metrics .= "# TYPE tms_total_tasks gauge\n";
    $metrics .= "tms_total_tasks {$totalTasks}\n\n";
    $metrics .= "# HELP tms_total_users Total number of users\n";
    $metrics .= "# TYPE tms_total_users gauge\n";
    $metrics .= "tms_total_users {$totalUsers}\n\n";
    $metrics .= "# HELP tms_completed_tasks Total number of completed tasks\n";
    $metrics .= "# TYPE tms_completed_tasks gauge\n";
    $metrics .= "tms_completed_tasks {$completedTasks}\n";
    
    return response($metrics)->header('Content-Type', 'text/plain');
});

