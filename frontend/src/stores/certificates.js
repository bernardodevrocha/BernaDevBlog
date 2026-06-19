import { defineStore } from 'pinia'
import { ref } from 'vue'
import http from '@/services/http'

export const useCertificatesStore = defineStore('certificates', () => {
  const certificates = ref([])
  const loading = ref(false)
  const error = ref(null)

  async function fetchCertificates() {
    loading.value = true
    error.value = null
    try {
      const { data } = await http.get('/certificates')
      certificates.value = data
    } catch (e) {
      error.value = e.response?.data?.detail ?? 'Erro ao carregar certificados'
    } finally {
      loading.value = false
    }
  }

  async function createCertificate(formData) {
    const { data } = await http.post('/certificates', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
    certificates.value.unshift(data)
    return data
  }

  async function deleteCertificate(id) {
    await http.delete(`/certificates/${id}`)
    certificates.value = certificates.value.filter((c) => c.id !== id)
  }

  function fileUrl(filename) {
    return `/api/certificates/file/${filename}`
  }

  return { certificates, loading, error, fetchCertificates, createCertificate, deleteCertificate, fileUrl }
})
