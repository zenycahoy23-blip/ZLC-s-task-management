<template>
  <div class="py-12">
    <div class="container">
      <h1 class="text-3xl font-bold text-gray-900 mb-8">Dashboard</h1>

      <!-- Admin Dashboard -->
      <div v-if="isAdmin" class="space-y-8">
        <div class="grid grid-cols-1 gap-5 sm:grid-cols-4">
          <div class="card">
            <div class="flex items-baseline">
              <div class="text-5xl font-extrabold text-gray-900">
                {{ stats.total_users }}
              </div>
              <div class="ml-2 flex items-baseline text-sm font-semibold text-gray-500">
                Total Users
              </div>
            </div>
          </div>
          <div class="card">
            <div class="flex items-baseline">
              <div class="text-5xl font-extrabold text-gray-900">
                {{ stats.total_tasks }}
              </div>
              <div class="ml-2 flex items-baseline text-sm font-semibold text-gray-500">
                Total Tasks
              </div>
            </div>
          </div>
          <div class="card">
            <div class="flex items-baseline">
              <div class="text-5xl font-extrabold text-red-600">
                {{ stats.overdue_tasks }}
              </div>
              <div class="ml-2 flex items-baseline text-sm font-semibold text-gray-500">
                Overdue Tasks
              </div>
            </div>
          </div>
        </div>

        <div class="card">
          <h2 class="text-lg font-medium text-gray-900 mb-4">Tasks by Status</h2>
          <div class="flex space-x-4">
            <div v-for="item in stats.tasks_by_status" :key="item.status" class="flex items-center">
              <div class="text-2xl font-bold text-indigo-600">{{ item.count }}</div>
              <div class="ml-2 text-sm text-gray-500">{{ item.status }}</div>
            </div>
          </div>
        </div>
      </div>

      <!-- Manager Dashboard -->
      <div v-else-if="isManager" class="space-y-8">
        <div class="grid grid-cols-1 gap-5 sm:grid-cols-3">
          <div class="card">
            <div class="flex items-baseline">
              <div class="text-5xl font-extrabold text-gray-900">
                {{ stats.team_tasks }}
              </div>
              <div class="ml-2 flex items-baseline text-sm font-semibold text-gray-500">
                Team Tasks
              </div>
            </div>
          </div>
          <div class="card">
            <div class="flex items-baseline">
              <div class="text-5xl font-extrabold text-red-600">
                {{ stats.overdue_tasks }}
              </div>
              <div class="ml-2 flex items-baseline text-sm font-semibold text-gray-500">
                Overdue
              </div>
            </div>
          </div>
        </div>

        <div class="card">
          <h2 class="text-lg font-medium text-gray-900 mb-4">Tasks by Status</h2>
          <div class="flex space-x-4">
            <div v-for="item in stats.tasks_by_status" :key="item.status" class="flex items-center">
              <div class="text-2xl font-bold text-indigo-600">{{ item.count }}</div>
              <div class="ml-2 text-sm text-gray-500">{{ item.status }}</div>
            </div>
          </div>
        </div>
      </div>

      <!-- Member Dashboard -->
      <div v-else class="space-y-8">
        <div class="grid grid-cols-1 gap-5 sm:grid-cols-3">
          <div v-for="item in stats.my_tasks" :key="item.status" class="card">
            <div class="flex items-baseline">
              <div class="text-5xl font-extrabold text-indigo-600">
                {{ item.count }}
              </div>
              <div class="ml-2 flex items-baseline text-sm font-semibold text-gray-500">
                {{ item.status }}
              </div>
            </div>
          </div>
        </div>

        <div v-if="stats.upcoming_deadlines && stats.upcoming_deadlines.length" class="card">
          <h2 class="text-lg font-medium text-gray-900 mb-4">Upcoming Deadlines</h2>
          <div class="space-y-2">
            <div
              v-for="task in stats.upcoming_deadlines"
              :key="task.id"
              class="flex items-center justify-between py-2"
            >
              <div>
                <p class="text-sm font-medium text-gray-900">{{ task.title }}</p>
                <p class="text-xs text-gray-500">{{ formatDate(task.due_date) }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const auth = useAuth();
const api = useApi();

definePageMeta({
  middleware: ['auth'],
});

const stats = ref({});

const isAdmin = computed(() => auth.user.value?.roles?.some((r) => r.name === 'admin') || false);
const isManager = computed(() => auth.user.value?.roles?.some((r) => r.name === 'manager') || false);

const formatDate = (date) => {
  return new Date(date).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  });
};

onMounted(async () => {
  try {
    const { data } = await api.get('/dashboard');
    stats.value = data;
  } catch (error) {
    console.error('Error loading dashboard:', error);
  }
});
</script>
