<template>
  <div class="app-wrapper">
    <NavBar />
    <main class="main-content">
      <RouterView />
    </main>
    <SiteFooter />
  </div>
</template>

<script setup>
import NavBar from '@/components/layout/NavBar.vue'
import SiteFooter from '@/components/layout/SiteFooter.vue'
</script>
