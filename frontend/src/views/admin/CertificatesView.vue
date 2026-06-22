<template>
  <section class="container section-sm">
    <div class="admin-header">
      <div>
        <h1 class="page-title">Certificados</h1>
        <p class="page-subtitle">Gerencie seus certificados e credenciais.</p>
      </div>
      <button class="btn btn-primary" @click="showForm = true">+ Novo Certificado</button>
    </div>

    <!-- Upload form -->
    <div v-if="showForm" class="cert-form-wrap">
      <form class="cert-form" @submit.prevent="handleCreate">
        <h2 class="cert-form-title">Novo Certificado</h2>

        <div class="form-group">
          <label class="form-label">Título <span class="required">*</span></label>
          <input v-model="form.title" class="form-input" type="text" placeholder="Ex: AWS Cloud Practitioner" required />
        </div>

        <div class="form-group">
          <label class="form-label">Emissor <span class="required">*</span></label>
          <input v-model="form.issuer" class="form-input" type="text" placeholder="Ex: Amazon Web Services" required />
        </div>

        <div class="form-group">
          <label class="form-label">Data de emissão <span class="required">*</span></label>
          <input v-model="form.issued_at" class="form-input" type="month" required />
        </div>

        <div class="form-group">
          <label class="form-label">Arquivo <span class="required">*</span> <span class="form-hint">(imagem ou PDF, máx 10 MB)</span></label>
          <input
            ref="fileInput"
            class="form-input"
            type="file"
            accept="image/*,.pdf"
            required
            @change="onFileChange"
          />
        </div>

        <div v-if="filePreview" class="cert-preview-wrap">
          <img v-if="fileIsImage" :src="filePreview" alt="Preview" class="cert-preview-img" />
          <div v-else class="cert-pdf-preview">PDF selecionado: {{ selectedFile?.name }}</div>
        </div>

        <AlertMessage v-if="formError" type="error" :message="formError" />

        <div class="form-actions">
          <button type="button" class="btn btn-ghost" @click="cancelForm">Cancelar</button>
          <button type="submit" class="btn btn-primary" :disabled="creating">
            {{ creating ? 'Enviando...' : 'Salvar' }}
          </button>
        </div>
      </form>
    </div>

    <LoadingSpinner v-if="store.loading" />
    <AlertMessage v-else-if="store.error" type="error" :message="store.error" />

    <div v-else-if="!store.certificates.length && !showForm" class="empty-state">
      <p>Nenhum certificado cadastrado ainda.</p>
    </div>

    <div v-else class="admin-table-wrap">
      <table class="admin-table">
        <thead>
          <tr>
            <th>Preview</th>
            <th>Título</th>
            <th>Emissor</th>
            <th>Data</th>
            <th>Tipo</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="cert in store.certificates" :key="cert.id">
            <td>
              <img
                v-if="cert.file_type === 'image'"
                :src="store.fileUrl(cert.file_path)"
                :alt="cert.title"
                class="cert-table-thumb"
              />
              <span v-else class="cert-table-pdf">PDF</span>
            </td>
            <td class="td-title">
              <a :href="store.fileUrl(cert.file_path)" target="_blank" rel="noopener">{{ cert.title }}</a>
            </td>
            <td>{{ cert.issuer }}</td>
            <td class="td-date">{{ cert.issued_at }}</td>
            <td>
              <span class="status-badge" :class="cert.file_type === 'pdf' ? 'status-draft' : 'status-published'">
                {{ cert.file_type === 'pdf' ? 'PDF' : 'Imagem' }}
              </span>
            </td>
            <td class="td-actions">
              <button class="btn btn-sm btn-danger" :disabled="deletingId === cert.id" @click="handleDelete(cert)">
                {{ deletingId === cert.id ? '...' : 'Excluir' }}
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import LoadingSpinner from '@/components/ui/LoadingSpinner.vue'
import AlertMessage from '@/components/ui/AlertMessage.vue'
import { useCertificatesStore } from '@/stores/certificates'

const store = useCertificatesStore()

const showForm = ref(false)
const creating = ref(false)
const formError = ref(null)
const deletingId = ref(null)

const form = ref({ title: '', issuer: '', issued_at: '' })
const fileInput = ref(null)
const selectedFile = ref(null)
const filePreview = ref(null)
const fileIsImage = ref(false)

function onFileChange(e) {
  const file = e.target.files[0]
  if (!file) return
  selectedFile.value = file
  fileIsImage.value = file.type.startsWith('image/')
  if (fileIsImage.value) {
    const reader = new FileReader()
    reader.onload = (ev) => { filePreview.value = ev.target.result }
    reader.readAsDataURL(file)
  } else {
    filePreview.value = 'pdf'
  }
}

function cancelForm() {
  showForm.value = false
  formError.value = null
  form.value = { title: '', issuer: '', issued_at: '' }
  selectedFile.value = null
  filePreview.value = null
  if (fileInput.value) fileInput.value.value = ''
}

async function handleCreate() {
  if (!selectedFile.value) { formError.value = 'Selecione um arquivo.'; return }
  creating.value = true
  formError.value = null
  try {
    const fd = new FormData()
    fd.append('title', form.value.title)
    fd.append('issuer', form.value.issuer)
    fd.append('issued_at', form.value.issued_at)
    fd.append('file', selectedFile.value)
    await store.createCertificate(fd)
    cancelForm()
  } catch (e) {
    formError.value = e.response?.data?.detail ?? 'Erro ao salvar certificado.'
  } finally {
    creating.value = false
  }
}

async function handleDelete(cert) {
  if (!confirm(`Excluir "${cert.title}"?`)) return
  deletingId.value = cert.id
  try {
    await store.deleteCertificate(cert.id)
  } catch {
    alert('Erro ao excluir certificado.')
  } finally {
    deletingId.value = null
  }
}

onMounted(() => store.fetchCertificates())
</script>

<style scoped>
.cert-form-wrap {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: 1.75rem;
  margin-bottom: 2rem;
}

.cert-form {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
  max-width: 560px;
}

.cert-form-title {
  font-size: 1.1rem;
  margin-bottom: 0.25rem;
}

.cert-preview-wrap {
  margin-top: 0.5rem;
}

.cert-preview-img {
  max-height: 160px;
  border-radius: var(--radius);
  border: 1px solid var(--color-border);
}

.cert-pdf-preview {
  font-size: 0.85rem;
  color: var(--color-text-muted);
  padding: 0.5rem 0;
}

.cert-table-thumb {
  width: 48px;
  height: 36px;
  object-fit: cover;
  border-radius: 4px;
  border: 1px solid var(--color-border);
}

.cert-table-pdf {
  font-family: var(--font-mono);
  font-size: 0.7rem;
  font-weight: 700;
  color: var(--color-accent-hover);
  background: var(--color-accent-muted);
  border: 1px solid var(--color-accent-muted-border);
  padding: 0.2rem 0.5rem;
  border-radius: 4px;
}
</style>
