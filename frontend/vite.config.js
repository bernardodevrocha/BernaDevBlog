import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'
import { fileURLToPath, URL } from 'node:url'

export default defineConfig(({ mode }) => {
  // loadEnv reads .env files; process.env picks up Docker-injected vars
  const env = loadEnv(mode, process.cwd(), '')

  const apiUrl = env.VITE_API_URL || process.env.VITE_API_URL
  if (!apiUrl) throw new Error('VITE_API_URL is not defined')

  return {
    plugins: [vue()],
    resolve: {
      alias: {
        '@': fileURLToPath(new URL('./src', import.meta.url)),
      },
    },
    server: {
      host: true,
      port: 5173,
      proxy: {
        '/api': {
          target: apiUrl,
          changeOrigin: true,
          credentials: true,
        },
      },
    },
  }
})
