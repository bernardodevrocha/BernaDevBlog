<template>
  <!-- ── Hero ── -->
  <section class="hero container">
    <div class="hero-content">
      <span class="hero-tag">Desenvolvedor Full Stack</span>
      <h1 class="hero-title">Olá, sou <span class="accent">Bernardo</span></h1>
      <p class="hero-subtitle">
        Apaixonado por construir sistemas robustos, APIs bem projetadas e interfaces modernas.
        Aqui documento minha jornada, projetos e aprendizados técnicos.
      </p>
      <div class="hero-actions">
        <RouterLink to="/blog" class="btn btn-primary">Ver Blog</RouterLink>
        <RouterLink to="/certificados" class="btn btn-ghost">Certificados</RouterLink>
        <RouterLink to="/como-foi-feito" class="btn btn-ghost">Como foi feito →</RouterLink>
      </div>
    </div>
    <div class="hero-decoration" aria-hidden="true">
      <div class="code-block">
        <span class="code-line"><span class="kw">const</span> <span class="fn">bernardo</span> = {</span>
        <span class="code-line">  <span class="str">stack</span>: [<span class="str">"Python"</span>, <span class="str">"React"</span>, <span class="str">"FastAPI"</span>],</span>
        <span class="code-line">  <span class="str">arch</span>: <span class="str">"microservices"</span>,</span>
        <span class="code-line">  <span class="str">focus</span>: <span class="str">"fullstack"</span>,</span>
        <span class="code-line">  <span class="str">learning</span>: <span class="kw">true</span>,</span>
        <span class="code-line">}</span>
      </div>
    </div>
  </section>

  <!-- ── Sobre mim ── -->
  <section class="section" id="sobre">
    <div class="container">
      <h2 class="section-title">Sobre mim</h2>
      <div class="about-grid">
        <div class="about-text">
          <p>
            Sou desenvolvedor com foco em sistemas backend robustos e interfaces modernas.
            No frontend, trabalho principalmente com <strong>React</strong> — meu framework
            de maior proficiência, que uso diariamente com TypeScript, hooks customizados e
            gerenciamento de estado. No backend, Python com FastAPI.
          </p>
          <p>
            Esse portfólio é onde documento minha jornada — desde conceitos fundamentais
            até projetos práticos com arquitetura de microserviços em produção.
          </p>
        </div>
        <div class="skills-grid">
          <div v-for="skill in skills" :key="skill.name" class="skill-item">
            <span>{{ skill.name }}</span>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- ── Experiências ── -->
  <section class="section section-alt" id="experiencias">
    <div class="container">
      <h2 class="section-title">Experiências</h2>
      <div class="timeline">
        <div v-for="exp in experiences" :key="exp.role + exp.company" class="timeline-item">
          <div class="timeline-dot"></div>
          <div class="timeline-content">
            <div class="timeline-header">
              <h3 class="timeline-role">{{ exp.role }}</h3>
              <span class="timeline-period">{{ exp.period }}</span>
            </div>
            <p class="timeline-company">{{ exp.company }}</p>
            <p class="timeline-desc">{{ exp.description }}</p>
            <div class="post-tags">
              <span v-for="tag in exp.tags" :key="tag" class="tag">{{ tag }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- ── Como foi feito (teaser) ── -->
  <section class="section section-alt" id="como-foi-feito">
    <div class="container">
      <h2 class="section-title">Como eu construí este projeto</h2>
      <p class="section-lead">
        Este portfólio não é apenas uma vitrine — é uma demonstração real de arquitetura de software.
        Microserviços com gateway centralizado, 6 camadas de segurança, async em toda a stack Python
        e decisões de performance conscientemente documentadas.
      </p>
      <div class="teaser-pills">
        <span class="teaser-pill">🧩 Microserviços</span>
        <span class="teaser-pill">🔀 API Gateway</span>
        <span class="teaser-pill">🛡️ Defense-in-depth</span>
        <span class="teaser-pill">⚡ AsyncIO</span>
        <span class="teaser-pill">🐳 Docker Compose</span>
        <span class="teaser-pill">📦 Schemas isolados</span>
      </div>
      <RouterLink to="/como-foi-feito" class="btn btn-primary" style="margin-top: 2rem;">
        Ver análise técnica completa →
      </RouterLink>
    </div>
  </section>

  <!-- ── Posts Recentes ── -->
  <section v-if="blog.posts.length" class="section">
    <div class="container">
      <div class="section-header">
        <h2 class="section-title">Posts Recentes</h2>
        <RouterLink to="/blog" class="link-more">Ver todos →</RouterLink>
      </div>
      <div class="posts-grid">
        <PostCard v-for="post in blog.posts.slice(0, 3)" :key="post.id" :post="post" />
      </div>
    </div>
  </section>
</template>

<script setup>
import { onMounted } from 'vue'
import PostCard from '@/components/blog/PostCard.vue'
import { useBlogStore } from '@/stores/blog'

const blog = useBlogStore()

const skills = [
  { name: 'Python' }, { name: 'React' }, { name: 'FastAPI' },
  { name: 'TypeScript' }, { name: 'Vue 3' }, { name: 'PostgreSQL' },
  { name: 'Docker' }, { name: 'Git' }, { name: 'REST APIs' },
]

const experiences = [
  {
    role: 'Desenvolvedor Full Stack',
    company: 'Projeto Pessoal',
    period: '1 mês',
    description:
      'Desenvolvimento full stack com foco em arquitetura de microserviços: gateway, auth-service, blog-service e frontend Vue 3 integrados via Docker Compose.',
    tags: ['Python', 'FastAPI', 'Vue 3', 'Docker', 'PostgreSQL'],
  },
  {
    role: 'Desenvolvedor Frontend',
    company: 'MTI — Mato Grosso Tecnologia da Informação',
    period: '1 ano e 10 meses',
    description:
      'Desenvolvimento e manutenção de sistemas web internos para o estado de Mato Grosso. Criação de interfaces com foco em usabilidade, acessibilidade e performance em aplicações de grande escala.',
    tags: ['Vue 3', 'TypeScript', 'REST APIs', 'Git'],
  },
  {
    role: 'Desenvolvedor de APIs',
    company: 'Projetos Pessoais',
    period: 'Contínuo',
    description:
      'Construção de APIs REST com TypeScript: tipagem forte, validação de schemas, arquitetura em camadas (controller → service → repository) e documentação via OpenAPI.',
    tags: ['TypeScript', 'Node.js', 'OpenAPI', 'Zod'],
  },
]

onMounted(() => blog.fetchPosts({ perPage: 3 }))
</script>
