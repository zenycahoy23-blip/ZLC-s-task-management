export const useAuth = () => {
  const user = useState('auth.user', () => null);
  const token = useState('auth.token', () => null);
  const isLoading = useState('auth.loading', () => false);

  const setUser = (newUser) => {
    user.value = newUser;
  };

  const setToken = (newToken) => {
    token.value = newToken;
    if (newToken) {
      localStorage.setItem('auth_token', newToken);
    } else {
      localStorage.removeItem('auth_token');
    }
  };

  const isAuthenticated = () => {
    return !!user.value && !!token.value;
  };

  const login = async (email, password) => {
    isLoading.value = true;
    try {
      const { data } = await useApi().post('/login', { email, password });
      setUser(data.user);
      setToken(data.token);
      return data;
    } finally {
      isLoading.value = false;
    }
  };

  const register = async (name, email, password, passwordConfirmation) => {
    isLoading.value = true;
    try {
      const { data } = await useApi().post('/register', {
        name,
        email,
        password,
        password_confirmation: passwordConfirmation,
      });
      return data;
    } finally {
      isLoading.value = false;
    }
  };

  const logout = async () => {
    try {
      await useApi().post('/logout');
    } finally {
      setUser(null);
      setToken(null);
    }
  };

  const fetchUser = async () => {
    try {
      const { data } = await useApi().get('/user');
      setUser(data);
      return data;
    } catch (error) {
      setUser(null);
      setToken(null);
      throw error;
    }
  };

  const initializeAuth = () => {
    const savedToken = localStorage.getItem('auth_token');
    if (savedToken) {
      setToken(savedToken);
      return fetchUser().catch(() => {
        setToken(null);
      });
    }
  };

  return {
    user: readonly(user),
    token: readonly(token),
    isLoading: readonly(isLoading),
    setUser,
    setToken,
    isAuthenticated,
    login,
    register,
    logout,
    fetchUser,
    initializeAuth,
  };
};
