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
        <a href="#sobre" class="btn btn-ghost">Sobre mim</a>
      </div>
    </div>
    <div class="hero-decoration" aria-hidden="true">
      <div class="code-block">
        <span class="code-line"><span class="kw">const</span> <span class="fn">bernardo</span> = {</span>
        <span class="code-line">  <span class="str">stack</span>: [<span class="str">"Python"</span>, <span class="str">"TypeScript"</span>, <span class="str">"Vue 3"</span>],</span>
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
            Tenho interesse profundo em arquitetura de sistemas, estruturas de dados, APIs RESTful
            e boas práticas de engenharia de software.
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

  <!-- ── Como foi desenvolvido ── -->
  <section class="section" id="desenvolvimento">
    <div class="container">
      <h2 class="section-title">Como desenvolvemos este projeto</h2>
      <p class="section-lead">
        A ideia central foi construir algo que não fosse apenas um portfólio visual, mas
        uma demonstração real de arquitetura de software — cada decisão técnica tomada
        com intenção e fundamentação.
      </p>
      <div class="dev-grid">
        <div v-for="step in devSteps" :key="step.title" class="dev-card">
          <div class="dev-card-icon">{{ step.icon }}</div>
          <h3 class="dev-card-title">{{ step.title }}</h3>
          <p class="dev-card-desc">{{ step.desc }}</p>
        </div>
      </div>
    </div>
  </section>

  <!-- ── Segurança ── -->
  <section class="section section-alt" id="seguranca">
    <div class="container">
      <h2 class="section-title">Camadas de Segurança</h2>
      <p class="section-lead">
        Segurança não foi um afterthought — foi arquitetada em camadas desde o início,
        seguindo o princípio de defense-in-depth.
      </p>
      <div class="security-list">
        <div v-for="layer in securityLayers" :key="layer.title" class="security-item">
          <div class="security-badge">{{ layer.layer }}</div>
          <div class="security-info">
            <h3 class="security-title">{{ layer.title }}</h3>
            <p class="security-desc">{{ layer.desc }}</p>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- ── Performance ── -->
  <section class="section" id="performance">
    <div class="container">
      <h2 class="section-title">Performance &amp; Qualidade de Código</h2>
      <p class="section-lead">
        Prezamos muito pela notação e escolha correta de estruturas de dados.
        Um algoritmo com complexidade O(n²) onde cabe O(n log n) é um bug silencioso em produção.
      </p>
      <div class="perf-grid">
        <div v-for="item in perfItems" :key="item.title" class="perf-card">
          <h3 class="perf-title">{{ item.title }}</h3>
          <p class="perf-desc">{{ item.desc }}</p>
          <div v-if="item.code" class="perf-code">
            <code>{{ item.code }}</code>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- ── Melhorias Futuras ── -->
  <section class="section section-alt" id="futuro">
    <div class="container">
      <h2 class="section-title">Melhorias Futuras</h2>
      <p class="section-lead">
        O projeto foi construído com evolução em mente. Estas são as próximas etapas planejadas:
      </p>
      <div class="future-grid">
        <div v-for="item in futureItems" :key="item.title" class="future-card">
          <div class="future-card-header">
            <span class="future-icon">{{ item.icon }}</span>
            <span class="future-status" :class="`fstatus-${item.status}`">{{ item.statusLabel }}</span>
          </div>
          <h3 class="future-title">{{ item.title }}</h3>
          <p class="future-desc">{{ item.desc }}</p>
        </div>
      </div>
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
  { name: 'Python' }, { name: 'FastAPI' }, { name: 'TypeScript' },
  { name: 'Vue 3' }, { name: 'PostgreSQL' }, { name: 'Docker' },
  { name: 'Git' }, { name: 'REST APIs' }, { name: 'Pinia' },
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

const devSteps = [
  {
    icon: '🧩',
    title: 'Arquitetura de Microserviços',
    desc: 'Partimos de um monolito mental e deliberadamente o quebramos em serviços coesos: cada serviço tem uma responsabilidade única (auth, blog, gateway), banco de dados próprio e comunicação interna segura via secret header.',
  },
  {
    icon: '🔀',
    title: 'API Gateway como Único Ponto de Entrada',
    desc: 'O gateway centraliza rate limiting, CORS, autenticação JWT e roteamento. Os serviços internos nunca ficam expostos diretamente — eles só confiam em requisições com o X-Internal-Secret correto.',
  },
  {
    icon: '🐘',
    title: 'PostgreSQL com Schemas Isolados',
    desc: 'Usamos PostgreSQL com schemas isolados por serviço dentro do mesmo cluster — prática comum em times que evoluem de monolito para microserviços sem o custo de múltiplos bancos desde o início.',
  },
  {
    icon: '🐳',
    title: 'Docker Compose para Orquestração',
    desc: 'Cada serviço tem seu Dockerfile otimizado. O Compose orquestra dependências com healthchecks, garantindo que o banco esteja pronto antes dos serviços iniciarem.',
  },
  {
    icon: '⚡',
    title: 'Frontend Desacoplado',
    desc: 'Vue 3 com Composition API, Pinia para gerenciamento de estado e Vite como bundler. O frontend só conhece o gateway — a topologia interna dos serviços é completamente transparente para ele.',
  },
  {
    icon: '🛡️',
    title: 'Segurança como Camada, não como Feature',
    desc: 'JWT com httpOnly cookies, BCrypt para hashing de senhas, sanitização de Markdown com bleach, e HTTP security headers por middleware no gateway — cada camada independente e empilhável.',
  },
]

const securityLayers = [
  {
    layer: '01',
    title: 'Rate Limiting (SlowAPI)',
    desc: 'Limitação por IP em todas as rotas do gateway. Endpoints sensíveis (auth, criação) têm limites mais restritivos que endpoints públicos de leitura.',
  },
  {
    layer: '02',
    title: 'CORS configurável por ambiente',
    desc: 'Origins permitidas definidas por variável de ambiente. Em produção, apenas o domínio do frontend é aceito — sem wildcard.',
  },
  {
    layer: '03',
    title: 'HTTP Security Headers',
    desc: 'Middleware customizado injeta X-Content-Type-Options, X-Frame-Options, Strict-Transport-Security e Content-Security-Policy em todas as respostas.',
  },
  {
    layer: '04',
    title: 'JWT + httpOnly Cookie',
    desc: 'Tokens JWT assinados com HS256 transmitidos via cookie httpOnly e SameSite=Lax — inacessíveis por JavaScript, protegendo contra XSS.',
  },
  {
    layer: '05',
    title: 'Comunicação Interna Autenticada',
    desc: 'Serviços internos rejeitam qualquer requisição que não contenha o X-Internal-Secret correto — impedindo bypass direto caso um serviço seja acessível na rede.',
  },
  {
    layer: '06',
    title: 'Sanitização de Conteúdo',
    desc: 'Todo conteúdo Markdown é sanitizado com bleach antes de ser armazenado. No frontend, a renderização aplica higienização adicional — XSS via conteúdo não é viável.',
  },
]

const perfItems = [
  {
    title: 'Subquery para evitar N+1',
    desc: 'Ao listar posts com tags, usamos uma subquery de IDs antes do selectinload — evitando o clássico problema de N+1 queries que explode com paginação.',
    code: 'O(1) query → selectinload em batch, não por item',
  },
  {
    title: 'Deduplicação O(n) com dict',
    desc: 'Tags são deduplicadas preservando ordem de inserção usando dict.fromkeys() — complexidade O(n) no lugar de O(n²) de uma checagem ingênua com list.',
    code: 'list(dict.fromkeys(tags))  # O(n), preserva ordem',
  },
  {
    title: 'Paginação server-side',
    desc: 'O backend nunca retorna todos os registros — LIMIT/OFFSET na query SQL garante que o payload cresce O(page_size) independente do total de registros.',
    code: '.limit(per_page).offset((page-1) * per_page)',
  },
  {
    title: 'AsyncIO em toda a stack Python',
    desc: 'FastAPI + SQLAlchemy async + asyncpg = zero thread blocking. Uma única instância do uvicorn serve centenas de requisições concorrentes com I/O bound work.',
    code: 'async def get_posts(...): await db.execute(...)',
  },
]

const futureItems = [
  {
    icon: '⚡',
    title: 'Cache com Redis',
    desc: 'Adicionar Redis como cache-aside para endpoints de leitura frequente. Cache invalidation via TTL e evento de escrita — reduzindo carga no PostgreSQL em picos de tráfego.',
    status: 'planned',
    statusLabel: 'Planejado',
  },
  {
    icon: '📊',
    title: 'Observabilidade: Prometheus + Grafana',
    desc: 'Instrumentar cada serviço com métricas Prometheus (latência, throughput, error rate). Dashboards Grafana para acompanhar SLIs em tempo real e configurar alertas de SLO.',
    status: 'planned',
    statusLabel: 'Planejado',
  },
  {
    icon: '🔍',
    title: 'Distributed Tracing (OpenTelemetry)',
    desc: 'Adicionar trace IDs propagados entre gateway e serviços internos — essencial para debugar latência em sistemas distribuídos sem vasculhar logs de múltiplos containers.',
    status: 'planned',
    statusLabel: 'Planejado',
  },
  {
    icon: '🚀',
    title: 'CI/CD com GitHub Actions',
    desc: 'Pipeline de deploy automático: lint → testes → build Docker → push para registry → deploy em VPS. Ambientes de staging e produção com promoção manual controlada.',
    status: 'planned',
    statusLabel: 'Planejado',
  },
  {
    icon: '🔎',
    title: 'Full-text Search',
    desc: 'Busca nos posts via PostgreSQL tsvector/tsquery — permitindo busca por conteúdo sem depender de infraestrutura adicional como Elasticsearch.',
    status: 'idea',
    statusLabel: 'Ideia',
  },
  {
    icon: '🌐',
    title: 'Internacionalização (i18n)',
    desc: 'Suporte a inglês e português no frontend com vue-i18n — tornando o portfólio acessível para recrutadores e desenvolvedores internacionais.',
    status: 'idea',
    statusLabel: 'Ideia',
  },
]

onMounted(() => blog.fetchPosts({ perPage: 3 }))
</script>
