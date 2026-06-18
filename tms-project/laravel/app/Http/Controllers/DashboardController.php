<?php

namespace App\Http\Controllers;

use App\Models\Task;
use App\Models\User;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function stats(Request $request)
    {
        $user = $request->user();

        // Admin dashboard
        if ($user->role_id === 1) {
            return response()->json([
                'total_users' => User::count(),
                'total_tasks' => Task::count(),
                'total_roles' => [
                    'admins' => User::where('role_id', 1)->count(),
                    'managers' => User::where('role_id', 2)->count(),
                    'members' => User::where('role_id', 3)->count(),
                ],
                'tasks_by_status' => Task::selectRaw('status, COUNT(*) as count')
                    ->groupBy('status')
                    ->get(),
                'tasks_by_priority' => Task::selectRaw('priority, COUNT(*) as count')
                    ->groupBy('priority')
                    ->get(),
                'overdue_tasks' => Task::where('due_date', '<', now())
                    ->where('status', '!=', 'done')
                    ->count(),
            ]);
        }

        // Manager dashboard
        if ($user->role_id === 2) {
            return response()->json([
                'team_tasks' => Task::where('created_by', $user->id)->count(),
                'my_tasks_assigned' => Task::where('assigned_to', $user->id)->count(),
                'tasks_by_assignee' => Task::where('created_by', $user->id)
                    ->selectRaw('assigned_to, COUNT(*) as count')
                    ->groupBy('assigned_to')
                    ->with('assignee')
                    ->get(),
                'tasks_by_status' => Task::where('created_by', $user->id)
                    ->selectRaw('status, COUNT(*) as count')
                    ->groupBy('status')
                    ->get(),
                'overdue_tasks' => Task::where('created_by', $user->id)
                    ->where('due_date', '<', now())
                    ->where('status', '!=', 'done')
                    ->count(),
            ]);
        }

        // Member dashboard
        return response()->json([
            'my_tasks' => Task::where('assigned_to', $user->id)
                ->selectRaw('status, COUNT(*) as count')
                ->groupBy('status')
                ->get(),
            'tasks_created_by_me' => Task::where('created_by', $user->id)->count(),
            'upcoming_deadlines' => Task::where('assigned_to', $user->id)
                ->where('status', '!=', 'done')
                ->where('due_date', '>=', now())
                ->where('due_date', '<=', now()->addDays(7))
                ->orderBy('due_date')
                ->limit(5)
                ->get(),
            'overdue_tasks' => Task::where('assigned_to', $user->id)
                ->where('due_date', '<', now())
                ->where('status', '!=', 'done')
                ->count(),
        ]);
    }
}
