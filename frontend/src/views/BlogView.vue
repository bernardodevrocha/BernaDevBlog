<template>
  <section class="page-header container">
    <h1 class="page-title">Blog</h1>
    <p class="page-subtitle">Estudos, experimentos e anotações sobre desenvolvimento de software.</p>
  </section>

  <section class="container section-sm">
    <div v-if="blog.tags.length" class="tag-filter">
      <button class="tag" :class="{ 'tag-active': !activeTag }" @click="setTag(null)">Todos</button>
      <button
        v-for="tag in blog.tags"
        :key="tag.id"
        class="tag"
        :class="{ 'tag-active': activeTag === tag.slug }"
        @click="setTag(tag.slug)"
      >
        {{ tag.name }}
      </button>
    </div>

    <LoadingSpinner v-if="blog.loading" />

    <template v-else>
      <div v-if="blog.posts.length" class="posts-list">
        <article v-for="post in blog.posts" :key="post.id" class="post-list-item">
          <div class="post-list-meta">
            <time :datetime="post.created_at">{{ formatDate(post.created_at) }}</time>
            <div v-if="post.tags?.length" class="post-tags">
              <TagBadge v-for="tag in post.tags" :key="tag.id" :tag="tag" />
            </div>
          </div>
          <div class="post-list-body">
            <h2 class="post-list-title">
              <RouterLink :to="`/blog/${post.slug}`">{{ post.title }}</RouterLink>
            </h2>
            <p class="post-list-summary">{{ post.summary }}</p>
            <RouterLink :to="`/blog/${post.slug}`" class="post-card-link">Ler mais →</RouterLink>
          </div>
        </article>
      </div>

      <div v-else class="empty-state">
        <p>{{ activeTag ? 'Nenhum post com essa tag.' : 'Nenhum post publicado ainda.' }}</p>
      </div>

      <PaginationBar
        :page="blog.pagination.page"
        :pages="blog.pagination.pages"
        :total="blog.pagination.total"
        :per-page="blog.pagination.per_page"
        @change="goToPage"
      />
    </template>
  </section>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import TagBadge from '@/components/ui/TagBadge.vue'
import LoadingSpinner from '@/components/ui/LoadingSpinner.vue'
import PaginationBar from '@/components/ui/PaginationBar.vue'
import { useBlogStore } from '@/stores/blog'

const blog = useBlogStore()
const route = useRoute()
const router = useRouter()

const activeTag = ref(route.query.tag || null)
const currentPage = ref(Number(route.query.page) || 1)

function formatDate(iso) {
  return new Date(iso).toLocaleDateString('pt-BR', { day: '2-digit', month: 'short', year: 'numeric' })
}

function setTag(slug) {
  activeTag.value = slug
  currentPage.value = 1
  syncRoute()
  loadPosts()
}

function goToPage(page) {
  currentPage.value = page
  syncRoute()
  loadPosts()
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

function syncRoute() {
  const query = {}
  if (activeTag.value) query.tag = activeTag.value
  if (currentPage.value > 1) query.page = currentPage.value
  router.replace({ query })
}

function loadPosts() {
  blog.fetchPosts({ tag: activeTag.value, page: currentPage.value })
}

onMounted(async () => {
  await Promise.all([loadPosts(), blog.fetchTags()])
})
</script>
