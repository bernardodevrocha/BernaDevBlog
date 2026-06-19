<template>
  <article class="post-card">
    <div class="post-card-meta">
      <time :datetime="post.created_at">{{ formatDate(post.created_at) }}</time>
      <div v-if="post.tags?.length" class="post-tags">
        <TagBadge v-for="tag in post.tags.slice(0, 2)" :key="tag.id" :tag="tag" />
      </div>
    </div>
    <h3 class="post-card-title">
      <RouterLink :to="`/blog/${post.slug}`">{{ post.title }}</RouterLink>
    </h3>
    <p class="post-card-summary">{{ post.summary }}</p>
    <RouterLink :to="`/blog/${post.slug}`" class="post-card-link">Ler mais →</RouterLink>
  </article>
</template>

<script setup>
import TagBadge from '@/components/ui/TagBadge.vue'

defineProps({ post: { type: Object, required: true } })

function formatDate(iso) {
  return new Date(iso).toLocaleDateString('pt-BR', { day: '2-digit', month: 'short', year: 'numeric' })
}
</script>

<style scoped>
.post-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 12px;
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  transition: border-color 0.2s;
}

.post-card:hover {
  border-color: var(--color-accent);
}

.post-card-meta {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.post-card-meta time {
  font-size: 0.8rem;
  color: var(--color-text-muted);
}

.post-card-title {
  font-size: 1.05rem;
  font-weight: 600;
  line-height: 1.4;
}

.post-card-title a {
  color: var(--color-text);
  text-decoration: none;
  transition: color 0.15s;
}

.post-card-title a:hover {
  color: var(--color-accent);
}

.post-card-summary {
  color: var(--color-text-muted);
  font-size: 0.9rem;
  line-height: 1.6;
  flex: 1;
}

.post-card-link {
  font-size: 0.85rem;
  color: var(--color-accent);
  text-decoration: none;
  font-weight: 500;
}

.post-card-link:hover {
  text-decoration: underline;
}
</style>
