<template>
  <div class="py-12">
    <div class="container">
      <div class="flex justify-between items-center mb-8">
        <h1 class="text-3xl font-bold text-gray-900">Users</h1>
        <button @click="showCreateModal = true" class="btn">
          Create User
        </button>
      </div>

      <div class="bg-white shadow overflow-hidden sm:rounded-lg">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="user in users" :key="user.id">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{{ user.name }}</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{{ user.email }}</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                {{ user.roles?.[0]?.name || 'N/A' }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm">
                <button
                  @click="editUser(user)"
                  class="text-indigo-600 hover:text-indigo-900 mr-4"
                >
                  Edit
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const api = useApi();

definePageMeta({
  middleware: ['auth'],
});

const users = ref([]);
const showCreateModal = ref(false);

const fetchUsers = async () => {
  try {
    const { data } = await api.get('/users');
    users.value = data.data || data;
  } catch (error) {
    console.error('Error loading users:', error);
  }
};

const editUser = (user) => {
  console.log('Edit user:', user);
  // TODO: Implement edit modal
};

onMounted(fetchUsers);
</script>
