<template>
  <!-- Hero -->
  <section class="certs-hero container-wide">
    <div class="certs-hero-content">
      <span class="hero-tag">Formação contínua</span>
      <h1 class="hero-title">Certificados &amp; <span class="accent">Credenciais</span></h1>
      <p class="hero-subtitle">
        Cursos, treinamentos e certificações concluídos ao longo da minha jornada
        como desenvolvedor.
      </p>
    </div>
  </section>

  <!-- Grid -->
  <section class="section container-wide">
    <LoadingSpinner v-if="store.loading" />

    <AlertMessage v-else-if="store.error" type="error" :message="store.error" />

    <div v-else-if="!store.certificates.length" class="empty-state">
      <p>Nenhum certificado cadastrado ainda.</p>
    </div>

    <div v-else>
      <p class="certs-count">{{ store.certificates.length }} certificado{{ store.certificates.length !== 1 ? 's' : '' }}</p>
      <div class="certs-grid">
        <article
          v-for="cert in store.certificates"
          :key="cert.id"
          class="cert-card"
          @click="openLightbox(cert)"
          role="button"
          tabindex="0"
          :aria-label="`Abrir certificado: ${cert.title}`"
          @keydown.enter="openLightbox(cert)"
          @keydown.space.prevent="openLightbox(cert)"
        >
          <!-- Thumbnail -->
          <div class="cert-thumb-wrap">
            <img
              v-if="cert.file_type === 'image'"
              :src="store.fileUrl(cert.file_path)"
              :alt="cert.title"
              class="cert-thumb"
              loading="lazy"
            />
            <div v-else class="cert-pdf-placeholder">
              <div class="cert-pdf-icon-wrap">
                <svg viewBox="0 0 48 48" fill="none" class="cert-pdf-svg">
                  <rect x="8" y="4" width="28" height="36" rx="3" fill="currentColor" opacity="0.08"/>
                  <path d="M8 7a3 3 0 013-3h20l9 9v28a3 3 0 01-3 3H11a3 3 0 01-3-3V7z" stroke="currentColor" stroke-width="2"/>
                  <path d="M31 4v8a1 1 0 001 1h8" stroke="currentColor" stroke-width="2"/>
                  <text x="14" y="32" font-family="monospace" font-size="9" font-weight="700" fill="currentColor">PDF</text>
                </svg>
              </div>
            </div>
            <div class="cert-overlay">
              <span class="cert-overlay-text">Ver certificado</span>
            </div>
          </div>

          <!-- Info -->
          <div class="cert-info">
            <h3 class="cert-title">{{ cert.title }}</h3>
            <p class="cert-issuer">{{ cert.issuer }}</p>
            <div class="cert-footer">
              <time class="cert-date">{{ formatDate(cert.issued_at) }}</time>
              <span class="cert-type-badge" :class="cert.file_type === 'pdf' ? 'badge-pdf' : 'badge-img'">
                {{ cert.file_type === 'pdf' ? 'PDF' : 'Imagem' }}
              </span>
            </div>
          </div>
        </article>
      </div>
    </div>
  </section>

  <!-- Lightbox -->
  <Teleport to="body">
    <Transition name="lightbox">
      <div v-if="lightbox" class="lightbox" @click.self="closeLightbox">
        <div class="lightbox-header">
          <div class="lightbox-meta">
            <span class="lightbox-title">{{ lightbox.title }}</span>
            <span class="lightbox-issuer">{{ lightbox.issuer }}</span>
          </div>
          <div class="lightbox-actions">
            <a
              :href="store.fileUrl(lightbox.file_path)"
              target="_blank"
              rel="noopener"
              class="lightbox-download"
              title="Abrir em nova aba"
              @click.stop
            >
              <svg viewBox="0 0 20 20" fill="currentColor" width="18" height="18">
                <path d="M11 3a1 1 0 100 2h2.586l-6.293 6.293a1 1 0 101.414 1.414L15 6.414V9a1 1 0 102 0V4a1 1 0 00-1-1h-5z"/>
                <path d="M5 5a2 2 0 00-2 2v8a2 2 0 002 2h8a2 2 0 002-2v-3a1 1 0 10-2 0v3H5V7h3a1 1 0 000-2H5z"/>
              </svg>
            </a>
            <button class="lightbox-close" @click="closeLightbox" aria-label="Fechar">
              <svg viewBox="0 0 20 20" fill="currentColor" width="18" height="18">
                <path d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"/>
              </svg>
            </button>
          </div>
        </div>

        <div class="lightbox-body" @click.self="closeLightbox">
          <img
            v-if="lightbox.file_type === 'image'"
            :src="store.fileUrl(lightbox.file_path)"
            :alt="lightbox.title"
            class="lightbox-img"
          />
          <iframe
            v-else
            :src="store.fileUrl(lightbox.file_path)"
            class="lightbox-pdf"
            title="Certificado PDF"
          />
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import LoadingSpinner from '@/components/ui/LoadingSpinner.vue'
import AlertMessage from '@/components/ui/AlertMessage.vue'
import { useCertificatesStore } from '@/stores/certificates'

const store = useCertificatesStore()
const lightbox = ref(null)

function openLightbox(cert) {
  lightbox.value = cert
  document.body.style.overflow = 'hidden'
}

function closeLightbox() {
  lightbox.value = null
  document.body.style.overflow = ''
}

function onKeydown(e) {
  if (e.key === 'Escape') closeLightbox()
}

function formatDate(raw) {
  if (!raw) return ''
  // "2024-03" → "Mar 2024"
  const [year, month] = raw.split('-')
  if (!month) return year
  const date = new Date(Number(year), Number(month) - 1)
  return date.toLocaleDateString('pt-BR', { month: 'short', year: 'numeric' })
}

onMounted(() => {
  store.fetchCertificates()
  window.addEventListener('keydown', onKeydown)
})

onUnmounted(() => {
  window.removeEventListener('keydown', onKeydown)
  document.body.style.overflow = ''
})
</script>

<style scoped>
/* ── Hero ──────────────────────────────────────────────────────────── */
.certs-hero {
  padding: 4rem 1.5rem 0;
}

.certs-hero-content {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  max-width: 600px;
}

/* ── Count ─────────────────────────────────────────────────────────── */
.certs-count {
  font-size: 0.85rem;
  color: var(--color-text-muted);
  margin-bottom: 1.5rem;
}

/* ── Grid ──────────────────────────────────────────────────────────── */
.certs-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 1.25rem;
}

/* ── Card ──────────────────────────────────────────────────────────── */
.cert-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  overflow: hidden;
  cursor: pointer;
  transition: border-color var(--transition), transform var(--transition);
  outline: none;
}

.cert-card:hover,
.cert-card:focus-visible {
  border-color: var(--color-accent);
  transform: translateY(-2px);
}

/* Thumbnail */
.cert-thumb-wrap {
  position: relative;
  height: 170px;
  background: var(--color-surface-raised);
  overflow: hidden;
}

.cert-thumb {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
  display: block;
}

.cert-card:hover .cert-thumb {
  transform: scale(1.05);
}

/* PDF placeholder */
.cert-pdf-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.cert-pdf-icon-wrap {
  color: var(--color-accent);
  opacity: 0.7;
}

.cert-pdf-svg {
  width: 64px;
  height: 64px;
}

/* Hover overlay */
.cert-overlay {
  position: absolute;
  inset: 0;
  background: rgba(99, 102, 241, 0.75);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.2s;
}

.cert-card:hover .cert-overlay,
.cert-card:focus-visible .cert-overlay {
  opacity: 1;
}

.cert-overlay-text {
  color: #fff;
  font-size: 0.875rem;
  font-weight: 600;
  letter-spacing: 0.03em;
}

/* Info */
.cert-info {
  padding: 1rem 1.1rem;
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
}

.cert-title {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--color-text);
  line-height: 1.35;
}

.cert-issuer {
  font-size: 0.78rem;
  color: var(--color-accent);
  font-weight: 500;
}

.cert-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 0.5rem;
}

.cert-date {
  font-size: 0.72rem;
  color: var(--color-text-muted);
}

.cert-type-badge {
  font-size: 0.65rem;
  font-weight: 700;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  padding: 0.15rem 0.45rem;
  border-radius: 4px;
}

.badge-pdf {
  background: rgba(99, 102, 241, 0.1);
  color: var(--color-accent-hover);
  border: 1px solid rgba(99, 102, 241, 0.25);
}

.badge-img {
  background: rgba(34, 197, 94, 0.08);
  color: #86efac;
  border: 1px solid rgba(34, 197, 94, 0.2);
}

/* ── Lightbox ──────────────────────────────────────────────────────── */
.lightbox {
  position: fixed;
  inset: 0;
  z-index: 200;
  background: rgba(5, 7, 12, 0.92);
  display: flex;
  flex-direction: column;
  backdrop-filter: blur(6px);
}

.lightbox-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  padding: 1rem 1.5rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  flex-shrink: 0;
}

.lightbox-meta {
  display: flex;
  flex-direction: column;
  gap: 0.1rem;
}

.lightbox-title {
  font-size: 0.95rem;
  font-weight: 600;
  color: #fff;
}

.lightbox-issuer {
  font-size: 0.78rem;
  color: rgba(255, 255, 255, 0.5);
}

.lightbox-actions {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.lightbox-download,
.lightbox-close {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 34px;
  height: 34px;
  border-radius: 6px;
  color: rgba(255, 255, 255, 0.7);
  background: none;
  border: 1px solid rgba(255, 255, 255, 0.1);
  cursor: pointer;
  text-decoration: none;
  transition: all 0.15s;
}

.lightbox-download:hover,
.lightbox-close:hover {
  background: rgba(255, 255, 255, 0.1);
  color: #fff;
}

.lightbox-body {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1.5rem;
  overflow: auto;
}

.lightbox-img {
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
  border-radius: var(--radius);
}

.lightbox-pdf {
  width: 100%;
  height: 100%;
  border: none;
  border-radius: var(--radius);
}

/* ── Transition ────────────────────────────────────────────────────── */
.lightbox-enter-active,
.lightbox-leave-active {
  transition: opacity 0.2s ease;
}

.lightbox-enter-from,
.lightbox-leave-to {
  opacity: 0;
}

/* ── Responsive ────────────────────────────────────────────────────── */
@media (max-width: 480px) {
  .certs-grid {
    grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
    gap: 1rem;
  }

  .cert-thumb-wrap {
    height: 130px;
  }

  .lightbox-body {
    padding: 0.75rem;
  }
}
</style>
