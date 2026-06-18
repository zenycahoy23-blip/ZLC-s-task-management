<template>
  <div class="py-12">
    <div class="container">
      <div class="flex justify-between items-center mb-8">
        <h1 class="text-3xl font-bold text-gray-900">Tasks</h1>
        <NuxtLink to="/tasks/create" class="btn">
          Create Task
        </NuxtLink>
      </div>

      <!-- Filters -->
      <div class="card mb-6 space-y-4">
        <div class="grid grid-cols-1 gap-4 sm:grid-cols-4">
          <div>
            <label class="block text-sm font-medium text-gray-700">Status</label>
            <select
              v-model="filters.status"
              @change="fetchTasks"
              class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
            >
              <option value="">All</option>
              <option value="todo">To Do</option>
              <option value="in_progress">In Progress</option>
              <option value="done">Done</option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700">Priority</label>
            <select
              v-model="filters.priority"
              @change="fetchTasks"
              class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
            >
              <option value="">All</option>
              <option value="low">Low</option>
              <option value="medium">Medium</option>
              <option value="high">High</option>
            </select>
          </div>
        </div>
      </div>

      <!-- Tasks List -->
      <div class="space-y-4">
        <div
          v-for="task in tasks"
          :key="task.id"
          class="card hover:shadow-lg transition-shadow cursor-pointer"
          @click="navigateTo(`/tasks/${task.id}`)"
        >
          <div class="flex items-start justify-between">
            <div class="flex-1">
              <h3 class="text-lg font-medium text-gray-900">{{ task.title }}</h3>
              <p class="mt-1 text-sm text-gray-600">{{ task.description }}</p>
              <div class="mt-2 flex items-center space-x-4">
                <span class="badge" :class="getPriorityClass(task.priority)">
                  {{ task.priority }}
                </span>
                <span class="badge" :class="getStatusClass(task.status)">
                  {{ task.status }}
                </span>
                <span v-if="task.category" class="text-sm text-gray-500">
                  {{ task.category.category_name }}
                </span>
                <span v-if="task.due_date" class="text-sm text-gray-500">
                  Due: {{ formatDate(task.due_date) }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const api = useApi();

definePageMeta({
  middleware: ['auth'],
});

const tasks = ref([]);
const filters = reactive({
  status: '',
  priority: '',
});

const getPriorityClass = (priority) => {
  switch (priority) {
    case 'high':
      return 'badge-danger';
    case 'medium':
      return 'badge-warning';
    case 'low':
      return 'badge-success';
    default:
      return '';
  }
};

const getStatusClass = (status) => {
  switch (status) {
    case 'done':
      return 'badge-success';
    case 'in_progress':
      return 'badge-warning';
    case 'todo':
      return 'badge-danger';
    default:
      return '';
  }
};

const formatDate = (date) => {
  return new Date(date).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  });
};

const fetchTasks = async () => {
  try {
    const params = new URLSearchParams();
    if (filters.status) params.append('status', filters.status);
    if (filters.priority) params.append('priority', filters.priority);

    const { data } = await api.get(`/tasks?${params}`);
    tasks.value = data.data || data;
  } catch (error) {
    console.error('Error loading tasks:', error);
  }
};

onMounted(fetchTasks);
</script>
