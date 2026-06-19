<template>
  <header class="site-header">
    <nav class="nav container">
      <RouterLink to="/" class="nav-logo">BR</RouterLink>

      <ul class="nav-links" :class="{ open: menuOpen }">
        <li><RouterLink to="/" class="nav-link" @click="menuOpen = false">Início</RouterLink></li>
        <li><RouterLink to="/blog" class="nav-link" @click="menuOpen = false">Blog</RouterLink></li>
        <li><RouterLink to="/certificados" class="nav-link" @click="menuOpen = false">Certificados</RouterLink></li>
        <li v-if="auth.user">
          <button class="btn-logout" @click="handleLogout">Sair</button>
        </li>
      </ul>

      <button class="nav-toggle" :class="{ active: menuOpen }" aria-label="Menu" @click="menuOpen = !menuOpen">
        <span /><span /><span />
      </button>
    </nav>
  </header>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const router = useRouter()
const menuOpen = ref(false)

async function handleLogout() {
  menuOpen.value = false
  await auth.logout()
  router.push('/')
}
</script>

<style scoped>
.site-header {
  position: sticky;
  top: 0;
  z-index: 100;
  background: rgba(15, 17, 23, 0.85);
  backdrop-filter: blur(12px);
  border-bottom: 1px solid var(--color-border);
}

.nav {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 64px;
}

.nav-logo {
  font-weight: 600;
  font-size: 1.1rem;
  color: var(--color-accent);
  letter-spacing: 0.05em;
  text-decoration: none;
}

.nav-links {
  display: flex;
  align-items: center;
  gap: 2rem;
  list-style: none;
  margin: 0;
  padding: 0;
}

.nav-link {
  color: var(--color-text-muted);
  text-decoration: none;
  font-size: 0.9rem;
  font-weight: 500;
  transition: color 0.15s;
}

.nav-link:hover,
.nav-link.router-link-active {
  color: var(--color-text);
}

.btn-logout {
  background: none;
  border: 1px solid var(--color-border);
  color: var(--color-text-muted);
  padding: 0.3rem 0.8rem;
  border-radius: 6px;
  font-size: 0.85rem;
  cursor: pointer;
  transition: all 0.15s;
}

.btn-logout:hover {
  color: var(--color-text);
  border-color: var(--color-text-muted);
}

.nav-toggle {
  display: none;
  flex-direction: column;
  gap: 5px;
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
}

.nav-toggle span {
  display: block;
  width: 22px;
  height: 2px;
  background: var(--color-text);
  border-radius: 2px;
  transition: all 0.2s;
}

@media (max-width: 640px) {
  .nav-toggle {
    display: flex;
  }

  .nav-links {
    display: none;
    position: absolute;
    top: 64px;
    left: 0;
    right: 0;
    flex-direction: column;
    align-items: flex-start;
    gap: 0;
    background: var(--color-surface);
    border-bottom: 1px solid var(--color-border);
    padding: 1rem 1.5rem;
  }

  .nav-links.open {
    display: flex;
  }

  .nav-links li {
    width: 100%;
    padding: 0.6rem 0;
    border-bottom: 1px solid var(--color-border);
  }

  .nav-links li:last-child {
    border-bottom: none;
  }
}
</style>
