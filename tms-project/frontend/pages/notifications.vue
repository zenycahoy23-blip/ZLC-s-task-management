<template>
  <div class="py-12">
    <div class="container">
      <h1 class="text-3xl font-bold text-gray-900 mb-8">Notifications</h1>

      <div class="bg-white shadow overflow-hidden sm:rounded-lg">
        <div v-if="!notifications.length" class="px-6 py-12 text-center text-gray-500">
          No notifications
        </div>

        <div v-for="notification in notifications" :key="notification.id" class="px-6 py-4 border-b">
          <div class="flex items-start justify-between">
            <div class="flex-1">
              <p :class="{ 'font-semibold': !notification.is_read, 'text-gray-600': notification.is_read }">
                {{ notification.message }}
              </p>
              <p class="mt-1 text-sm text-gray-500">
                {{ formatDate(notification.created_at) }}
              </p>
            </div>
            <button
              v-if="!notification.is_read"
              @click="handleMarkAsRead(notification.id)"
              class="ml-4 text-indigo-600 hover:text-indigo-900 text-sm"
            >
              Mark as read
            </button>
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

const notifications = ref([]);

const formatDate = (date) => {
  return new Date(date).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
};

const handleMarkAsRead = async (id) => {
  try {
    await api.put(`/notifications/${id}/read`);
    await fetchNotifications();
  } catch (error) {
    console.error('Error marking notification as read:', error);
  }
};

const fetchNotifications = async () => {
  try {
    const { data } = await api.get('/notifications');
    notifications.value = data.data || data;
  } catch (error) {
    console.error('Error loading notifications:', error);
  }
};

onMounted(fetchNotifications);
</script>
