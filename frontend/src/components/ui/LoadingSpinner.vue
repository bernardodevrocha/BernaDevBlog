<template>
  <div class="spinner-wrap" :class="{ full }">
    <div class="spinner" />
  </div>
</template>

<script setup>
defineProps({ full: { type: Boolean, default: false } })
</script>

<style scoped>
.spinner-wrap {
  display: flex;
  justify-content: center;
  padding: 3rem 0;
}

.spinner-wrap.full {
  min-height: 50vh;
  align-items: center;
}

.spinner {
  width: 32px;
  height: 32px;
  border: 2px solid var(--color-border);
  border-top-color: var(--color-accent);
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
</style>
