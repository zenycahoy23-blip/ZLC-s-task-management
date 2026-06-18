<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Task;
use App\Models\Category;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use Spatie\Permission\Models\Role;

class TaskPermissionTest extends RefreshDatabase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        // Create roles
        Role::firstOrCreate(['name' => 'admin']);
        Role::firstOrCreate(['name' => 'manager']);
        Role::firstOrCreate(['name' => 'member']);
    }

    public function test_admin_can_create_task()
    {
        $admin = User::factory()->create();
        $admin->assignRole('admin');

        $response = $this->actingAs($admin)->postJson('/api/tasks', [
            'title' => 'Test Task',
            'description' => 'Test Description',
            'priority' => 'high',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('title', 'Test Task');
    }

    public function test_manager_can_create_task()
    {
        $manager = User::factory()->create();
        $manager->assignRole('manager');

        $response = $this->actingAs($manager)->postJson('/api/tasks', [
            'title' => 'Test Task',
            'description' => 'Test Description',
            'priority' => 'medium',
        ]);

        $response->assertStatus(201);
    }

    public function test_member_cannot_create_task()
    {
        $member = User::factory()->create();
        $member->assignRole('member');

        $response = $this->actingAs($member)->postJson('/api/tasks', [
            'title' => 'Test Task',
            'priority' => 'low',
        ]);

        $response->assertStatus(403);
    }

    public function test_member_can_update_task_status_only()
    {
        $member = User::factory()->create();
        $member->assignRole('member');

        $creator = User::factory()->create();
        $task = Task::factory()->create([
            'created_by' => $creator->id,
            'assigned_to' => $member->id,
            'status' => 'todo',
        ]);

        $response = $this->actingAs($member)->putJson("/api/tasks/{$task->id}", [
            'status' => 'in_progress',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('status', 'in_progress');

        // Try to update title - should fail
        $response = $this->actingAs($member)->putJson("/api/tasks/{$task->id}", [
            'title' => 'New Title',
            'status' => 'in_progress',
        ]);

        $response->assertStatus(422);
    }

    public function test_task_creation_triggers_notification()
    {
        $manager = User::factory()->create();
        $manager->assignRole('manager');

        $member = User::factory()->create();

        $this->actingAs($manager)->postJson('/api/tasks', [
            'title' => 'Test Task',
            'assigned_to' => $member->id,
        ]);

        $this->assertDatabaseHas('notifications', [
            'user_id' => $member->id,
            'message' => "You have been assigned a new task: Test Task",
        ]);
    }

    public function test_task_activity_is_logged()
    {
        $manager = User::factory()->create();
        $manager->assignRole('manager');

        $response = $this->actingAs($manager)->postJson('/api/tasks', [
            'title' => 'Test Task',
            'description' => 'Test',
            'priority' => 'high',
        ]);

        $task = Task::find($response->json('id'));
        $activities = $task->activities()->get();

        $this->assertTrue($activities->count() > 0);
        $this->assertEquals('created', $activities->first()->event);
    }
}
