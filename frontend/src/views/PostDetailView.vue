<template>
  <div v-if="blog.loading">
    <LoadingSpinner :full="true" />
  </div>

  <div v-else-if="!blog.currentPost" class="error-section container">
    <div class="error-content">
      <span class="error-code">404</span>
      <h1 class="error-title">Post não encontrado</h1>
      <RouterLink to="/blog" class="btn btn-primary">Voltar ao blog</RouterLink>
    </div>
  </div>

  <article v-else class="post-article">
    <header class="post-header container">
      <div class="post-header-meta">
        <RouterLink to="/blog" class="back-link">← Blog</RouterLink>
        <time :datetime="blog.currentPost.created_at">{{ formatDate(blog.currentPost.created_at) }}</time>
      </div>
      <h1 class="post-title">{{ blog.currentPost.title }}</h1>
      <p class="post-lead">{{ blog.currentPost.summary }}</p>
      <div v-if="blog.currentPost.tags?.length" class="post-tags post-tags-large">
        <TagBadge v-for="tag in blog.currentPost.tags" :key="tag.id" :tag="tag" />
      </div>
      <div v-if="auth.user" class="post-admin-actions">
        <RouterLink :to="`/admin/posts/${blog.currentPost.id}/edit`" class="btn btn-sm">Editar</RouterLink>
      </div>
    </header>

    <div class="post-body container">
      <div class="prose" v-html="renderedContent" />
    </div>

    <footer class="post-footer container">
      <RouterLink to="/blog" class="back-link">← Voltar ao blog</RouterLink>
    </footer>
  </article>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { marked } from 'marked'
import DOMPurify from 'dompurify'
import TagBadge from '@/components/ui/TagBadge.vue'
import LoadingSpinner from '@/components/ui/LoadingSpinner.vue'
import { useBlogStore } from '@/stores/blog'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const blog = useBlogStore()
const auth = useAuthStore()

const renderedContent = computed(() => {
  if (!blog.currentPost?.content) return ''
  return DOMPurify.sanitize(marked.parse(blog.currentPost.content))
})

function formatDate(iso) {
  return new Date(iso).toLocaleDateString('pt-BR', { day: 'numeric', month: 'long', year: 'numeric' })
}

onMounted(() => blog.fetchPost(route.params.slug))
</script>
