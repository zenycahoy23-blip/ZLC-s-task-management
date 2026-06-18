<template>
  <div class="py-12">
    <div class="container max-w-2xl">
      <div class="mb-6">
        <NuxtLink to="/tasks" class="text-indigo-600 hover:text-indigo-700">
          ← Back to Tasks
        </NuxtLink>
      </div>

      <div class="card">
        <h1 class="text-3xl font-bold text-gray-900 mb-6">{{ task.title }}</h1>

        <div class="space-y-6">
          <div>
            <label class="block text-sm font-medium text-gray-700">Description</label>
            <p class="mt-2 text-gray-600">{{ task.description }}</p>
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700">Status</label>
              <select
                v-model="form.status"
                class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
              >
                <option value="todo">To Do</option>
                <option value="in_progress">In Progress</option>
                <option value="done">Done</option>
              </select>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700">Priority</label>
              <select
                v-model="form.priority"
                class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
              >
                <option value="low">Low</option>
                <option value="medium">Medium</option>
                <option value="high">High</option>
              </select>
            </div>
          </div>

          <div v-if="canEdit" class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700">Category</label>
              <select
                v-model="form.category_id"
                class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
              >
                <option :value="null">None</option>
                <option v-for="cat in categories" :key="cat.id" :value="cat.id">
                  {{ cat.category_name }}
                </option>
              </select>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700">Assigned To</label>
              <select
                v-model="form.assigned_to"
                class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
              >
                <option :value="null">Unassigned</option>
                <option v-for="user in users" :key="user.id" :value="user.id">
                  {{ user.name }}
                </option>
              </select>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700">Due Date</label>
              <input
                v-model="form.due_date"
                type="datetime-local"
                class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
              />
            </div>
          </div>

          <div class="flex space-x-4">
            <button @click="handleUpdate" class="btn">
              {{ loading ? 'Saving...' : 'Update Task' }}
            </button>
            <button v-if="canDelete" @click="handleDelete" class="btn-secondary bg-red-50 text-red-700">
              Delete
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const route = useRoute();
const router = useRouter();
const api = useApi();
const auth = useAuth();

definePageMeta({
  middleware: ['auth'],
});

const task = ref({});
const categories = ref([]);
const users = ref([]);
const loading = ref(false);
const canEdit = ref(false);
const canDelete = ref(false);

const form = reactive({
  title: '',
  description: '',
  status: '',
  priority: '',
  category_id: null,
  assigned_to: null,
  due_date: '',
});

const handleUpdate = async () => {
  loading.value = true;
  try {
    const data = {
      status: form.status,
    };

    if (canEdit.value) {
      Object.assign(data, {
        title: form.title,
        description: form.description,
        priority: form.priority,
        category_id: form.category_id,
        assigned_to: form.assigned_to,
        due_date: form.due_date,
      });
    }

    await api.put(`/tasks/${route.params.id}`, data);
    await fetchTask();
  } catch (error) {
    console.error('Error updating task:', error);
  } finally {
    loading.value = false;
  }
};

const handleDelete = async () => {
  if (confirm('Are you sure?')) {
    try {
      await api.delete(`/tasks/${route.params.id}`);
      await router.push('/tasks');
    } catch (error) {
      console.error('Error deleting task:', error);
    }
  }
};

const fetchTask = async () => {
  try {
    const { data } = await api.get(`/tasks/${route.params.id}`);
    task.value = data;

    Object.assign(form, {
      title: data.title,
      description: data.description,
      status: data.status,
      priority: data.priority,
      category_id: data.category_id,
      assigned_to: data.assigned_to,
      due_date: data.due_date,
    });

    canEdit.value = auth.user.value?.roles?.some((r) =>
      ['admin', 'manager'].includes(r.name)
    );
    canDelete.value = auth.user.value?.roles?.some((r) =>
      ['admin', 'manager'].includes(r.name)
    );
  } catch (error) {
    console.error('Error loading task:', error);
  }
};

const fetchCategories = async () => {
  try {
    const { data } = await api.get('/categories');
    categories.value = data;
  } catch (error) {
    console.error('Error loading categories:', error);
  }
};

const fetchUsers = async () => {
  try {
    const { data } = await api.get('/users');
    users.value = data.data || data;
  } catch (error) {
    console.error('Error loading users:', error);
  }
};

onMounted(async () => {
  await fetchTask();
  await fetchCategories();
  await fetchUsers();
});
</script>
