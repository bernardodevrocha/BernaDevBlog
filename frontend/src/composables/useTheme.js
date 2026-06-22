import { ref } from 'vue'

const theme = ref(localStorage.getItem('theme') ?? 'dark')

export function useTheme() {
  function toggle() {
    theme.value = theme.value === 'dark' ? 'light' : 'dark'
    document.documentElement.setAttribute('data-theme', theme.value)
    localStorage.setItem('theme', theme.value)
  }
  return { theme, toggle }
}
