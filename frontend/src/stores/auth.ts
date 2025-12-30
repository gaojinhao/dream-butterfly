import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import axios from 'axios'

interface User {
  id: number
  username: string
  email: string
}

interface AuthResponse {
  user: User
  token: string
}

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const token = ref<string | null>(localStorage.getItem('token'))
  const loading = ref(false)
  const error = ref<string | null>(null)

  const isAuthenticated = computed(() => !!token.value && !!user.value)

  async function login(email: string, password: string) {
    loading.value = true
    error.value = null
    try {
      const response = await axios.post<AuthResponse>('/api/auth/login', { email, password })
      token.value = response.data.token
      user.value = response.data.user
      localStorage.setItem('token', token.value!)
      axios.defaults.headers.common['Authorization'] = `Bearer ${token.value}`
      return true
    } catch (err: any) {
      error.value = err.response?.data?.message || '登录失败'
      return false
    } finally {
      loading.value = false
    }
  }

  async function register(username: string, email: string, password: string) {
    loading.value = true
    error.value = null
    try {
      const response = await axios.post<AuthResponse>('/api/auth/register', { username, email, password })
      token.value = response.data.token
      user.value = response.data.user
      localStorage.setItem('token', token.value!)
      axios.defaults.headers.common['Authorization'] = `Bearer ${token.value}`
      return true
    } catch (err: any) {
      error.value = err.response?.data?.message || '注册失败'
      return false
    } finally {
      loading.value = false
    }
  }

  async function fetchUser() {
    if (!token.value) return
    loading.value = true
    try {
      const response = await axios.get<User>('/api/auth/me')
      user.value = response.data
    } catch {
      logout()
    } finally {
      loading.value = false
    }
  }

  function logout() {
    user.value = null
    token.value = null
    localStorage.removeItem('token')
    delete axios.defaults.headers.common['Authorization']
  }

  if (token.value) {
    axios.defaults.headers.common['Authorization'] = `Bearer ${token.value}`
    fetchUser()
  }

  return { user, token, loading, error, isAuthenticated, login, register, fetchUser, logout }
})
