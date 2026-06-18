<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class RoleAndPermissionSeeder extends Seeder
{
    public function run(): void
    {
        // Create roles
        Role::firstOrCreate(['name' => 'admin']);
        Role::firstOrCreate(['name' => 'manager']);
        Role::firstOrCreate(['name' => 'member']);

        // Create permissions
        $permissions = [
            'manage-users',
            'create-task',
            'assign-task',
            'update-task-status',
            'update-task',
            'delete-task',
            'view-all-tasks',
            'view-own-tasks',
            'manage-categories',
            'view-logs',
        ];

        foreach ($permissions as $permission) {
            Permission::firstOrCreate(['name' => $permission]);
        }

        // Assign permissions to roles
        $admin = Role::firstWhere('name', 'admin');
        $admin->syncPermissions($permissions);

        $manager = Role::firstWhere('name', 'manager');
        $manager->syncPermissions([
            'create-task',
            'assign-task',
            'update-task',
            'delete-task',
            'manage-categories',
            'view-all-tasks',
        ]);

        $member = Role::firstWhere('name', 'member');
        $member->syncPermissions([
            'update-task-status',
            'view-own-tasks',
        ]);
    }
}
