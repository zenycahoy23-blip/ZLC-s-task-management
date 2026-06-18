export default defineNuxtRouteMiddleware((to, from) => {
  const auth = useAuth();

  if (auth.isAuthenticated() && to.path === '/login') {
    return navigateTo('/dashboard');
  }
});
