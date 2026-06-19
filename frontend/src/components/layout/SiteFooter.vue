<template>
  <footer class="site-footer">
    <div class="container">
      <p>© {{ year }} Bernardo Rocha &middot; Feito com FastAPI + Vue</p>
    </div>
  </footer>
</template>

<script setup>
const year = new Date().getFullYear()
</script>

<style scoped>
.site-footer {
  border-top: 1px solid var(--color-border);
  padding: 2rem 0;
  margin-top: auto;
}

.site-footer p {
  color: var(--color-text-muted);
  font-size: 0.85rem;
  text-align: center;
}
</style>
