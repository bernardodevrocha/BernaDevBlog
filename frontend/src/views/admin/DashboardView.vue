<template>
  <section class="container section-sm">
    <div class="admin-header">
      <div>
        <h1 class="page-title">Dashboard</h1>
        <p class="page-subtitle">Gerencie os posts do blog.</p>
      </div>
      <div style="display:flex;gap:0.75rem">
        <RouterLink to="/admin/posts/new" class="btn btn-primary">+ Novo Post</RouterLink>
        <RouterLink to="/admin/certificados" class="btn btn-ghost">Certificados</RouterLink>
      </div>
    </div>

    <AlertMessage :message="blog.error" />
    <LoadingSpinner v-if="blog.loading" />

    <div v-else-if="blog.posts.length" class="admin-table-wrap">
      <table class="admin-table">
        <thead>
          <tr>
            <th>Título</th>
            <th>Status</th>
            <th>Tags</th>
            <th>Data</th>
            <th>Ações</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="post in blog.posts" :key="post.id">
            <td class="td-title">
              <a :href="`/blog/${post.slug}`" target="_blank">{{ post.title }}</a>
            </td>
            <td>
              <span class="status-badge" :class="post.published ? 'status-published' : 'status-draft'">
                {{ post.published ? 'Publicado' : 'Rascunho' }}
              </span>
            </td>
            <td class="td-tags">
              <TagBadge v-for="tag in post.tags" :key="tag.id" :tag="tag" :link="false" />
            </td>
            <td class="td-date">{{ formatDate(post.created_at) }}</td>
            <td class="td-actions">
              <RouterLink :to="`/admin/posts/${post.id}/edit`" class="btn btn-sm">Editar</RouterLink>
              <button class="btn btn-sm btn-danger" @click="confirmDelete(post)">Excluir</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-else class="empty-state">
      <p>Nenhum post ainda.</p>
      <RouterLink to="/admin/posts/new" class="btn btn-primary">Criar primeiro post</RouterLink>
    </div>
  </section>
</template>

<script setup>
import { onMounted } from 'vue'
import TagBadge from '@/components/ui/TagBadge.vue'
import AlertMessage from '@/components/ui/AlertMessage.vue'
import LoadingSpinner from '@/components/ui/LoadingSpinner.vue'
import { useBlogStore } from '@/stores/blog'

const blog = useBlogStore()

function formatDate(iso) {
  return new Date(iso).toLocaleDateString('pt-BR')
}

async function confirmDelete(post) {
  if (!confirm(`Excluir "${post.title}"?`)) return
  await blog.deletePost(post.id)
}

onMounted(() => blog.fetchAllPosts())
</script>
