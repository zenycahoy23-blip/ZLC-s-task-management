export default defineNuxtRouteMiddleware(async (to, from) => {
  const auth = useAuth();

  if (!auth.isAuthenticated()) {
    const savedToken = localStorage.getItem('auth_token');
    if (savedToken) {
      auth.setToken(savedToken);
      try {
        await auth.fetchUser();
      } catch {
        return navigateTo('/login');
      }
    } else {
      return navigateTo('/login');
    }
  }
});
