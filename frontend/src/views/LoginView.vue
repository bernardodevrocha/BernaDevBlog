<template>
  <section class="auth-section">
    <div class="auth-card">
      <div class="auth-header">
        <span class="auth-logo">BR</span>
        <h1 class="auth-title">Entrar</h1>
        <p class="auth-subtitle">Acesso restrito ao administrador</p>
      </div>

      <AlertMessage :message="error" />

      <form class="auth-form" @submit.prevent="handleLogin">
        <div class="form-group">
          <label for="email" class="form-label">E-mail</label>
          <input
            id="email"
            v-model="form.email"
            type="email"
            class="form-input"
            placeholder="seu@email.com"
            required
            autofocus
          />
        </div>
        <div class="form-group">
          <label for="password" class="form-label">Senha</label>
          <input
            id="password"
            v-model="form.password"
            type="password"
            class="form-input"
            placeholder="••••••••"
            required
          />
        </div>
        <button type="submit" class="btn btn-primary btn-full" :disabled="loading">
          {{ loading ? 'Entrando...' : 'Entrar' }}
        </button>
      </form>
    </div>
  </section>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import AlertMessage from '@/components/ui/AlertMessage.vue'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const router = useRouter()
const route = useRoute()

const form = reactive({ email: '', password: '' })
const error = ref('')
const loading = ref(false)

async function handleLogin() {
  error.value = ''
  loading.value = true
  try {
    await auth.login(form.email, form.password)
    const redirect = route.query.redirect || '/admin'
    router.push(redirect)
  } catch (e) {
    error.value = e.response?.data?.detail ?? 'Erro ao fazer login. Tente novamente.'
  } finally {
    loading.value = false
  }
}
</script>
