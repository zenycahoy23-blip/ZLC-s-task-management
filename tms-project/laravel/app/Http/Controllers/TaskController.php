<?php

namespace App\Http\Controllers;

use App\Models\Task;
use App\Models\Notification;
use App\Models\AuditLog;
use Illuminate\Http\Request;

class TaskController extends Controller
{
    public function index(Request $request)
    {
        $query = Task::query();

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('priority')) {
            $query->where('priority', $request->priority);
        }

        if ($request->filled('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        if ($request->filled('assigned_to')) {
            $query->where('assigned_to', $request->assigned_to);
        }

        if ($request->filled('due_date')) {
            $query->whereDate('due_date', $request->due_date);
        }

        // Non-admins see only their own tasks or tasks assigned to them
        if ($request->user()->role_id !== 1) { // 1 = Admin
            $query->where(function ($q) use ($request) {
                $q->where('created_by', $request->user()->id)
                  ->orWhere('assigned_to', $request->user()->id);
            });
        }

        return response()->json($query->with('category', 'assignee', 'creator')->paginate());
    }

    public function store(Request $request)
    {
        // Only Manager and Admin can create tasks
        if ($request->user()->role_id > 2) { // 1=Admin, 2=Manager, 3=Member
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'priority' => 'required|in:low,medium,high',
            'category_id' => 'nullable|exists:categories,id',
            'assigned_to' => 'nullable|exists:users,id',
            'due_date' => 'nullable|date_format:Y-m-d H:i:s',
        ]);

        $validated['created_by'] = $request->user()->id;
        $validated['status'] = 'todo';

        $task = Task::create($validated);

        // Notify assignee
        if ($task->assigned_to) {
            Notification::create([
                'user_id' => $task->assigned_to,
                'task_id' => $task->id,
                'message' => "You have been assigned a new task: {$task->title}",
            ]);
        }

        AuditLog::log(
            action: 'TASK_CREATED',
            description: "Task created: {$task->title}",
            userId: $request->user()->id,
            ipAddress: $request->ip()
        );

        return response()->json($task->load('category', 'assignee', 'creator'), 201);
    }

    public function show(Task $task)
    {
        return response()->json($task->load('category', 'assignee', 'creator'));
    }

    public function update(Request $request, Task $task)
    {
        $user = $request->user();

        // Members can only update status of their own tasks
        if ($user->role_id === 3) { // Member
            if ($task->assigned_to !== $user->id && $task->created_by !== $user->id) {
                return response()->json(['message' => 'Unauthorized'], 403);
            }
            $validated = $request->validate(['status' => 'required|in:todo,in_progress,done']);
        } else {
            // Manager and Admin can update everything
            $validated = $request->validate([
                'title' => 'string|max:255',
                'description' => 'nullable|string',
                'status' => 'in:todo,in_progress,done',
                'priority' => 'in:low,medium,high',
                'category_id' => 'nullable|exists:categories,id',
                'assigned_to' => 'nullable|exists:users,id',
                'due_date' => 'nullable|date_format:Y-m-d H:i:s',
            ]);
        }

        $task->update($validated);

        AuditLog::log(
            action: 'TASK_UPDATED',
            description: "Task updated: {$task->title}",
            userId: $user->id,
            ipAddress: $request->ip()
        );

        return response()->json($task->load('category', 'assignee', 'creator'));
    }

    public function updateStatus(Request $request, Task $task)
    {
        $user = $request->user();

        // Check if user can update this task
        if ($user->role_id === 3 && $task->assigned_to !== $user->id && $task->created_by !== $user->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate(['status' => 'required|in:todo,in_progress,done']);
        $task->update($validated);

        AuditLog::log(
            action: 'TASK_STATUS_UPDATED',
            description: "Task '{$task->title}' status changed to {$validated['status']}",
            userId: $user->id,
            ipAddress: $request->ip()
        );

        return response()->json($task);
    }

    public function destroy(Request $request, Task $task)
    {
        // Only Admin can delete tasks
        if ($request->user()->role_id !== 1) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        AuditLog::log(
            action: 'TASK_DELETED',
            description: "Task deleted: {$task->title}",
            userId: $request->user()->id,
            ipAddress: $request->ip()
        );

        $task->delete();
        return response()->json(['message' => 'Task deleted']);
    }
}
