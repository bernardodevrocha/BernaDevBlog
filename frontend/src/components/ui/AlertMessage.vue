<template>
  <div v-if="message" class="alert" :class="`alert-${type}`">{{ message }}</div>
</template>

<script setup>
defineProps({
  message: { type: String, default: '' },
  type: { type: String, default: 'error' },
})
</script>

<style scoped>
.alert {
  padding: 0.75rem 1rem;
  border-radius: 8px;
  font-size: 0.9rem;
  margin-bottom: 1.25rem;
}

.alert-error {
  background: rgba(239, 68, 68, 0.1);
  border: 1px solid rgba(239, 68, 68, 0.3);
  color: #fca5a5;
}

.alert-success {
  background: rgba(34, 197, 94, 0.1);
  border: 1px solid rgba(34, 197, 94, 0.3);
  color: #86efac;
}
</style>
