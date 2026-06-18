export default defineNuxtConfig({
  devtools: { enabled: true },
  modules: ['@nuxtjs/tailwindcss'],
  css: ['~/assets/css/main.css'],
  runtimeConfig: {
    public: {
      apiBase: process.env.VITE_API_URL || 'http://localhost:8000',
      apiPath: process.env.VITE_API_BASE_PATH || '/api',
    },
  },
  ssr: false,
});
