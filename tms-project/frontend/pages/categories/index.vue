<template>
  <div class="py-12">
    <div class="container">
      <h1 class="text-3xl font-bold text-gray-900 mb-8">Categories</h1>

      <div class="grid grid-cols-1 gap-5 sm:grid-cols-3 mb-8">
        <div class="card">
          <label class="block text-sm font-medium text-gray-700">Category Name</label>
          <input
            v-model="newCategory.category_name"
            type="text"
            class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
          />
        </div>
        <div class="card">
          <label class="block text-sm font-medium text-gray-700">Description</label>
          <input
            v-model="newCategory.description"
            type="text"
            class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
          />
        </div>
        <div class="card flex items-end">
          <button @click="handleCreateCategory" class="btn w-full">
            Create Category
          </button>
        </div>
      </div>

      <div class="bg-white shadow overflow-hidden sm:rounded-lg">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Description</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="category in categories" :key="category.id">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                {{ category.category_name }}
              </td>
              <td class="px-6 py-4 text-sm text-gray-600">{{ category.description }}</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm">
                <button
                  @click="handleDeleteCategory(category.id)"
                  class="text-red-600 hover:text-red-900"
                >
                  Delete
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

const categories = ref([]);
const newCategory = reactive({
  category_name: '',
  description: '',
});

const handleCreateCategory = async () => {
  try {
    await api.post('/categories', newCategory);
    newCategory.category_name = '';
    newCategory.description = '';
    await fetchCategories();
  } catch (error) {
    console.error('Error creating category:', error);
  }
};

const handleDeleteCategory = async (id) => {
  if (confirm('Are you sure?')) {
    try {
      await api.delete(`/categories/${id}`);
      await fetchCategories();
    } catch (error) {
      console.error('Error deleting category:', error);
    }
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

onMounted(fetchCategories);
</script>
