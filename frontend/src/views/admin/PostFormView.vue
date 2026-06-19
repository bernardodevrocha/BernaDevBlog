<template>
  <section class="container section-sm">
    <div class="admin-header">
      <div>
        <RouterLink to="/admin" class="back-link">← Dashboard</RouterLink>
        <h1 class="page-title">{{ isEdit ? 'Editar Post' : 'Novo Post' }}</h1>
      </div>
    </div>

    <AlertMessage :message="error" />
    <LoadingSpinner v-if="loading" />

    <form v-else class="post-form" @submit.prevent="handleSubmit">
      <div class="form-group">
        <label for="title" class="form-label">Título <span class="required">*</span></label>
        <input id="title" v-model="form.title" type="text" class="form-input" required placeholder="Título do post" />
      </div>

      <div class="form-group">
        <label for="summary" class="form-label">Resumo</label>
        <input id="summary" v-model="form.summary" type="text" class="form-input" placeholder="Breve descrição (aparece na listagem)" />
      </div>

      <div class="form-group">
        <label for="tags" class="form-label">Tags</label>
        <input id="tags" v-model="tagsInput" type="text" class="form-input" placeholder="python, fastapi, docker  (separe por vírgula)" />
      </div>

      <div class="form-group">
        <label for="content" class="form-label">
          Conteúdo <span class="required">*</span>
          <span class="form-hint">(Markdown)</span>
        </label>
        <div class="editor-wrap">
          <div class="editor-toolbar">
            <button type="button" class="toolbar-btn" title="Negrito" @click="insert('**', '**')"><b>B</b></button>
            <button type="button" class="toolbar-btn" title="Itálico" @click="insert('*', '*')"><i>I</i></button>
            <button type="button" class="toolbar-btn" title="Código" @click="insert('`', '`')">`</button>
            <button type="button" class="toolbar-btn" title="Bloco de código" @click="insert('```\n', '\n```')">{}</button>
            <button type="button" class="toolbar-btn" title="H2" @click="insert('## ', '')">H2</button>
            <button type="button" class="toolbar-btn" title="H3" @click="insert('### ', '')">H3</button>
            <button type="button" class="toolbar-btn" title="Lista" @click="insert('- ', '')">≡</button>
            <button type="button" class="toolbar-btn" :class="{ active: showPreview }" @click="showPreview = !showPreview">👁</button>
          </div>
          <div class="editor-body">
            <textarea
              id="content"
              ref="textarea"
              v-model="form.content"
              class="form-textarea editor-textarea"
              rows="20"
              required
              placeholder="Escreva o conteúdo em Markdown..."
            />
            <div v-if="showPreview" class="preview-pane prose" v-html="renderedPreview" />
          </div>
        </div>
      </div>

      <div class="form-row">
        <label class="toggle-label">
          <input v-model="form.published" type="checkbox" class="toggle-input" />
          <span class="toggle-track" />
          <span class="toggle-text">Publicar post</span>
        </label>
      </div>

      <div class="form-actions">
        <RouterLink to="/admin" class="btn btn-ghost">Cancelar</RouterLink>
        <button type="submit" class="btn btn-primary" :disabled="saving">
          {{ saving ? 'Salvando...' : isEdit ? 'Salvar alterações' : 'Criar post' }}
        </button>
      </div>
    </form>
  </section>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { marked } from 'marked'
import DOMPurify from 'dompurify'
import AlertMessage from '@/components/ui/AlertMessage.vue'
import LoadingSpinner from '@/components/ui/LoadingSpinner.vue'
import { useBlogStore } from '@/stores/blog'

const route = useRoute()
const router = useRouter()
const blog = useBlogStore()

const isEdit = computed(() => !!route.params.id)
const loading = ref(isEdit.value)
const saving = ref(false)
const error = ref('')
const showPreview = ref(false)
const textarea = ref(null)

const form = reactive({ title: '', summary: '', content: '', published: false })
const tagsInput = ref('')

const renderedPreview = computed(() =>
  DOMPurify.sanitize(marked.parse(form.content || ''))
)

function insert(before, after) {
  const el = textarea.value
  if (!el) return
  const start = el.selectionStart
  const end = el.selectionEnd
  const selected = form.content.slice(start, end)
  form.content = form.content.slice(0, start) + before + selected + after + form.content.slice(end)
}

async function handleSubmit() {
  error.value = ''
  saving.value = true
  const payload = {
    ...form,
    tags: tagsInput.value.split(',').map((t) => t.trim()).filter(Boolean),
  }
  try {
    if (isEdit.value) {
      await blog.updatePost(route.params.id, payload)
    } else {
      await blog.createPost(payload)
    }
    router.push('/admin')
  } catch (e) {
    const detail = e.response?.data?.detail
    error.value = Array.isArray(detail)
      ? detail.map((d) => d.msg).join(', ')
      : (detail ?? 'Erro ao salvar post.')
  } finally {
    saving.value = false
  }
}

onMounted(async () => {
  if (!isEdit.value) { loading.value = false; return }
  try {
    await blog.fetchAllPosts()
    const post = blog.posts.find((p) => p.id === Number(route.params.id))
    if (post) {
      form.title = post.title
      form.summary = post.summary
      form.content = post.content
      form.published = post.published
      tagsInput.value = post.tags?.map((t) => t.name).join(', ') ?? ''
    }
  } finally {
    loading.value = false
  }
})
</script>
