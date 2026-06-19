import { defineStore } from 'pinia'
import { ref } from 'vue'
import http from '@/services/http'

export const useBlogStore = defineStore('blog', () => {
  const posts = ref([])
  const pagination = ref({ total: 0, page: 1, per_page: 10, pages: 0 })
  const currentPost = ref(null)
  const tags = ref([])
  const loading = ref(false)
  const error = ref(null)

  async function fetchPosts({ tag = null, page = 1, perPage = 10 } = {}) {
    loading.value = true
    error.value = null
    try {
      const params = { page, per_page: perPage }
      if (tag) params.tag = tag
      const { data } = await http.get('/posts', { params })
      posts.value = data.items
      pagination.value = { total: data.total, page: data.page, per_page: data.per_page, pages: data.pages }
    } catch (e) {
      error.value = e.response?.data?.detail ?? 'Erro ao carregar posts'
    } finally {
      loading.value = false
    }
  }

  async function fetchAllPosts() {
    loading.value = true
    error.value = null
    try {
      const { data } = await http.get('/posts/all')
      posts.value = data
    } catch (e) {
      error.value = e.response?.data?.detail ?? 'Erro ao carregar posts'
    } finally {
      loading.value = false
    }
  }

  async function fetchPost(slug) {
    loading.value = true
    error.value = null
    try {
      const { data } = await http.get(`/posts/${slug}`)
      currentPost.value = data
    } catch (e) {
      currentPost.value = null
      error.value = e.response?.data?.detail ?? 'Post não encontrado'
    } finally {
      loading.value = false
    }
  }

  async function fetchTags() {
    const { data } = await http.get('/tags')
    tags.value = data
  }

  async function createPost(payload) {
    const { data } = await http.post('/posts', payload)
    return data
  }

  async function updatePost(id, payload) {
    const { data } = await http.put(`/posts/${id}`, payload)
    return data
  }

  async function deletePost(id) {
    await http.delete(`/posts/${id}`)
    posts.value = posts.value.filter((p) => p.id !== id)
  }

  return {
    posts, pagination, currentPost, tags, loading, error,
    fetchPosts, fetchAllPosts, fetchPost, fetchTags,
    createPost, updatePost, deletePost,
  }
})
