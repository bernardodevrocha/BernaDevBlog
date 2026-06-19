<template>
  <nav v-if="pages > 1" class="pagination" aria-label="Paginação">
    <button class="page-btn" :disabled="page <= 1" @click="$emit('change', page - 1)">
      ← Anterior
    </button>

    <div class="page-numbers">
      <template v-for="n in visiblePages" :key="n">
        <span v-if="n === '…'" class="page-ellipsis">…</span>
        <button
          v-else
          class="page-btn page-num"
          :class="{ active: n === page }"
          @click="$emit('change', n)"
        >
          {{ n }}
        </button>
      </template>
    </div>

    <button class="page-btn" :disabled="page >= pages" @click="$emit('change', page + 1)">
      Próxima →
    </button>
  </nav>
  <p v-else-if="total > 0" class="pagination-info">
    {{ total }} {{ total === 1 ? 'post' : 'posts' }}
  </p>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  page: { type: Number, required: true },
  pages: { type: Number, required: true },
  total: { type: Number, required: true },
  perPage: { type: Number, required: true },
})

defineEmits(['change'])

const visiblePages = computed(() => {
  const { page, pages } = props
  if (pages <= 7) return Array.from({ length: pages }, (_, i) => i + 1)

  const result = []
  const addPage = (n) => result.push(n)
  const addEllipsis = () => { if (result.at(-1) !== '…') result.push('…') }

  addPage(1)
  if (page > 3) addEllipsis()

  for (let n = Math.max(2, page - 1); n <= Math.min(pages - 1, page + 1); n++) {
    addPage(n)
  }

  if (page < pages - 2) addEllipsis()
  addPage(pages)

  return result
})
</script>

<style scoped>
.pagination {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 2.5rem 0 0;
  flex-wrap: wrap;
}

.pagination-info {
  text-align: center;
  color: var(--color-text-muted);
  font-size: 0.875rem;
  padding-top: 2rem;
}

.page-numbers {
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.page-btn {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  color: var(--color-text-muted);
  padding: 0.4rem 0.9rem;
  border-radius: var(--radius);
  font-size: 0.875rem;
  cursor: pointer;
  transition: all var(--transition);
  white-space: nowrap;
  font-family: var(--font-sans);
}

.page-btn:hover:not(:disabled):not(.active) {
  border-color: var(--color-accent);
  color: var(--color-text);
}

.page-btn:disabled {
  opacity: 0.35;
  cursor: not-allowed;
}

.page-num {
  min-width: 36px;
  text-align: center;
  padding: 0.4rem 0.5rem;
}

.page-num.active {
  background: var(--color-accent);
  border-color: var(--color-accent);
  color: #fff;
  cursor: default;
}

.page-ellipsis {
  color: var(--color-text-subtle);
  padding: 0 0.25rem;
  user-select: none;
}
</style>
