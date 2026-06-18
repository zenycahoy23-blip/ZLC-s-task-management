import axios from 'axios';

export const useApi = () => {
  const config = useRuntimeConfig();
  const auth = useAuth();

  const instance = axios.create({
    baseURL: `${config.public.apiBase}${config.public.apiPath}`,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  });

  instance.interceptors.request.use((config) => {
    if (auth.token.value) {
      config.headers.Authorization = `Bearer ${auth.token.value}`;
    }
    return config;
  });

  instance.interceptors.response.use(
    (response) => response,
    (error) => {
      if (error.response?.status === 401) {
        auth.setToken(null);
        auth.setUser(null);
        navigateTo('/login');
      }
      return Promise.reject(error);
    }
  );

  return instance;
};
