import { defineStore } from 'pinia'
import { ref } from 'vue'
import http from '@/services/http'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const loading = ref(false)
  const initialized = ref(false)

  async function fetchMe() {
    if (initialized.value) return
    loading.value = true
    try {
      const { data } = await http.get('/auth/me')
      user.value = data
    } catch {
      user.value = null
    } finally {
      loading.value = false
      initialized.value = true
    }
  }

  async function login(email, password) {
    const { data } = await http.post('/auth/login', { email, password })
    user.value = data
    initialized.value = true
  }

  async function logout() {
    await http.post('/auth/logout')
    user.value = null
  }

  return { user, loading, initialized, fetchMe, login, logout }
})
