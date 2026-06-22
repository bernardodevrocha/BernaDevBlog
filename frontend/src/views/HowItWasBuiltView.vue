<template>
  <!-- ── Page header ── -->
  <div class="page-header container" style="margin-bottom: 0;">
    <RouterLink to="/" class="back-link">← Voltar para o início</RouterLink>
    <h1 class="page-title" style="margin-top: 1rem;">Como eu construí este projeto</h1>
    <p class="page-subtitle">
      Uma análise técnica de cada decisão de arquitetura, segurança e performance que tomei
      durante o desenvolvimento deste portfólio.
    </p>
  </div>

  <!-- ── Visão geral ── -->
  <section class="section" id="visao-geral">
    <div class="container">
      <h2 class="section-title">Visão Geral</h2>
      <p class="section-lead">
        A ideia central foi construir algo que não fosse apenas um portfólio visual, mas uma
        demonstração real de arquitetura de software. Cada decisão técnica foi tomada com
        intenção — eu queria que qualquer desenvolvedor pudesse abrir o código e entender
        o raciocínio por trás de cada escolha.
      </p>
      <div class="overview-grid">
        <div v-for="item in overviewItems" :key="item.label" class="overview-stat">
          <span class="overview-value">{{ item.value }}</span>
          <span class="overview-label">{{ item.label }}</span>
        </div>
      </div>
    </div>
  </section>

  <!-- ── Stack ── -->
  <section class="section section-alt" id="stack">
    <div class="container">
      <h2 class="section-title">Stack Tecnológica</h2>
      <p class="section-lead">
        Escolhi cada tecnologia por um motivo específico — não por modismo, mas pela adequação
        ao problema que ela resolve.
      </p>
      <div class="stack-grid">
        <div v-for="group in stackGroups" :key="group.category" class="stack-group">
          <h3 class="stack-category">{{ group.category }}</h3>
          <div class="stack-items">
            <div v-for="item in group.items" :key="item.name" class="stack-item">
              <span class="stack-name">{{ item.name }}</span>
              <span class="stack-reason">{{ item.reason }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- ── Arquitetura ── -->
  <section class="section" id="arquitetura">
    <div class="container">
      <h2 class="section-title">Arquitetura de Microserviços</h2>
      <p class="section-lead">
        Parti de um monolito mental e deliberadamente o quebrei em serviços coesos. Cada serviço
        tem uma responsabilidade única, banco de dados próprio e comunicação interna segura via
        secret header. O diagrama abaixo mostra como as peças se encaixam:
      </p>
      <div class="arch-diagram">
        <div class="arch-layer">
          <div class="arch-box arch-client">Frontend (Vue 3)<br/><span class="arch-port">:5173</span></div>
        </div>
        <div class="arch-arrow">↓ HTTP</div>
        <div class="arch-layer">
          <div class="arch-box arch-gateway">
            API Gateway<br/><span class="arch-port">:8000</span>
            <div class="arch-badges">
              <span class="arch-badge">Rate Limit</span>
              <span class="arch-badge">JWT Guard</span>
              <span class="arch-badge">CORS</span>
              <span class="arch-badge">Headers</span>
            </div>
          </div>
        </div>
        <div class="arch-arrow">↓ X-Internal-Secret</div>
        <div class="arch-layer arch-services-row">
          <div class="arch-box arch-service">Auth Service<br/><span class="arch-port">:8001</span></div>
          <div class="arch-box arch-service">Blog Service<br/><span class="arch-port">:8002</span></div>
        </div>
        <div class="arch-arrow">↓</div>
        <div class="arch-layer">
          <div class="arch-box arch-db">PostgreSQL<br/><span class="arch-port">schemas isolados por serviço</span></div>
        </div>
      </div>
      <div class="dev-grid" style="margin-top: 2.5rem;">
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
        seguindo o princípio de <strong>defense-in-depth</strong>. Cada camada é independente:
        se uma falhar, as outras continuam protegendo o sistema.
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
        Presto muita atenção na notação e escolha correta de estruturas de dados.
        Um algoritmo com complexidade O(n²) onde cabe O(n log n) é um bug silencioso em produção.
        Abaixo estão as decisões que tomei para garantir que o sistema escale bem.
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

  <!-- ── Desafios ── -->
  <section class="section section-alt" id="desafios">
    <div class="container">
      <h2 class="section-title">Desafios que Enfrentei</h2>
      <p class="section-lead">
        Construir do zero sempre traz surpresas. Estes foram os problemas mais interessantes
        que precisei resolver durante o desenvolvimento.
      </p>
      <div class="challenge-list">
        <div v-for="challenge in challenges" :key="challenge.title" class="challenge-item">
          <div class="challenge-header">
            <span class="challenge-icon">{{ challenge.icon }}</span>
            <h3 class="challenge-title">{{ challenge.title }}</h3>
          </div>
          <p class="challenge-problem"><strong>Problema:</strong> {{ challenge.problem }}</p>
          <p class="challenge-solution"><strong>Solução:</strong> {{ challenge.solution }}</p>
        </div>
      </div>
    </div>
  </section>

  <!-- ── Melhorias Futuras ── -->
  <section class="section" id="futuro">
    <div class="container">
      <h2 class="section-title">Melhorias Futuras</h2>
      <p class="section-lead">
        Construí o projeto com evolução em mente. Estas são as próximas etapas que planejo
        implementar — cada uma delas resolve uma limitação real do sistema atual.
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

  <!-- ── Conclusão ── -->
  <section class="section section-alt" id="conclusao">
    <div class="container conclusion-wrap">
      <h2 class="section-title">O que aprendi</h2>
      <p class="section-lead">
        Este projeto me ensinou que arquitetura não é sobre usar as tecnologias mais novas —
        é sobre entender tradeoffs e tomar decisões conscientes. Microserviços adicionam
        complexidade operacional; essa complexidade só vale a pena se os benefícios de
        isolamento e escalabilidade independente forem reais para o problema em questão.
      </p>
      <p class="section-lead" style="margin-top: -1rem;">
        Escolhi Vue 3 deliberadamente para expandir o repertório — minha experiência de dia a dia
        é com React, e quis provar que consigo navegar bem em ecossistemas diferentes. Cada linha
        de código aqui tem um motivo. Se quiser discutir qualquer decisão técnica, pode me encontrar
        no GitHub ou no LinkedIn.
      </p>
      <div style="display: flex; gap: 0.75rem; flex-wrap: wrap; margin-top: 1rem;">
        <RouterLink to="/blog" class="btn btn-primary">Ver meus posts</RouterLink>
        <RouterLink to="/" class="btn btn-ghost">Voltar ao início</RouterLink>
      </div>
    </div>
  </section>
</template>

<script setup>
const overviewItems = [
  { value: '3', label: 'Microserviços' },
  { value: '6', label: 'Camadas de segurança' },
  { value: '4', label: 'Otimizações de performance' },
  { value: '1', label: 'Dev, do zero ao MVP' },
]

const stackGroups = [
  {
    category: 'Backend',
    items: [
      { name: 'Python + FastAPI', reason: 'Async nativo, tipagem forte com Pydantic, OpenAPI automático e ecossistema maduro para APIs.' },
      { name: 'SQLAlchemy (async)', reason: 'ORM com suporte a asyncio — sem bloquear threads em I/O de banco de dados.' },
      { name: 'asyncpg', reason: 'Driver PostgreSQL puro em async, mais rápido que psycopg2 em cargas concorrentes.' },
      { name: 'SlowAPI', reason: 'Rate limiting por IP integrado ao FastAPI sem necessidade de infraestrutura externa.' },
    ],
  },
  {
    category: 'Frontend',
    items: [
      { name: 'React (stack principal)', reason: 'Meu framework de maior proficiência — uso diariamente com TypeScript, hooks customizados, Context API e Zustand. É onde tenho mais experiência acumulada.' },
      { name: 'Vue 3 + Composition API', reason: 'Escolhido intencionalmente neste projeto para explorar o ecossistema fora do trabalho. A Composition API tem paralelos claros com os hooks do React, o que facilitou a curva de aprendizado.' },
      { name: 'Vite', reason: 'Build extremamente rápido em dev (HMR nativo com ESM) e bundle otimizado em produção.' },
    ],
  },
  {
    category: 'Infraestrutura',
    items: [
      { name: 'Docker + Compose', reason: 'Isolamento de ambiente garantido. Healthchecks asseguram que o banco esteja pronto antes dos serviços.' },
      { name: 'PostgreSQL', reason: 'Banco relacional robusto com suporte a schemas isolados por serviço e full-text search nativo.' },
      { name: 'Nginx', reason: 'Serve o build estático do Vue em produção com compressão gzip e cache de assets.' },
    ],
  },
]

const devSteps = [
  {
    icon: '🧩',
    title: 'Arquitetura de Microserviços',
    desc: 'Parti de um monolito mental e deliberadamente o quebrei em serviços coesos: cada serviço tem uma responsabilidade única (auth, blog, gateway), banco de dados próprio e comunicação interna segura via secret header.',
  },
  {
    icon: '🔀',
    title: 'API Gateway como Único Ponto de Entrada',
    desc: 'O gateway centraliza rate limiting, CORS, autenticação JWT e roteamento. Os serviços internos nunca ficam expostos diretamente — eles só confiam em requisições com o X-Internal-Secret correto.',
  },
  {
    icon: '🐘',
    title: 'PostgreSQL com Schemas Isolados',
    desc: 'Usei PostgreSQL com schemas isolados por serviço dentro do mesmo cluster — prática comum em times que evoluem de monolito para microserviços sem o custo de múltiplos bancos desde o início.',
  },
  {
    icon: '🐳',
    title: 'Docker Compose para Orquestração',
    desc: 'Cada serviço tem seu Dockerfile otimizado. O Compose orquestra dependências com healthchecks, garantindo que o banco esteja pronto antes dos serviços iniciarem.',
  },
  {
    icon: '⚡',
    title: 'Frontend Desacoplado',
    desc: 'Vue 3 com Composition API e Vite como bundler. O frontend só conhece o gateway — a topologia interna dos serviços é completamente transparente para ele. Escolhi Vue 3 para explorar o ecossistema; minha stack preferida é React.',
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
    desc: 'Ao listar posts com tags, usei uma subquery de IDs antes do selectinload — evitando o clássico problema de N+1 queries que explode com paginação.',
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

const challenges = [
  {
    icon: '🔐',
    title: 'Autenticação entre serviços internos',
    problem: 'Os serviços internos precisavam receber requisições do gateway sem duplicar lógica de JWT em cada um deles.',
    solution: 'Implementei um X-Internal-Secret compartilhado via variável de ambiente. O gateway verifica o JWT do usuário e repassa a requisição com o secret interno. Cada serviço só confia nesse header — nunca em JWT diretamente.',
  },
  {
    icon: '📦',
    title: 'Ordem de inicialização dos containers',
    problem: 'Os serviços tentavam conectar ao PostgreSQL antes do banco terminar de inicializar, causando crashes na subida do Compose.',
    solution: 'Adicionei healthchecks no container do PostgreSQL e usei depends_on com condition: service_healthy no Compose — garantindo que os serviços só sobem quando o banco está realmente pronto para aceitar conexões.',
  },
  {
    icon: '🖊️',
    title: 'XSS via Markdown do usuário',
    problem: 'Posts em Markdown renderizados no frontend poderiam conter HTML malicioso injetado pelo autor, executando scripts no navegador de leitores.',
    solution: 'Dupla sanitização: bleach no backend (na escrita) filtra tags HTML perigosas antes de salvar no banco; DOMPurify no frontend (na leitura) sanitiza novamente antes de renderizar — defence-in-depth aplicado ao conteúdo.',
  },
  {
    icon: '🏷️',
    title: 'Tags duplicadas em posts',
    problem: 'Ao criar ou editar um post, a mesma tag podia ser enviada múltiplas vezes no array, gerando duplicatas no banco de dados.',
    solution: 'Usei dict.fromkeys() no serviço antes de processar as tags — O(n) e preserva a ordem de inserção original, diferente de converter para set que perde a ordem.',
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
</script>

<style scoped>
/* ── Overview stats ── */
.overview-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1.25rem;
  margin-top: 0.5rem;
}

.overview-stat {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
  align-items: center;
  text-align: center;
}

.overview-value {
  font-size: 2.5rem;
  font-weight: 700;
  color: var(--color-accent);
  font-family: var(--font-mono);
  line-height: 1;
}

.overview-label {
  font-size: 0.8rem;
  color: var(--color-text-muted);
  font-weight: 500;
}

/* ── Stack ── */
.stack-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.5rem;
}

.stack-group {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.stack-category {
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--color-accent);
  padding-bottom: 0.5rem;
  border-bottom: 1px solid var(--color-border);
}

.stack-items {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.stack-item {
  display: flex;
  flex-direction: column;
  gap: 0.15rem;
  padding: 0.75rem;
  background: var(--color-surface-raised);
  border: 1px solid var(--color-border);
  border-radius: var(--radius);
}

.stack-name {
  font-size: 0.875rem;
  font-weight: 600;
  color: var(--color-text);
}

.stack-reason {
  font-size: 0.8rem;
  color: var(--color-text-muted);
  line-height: 1.6;
}

/* ── Architecture diagram ── */
.arch-diagram {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
  margin: 0 auto;
  max-width: 520px;
}

.arch-layer {
  width: 100%;
  display: flex;
  justify-content: center;
}

.arch-services-row {
  gap: 1rem;
}

.arch-arrow {
  font-size: 0.8rem;
  color: var(--color-text-muted);
  font-family: var(--font-mono);
}

.arch-box {
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: 1rem 1.5rem;
  font-size: 0.875rem;
  font-weight: 600;
  text-align: center;
  line-height: 1.6;
  width: 100%;
}

.arch-port {
  font-family: var(--font-mono);
  font-size: 0.75rem;
  font-weight: 400;
  color: var(--color-text-muted);
}

.arch-client {
  background: var(--color-accent-muted);
  border-color: var(--color-accent-muted-border);
  color: var(--color-accent-hover);
}

.arch-gateway {
  background: var(--color-surface);
  border-color: var(--color-accent);
  color: var(--color-text);
}

.arch-service {
  background: var(--color-surface-raised);
  border-color: var(--color-border);
  color: var(--color-text);
}

.arch-db {
  background: rgba(100, 116, 139, 0.08);
  border-color: var(--color-border);
  color: var(--color-text-muted);
  font-size: 0.8rem;
}

.arch-badges {
  display: flex;
  gap: 0.4rem;
  justify-content: center;
  flex-wrap: wrap;
  margin-top: 0.6rem;
}

.arch-badge {
  font-size: 0.7rem;
  font-weight: 500;
  padding: 0.15rem 0.5rem;
  background: var(--color-accent-muted);
  border: 1px solid var(--color-accent-muted-border);
  border-radius: 999px;
  color: var(--color-accent-hover);
}

/* ── Challenges ── */
.challenge-list {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.challenge-item {
  background: var(--color-surface-raised);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 0.6rem;
  transition: border-color var(--transition);
}

.challenge-item:hover {
  border-color: var(--color-accent);
}

.challenge-header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.challenge-icon {
  font-size: 1.4rem;
  line-height: 1;
}

.challenge-title {
  font-size: 1rem;
  font-weight: 600;
  color: var(--color-text);
}

.challenge-problem,
.challenge-solution {
  font-size: 0.875rem;
  color: var(--color-text-muted);
  line-height: 1.7;
}

.challenge-problem strong,
.challenge-solution strong {
  color: var(--color-text);
}

/* ── Conclusion ── */
.conclusion-wrap {
  max-width: 680px;
}

/* ── Responsive ── */
@media (max-width: 768px) {
  .overview-grid { grid-template-columns: repeat(2, 1fr); }
  .stack-grid { grid-template-columns: 1fr; }
}

@media (max-width: 480px) {
  .overview-grid { grid-template-columns: repeat(2, 1fr); }
}
</style>
