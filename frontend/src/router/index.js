import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const routes = [
  {
    path: '/',
    component: () => import('@/layouts/DefaultLayout.vue'),
    children: [
      { path: '', name: 'home', component: () => import('@/views/HomeView.vue') },
      { path: 'blog', name: 'blog', component: () => import('@/views/BlogView.vue') },
      { path: 'blog/:slug', name: 'post', component: () => import('@/views/PostDetailView.vue') },
      { path: 'certificados', name: 'certificates', component: () => import('@/views/CertificatesView.vue') },
      { path: 'como-foi-feito', name: 'how-it-was-built', component: () => import('@/views/HowItWasBuiltView.vue') },
      { path: 'login', name: 'login', component: () => import('@/views/LoginView.vue') },
    ],
  },
  {
    path: '/admin',
    component: () => import('@/layouts/AdminLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      { path: '', name: 'admin', component: () => import('@/views/admin/DashboardView.vue') },
      { path: 'posts/new', name: 'post-new', component: () => import('@/views/admin/PostFormView.vue') },
      { path: 'posts/:id/edit', name: 'post-edit', component: () => import('@/views/admin/PostFormView.vue') },
      { path: 'certificados', name: 'admin-certificates', component: () => import('@/views/admin/CertificatesView.vue') },
    ],
  },
  { path: '/:pathMatch(.*)*', name: 'not-found', component: () => import('@/views/NotFoundView.vue') },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior: () => ({ top: 0 }),
})

router.beforeEach(async (to) => {
  const auth = useAuthStore()

  // Validate session once per app lifecycle (cookie → /me)
  if (!auth.initialized) await auth.fetchMe()

  if (to.meta.requiresAuth && !auth.user) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }

  if (to.name === 'login' && auth.user) {
    return { name: 'admin' }
  }
})

export default router
