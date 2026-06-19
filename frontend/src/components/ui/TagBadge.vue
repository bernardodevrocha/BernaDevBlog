<template>
  <RouterLink v-if="link" :to="`/blog?tag=${tag.slug}`" class="tag">{{ tag.name }}</RouterLink>
  <span v-else class="tag">{{ tag.name }}</span>
</template>

<script setup>
defineProps({
  tag: { type: Object, required: true },
  link: { type: Boolean, default: true },
})
</script>
