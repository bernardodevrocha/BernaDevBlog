# Portfolio Pessoal — BernaDevBlog

Blog pessoal e portfólio construído com arquitetura de microsserviços em Python (FastAPI), frontend Vue 3 e infraestrutura totalmente gerenciada na AWS via Terraform.

---

## Sumário

- [Arquitetura](#arquitetura)
- [Stack de Tecnologias](#stack-de-tecnologias)
- [Estrutura do Repositório](#estrutura-do-repositório)
- [Rodando Localmente](#rodando-localmente)
- [Infraestrutura AWS](#infraestrutura-aws)
- [CI/CD Pipeline](#cicd-pipeline)
- [Segurança](#segurança)
- [Variáveis de Ambiente](#variáveis-de-ambiente)
- [Deploy em Produção](#deploy-em-produção)

---

## Arquitetura

```
Internet
    │
    ▼
┌───────────────────────────────────┐
│       AWS Application Load        │
│       Balancer (HTTPS/443)        │
│  /api/* → Gateway                 │
│  /*     → Frontend                │
└────────────┬──────────────────────┘
             │
     ┌───────┴────────┐
     ▼                ▼
┌─────────┐    ┌────────────┐
│ Gateway │    │  Frontend  │
│ :8000   │    │  (Nginx)   │
│ FastAPI │    │  Vue 3 SPA │
└────┬────┘    └────────────┘
     │
     ├────────────────────┐
     ▼                    ▼
┌──────────┐       ┌────────────┐
│   Auth   │       │    Blog    │
│ Service  │       │  Service   │
│  :8001   │       │   :8002    │
│ FastAPI  │       │  FastAPI   │
└────┬─────┘       └─────┬──────┘
     │                   │
     └─────────┬─────────┘
               ▼
        ┌────────────┐
        │ PostgreSQL │
        │  (AWS RDS) │
        │ auth_db    │
        │ blog_db    │
        └────────────┘
```

### Fluxo de requisição

1. O usuário acessa `https://yourdomain.com`
2. O ALB roteia `/api/*` para o **Gateway** e todo o resto para o **Frontend**
3. O Gateway valida o JWT (via `INTERNAL_SECRET`), aplica rate limiting e CORS, e faz proxy para Auth ou Blog Service
4. Os serviços internos (Auth, Blog) nunca são expostos diretamente — só o Gateway os acessa, via ECS Service Discovery

### Comunicação interna

Em produção (ECS Fargate), os serviços se comunicam pelo AWS Cloud Map:

```
gateway → http://auth-service.<project>.local:8001
gateway → http://blog-service.<project>.local:8002
```

Em desenvolvimento (Docker Compose), os nomes dos containers são usados diretamente.

---

## Stack de Tecnologias

| Camada | Tecnologia |
|---|---|
| Frontend | Vue 3, Vite, Pinia, Vue Router, Axios |
| Backend | Python 3.12, FastAPI, Pydantic v2, SQLAlchemy 2 (async) |
| Banco de Dados | PostgreSQL 16 (asyncpg driver) |
| Autenticação | JWT (HS256), bcrypt |
| Segurança | Rate limiting (slowapi), CORS, Security Headers, bleach (sanitização HTML) |
| Infra | AWS ECS Fargate, RDS PostgreSQL, ALB, ECR, Secrets Manager, CloudWatch |
| IaC | Terraform >= 1.7 |
| CI/CD | GitHub Actions, OIDC (sem credenciais estáticas), Trivy |
| Servidor web | Nginx (Alpine) |
| Containerização | Docker multi-stage build |

---

## Estrutura do Repositório

```
.
├── .env.example                  # Template de variáveis de ambiente (sem segredos)
├── .gitignore
├── docker-compose.yml            # Ambiente de desenvolvimento completo
│
├── services/
│   ├── gateway/                  # API Gateway — único ponto de entrada público
│   │   ├── Dockerfile
│   │   ├── requirements.txt
│   │   └── app/
│   │       ├── config.py
│   │       ├── main.py           # FastAPI app, CORS, rate limit, security headers
│   │       ├── proxy.py          # Lógica de proxy reverso via httpx
│   │       ├── routers/          # auth, posts, tags, certificates
│   │       └── security/         # Middleware de headers, rate limiter
│   │
│   ├── auth-service/             # Autenticação, JWT, gestão de usuários
│   │   ├── Dockerfile
│   │   ├── requirements.txt
│   │   └── app/
│   │       ├── config.py         # Pydantic BaseSettings, suporte a AWS Secrets Manager
│   │       ├── main.py
│   │       ├── models/           # SQLAlchemy ORM
│   │       ├── routers/          # /auth/login, /auth/register, etc.
│   │       ├── schemas/          # Pydantic schemas de entrada/saída
│   │       └── security/         # JWT encode/decode, password hashing
│   │
│   └── blog-service/             # Posts, tags, certificados
│       ├── Dockerfile
│       ├── requirements.txt
│       └── app/
│           ├── config.py
│           ├── main.py
│           ├── models/
│           ├── routers/
│           ├── schemas/
│           └── security/
│
├── frontend/                     # SPA Vue 3
│   ├── Dockerfile                # Multi-stage: Node (dev/build) → Nginx (prod)
│   ├── nginx.conf                # SPA routing com try_files
│   ├── package.json
│   ├── vite.config.js
│   └── src/
│       ├── components/
│       ├── views/
│       ├── stores/               # Pinia stores
│       ├── services/             # Chamadas HTTP via Axios
│       └── router/
│
├── infra/
│   ├── postgres/
│   │   └── init.sql              # Cria auth_db e blog_db no startup
│   └── terraform/
│       ├── main.tf               # Provider AWS, backend S3
│       ├── variables.tf          # Declaração de todas as variáveis
│       ├── terraform.tfvars.example  # Template — copie para terraform.tfvars
│       ├── vpc.tf                # VPC, subnets públicas/privadas/banco
│       ├── security_groups.tf    # SGs para ALB, ECS, RDS
│       ├── alb.tf                # ALB, listeners HTTP/HTTPS, target groups
│       ├── ecr.tf                # Repositórios ECR + lifecycle policies
│       ├── ecs_cluster.tf        # ECS Cluster Fargate
│       ├── ecs_tasks.tf          # Task Definitions (gateway, auth, blog, frontend)
│       ├── ecs_services.tf       # ECS Services com rolling update
│       ├── service_discovery.tf  # AWS Cloud Map (namespace .local)
│       ├── rds.tf                # RDS PostgreSQL 16, Multi-AZ, senha aleatória
│       ├── secrets.tf            # AWS Secrets Manager (JWT, DB, admin)
│       ├── iam.tf                # IAM roles para ECS execution e task
│       ├── autoscaling.tf        # Auto Scaling para os serviços ECS
│       ├── cloudwatch.tf         # Log groups por serviço (30 dias retenção)
│       └── outputs.tf
│
└── .github/
    └── workflows/
        └── deploy-prod.yml       # Pipeline CI/CD completo
```

---

## Rodando Localmente

### Pré-requisitos

- Docker e Docker Compose
- Python 3.12+ (opcional, para desenvolvimento fora do container)
- Node.js 20+ (opcional, para desenvolvimento do frontend fora do container)

### Passo a passo

**1. Clone o repositório e configure as variáveis de ambiente:**

```bash
git clone https://github.com/bernardodevrocha/BernaDevBlog.git
cd BernaDevBlog

cp .env.example .env
# Edite .env com seus valores locais
```

**2. Gere os secrets para desenvolvimento:**

```bash
# JWT_SECRET_KEY e INTERNAL_SECRET
openssl rand -hex 32
```

**3. Suba todos os serviços com Docker Compose:**

```bash
docker compose up --build
```

Isso sobe automaticamente:
- PostgreSQL 16 com healthcheck (aguarda estar pronto antes dos serviços)
- Auth Service (interno, sem porta exposta no host)
- Blog Service (interno, sem porta exposta no host)
- Gateway em `http://localhost:8000`
- Frontend Vue 3 em `http://localhost:5173` com hot-reload

**4. Verifique que está tudo funcionando:**

```bash
curl http://localhost:8000/api/health
# → {"status": "ok"}
```

**5. Acesse:**

- Frontend: `http://localhost:5173`
- API (via gateway): `http://localhost:8000/api/`

> O frontend em Docker Compose usa `VITE_API_URL=http://gateway:8000` internamente (nome do serviço Docker). Se rodar o frontend fora do Docker, use `VITE_API_URL=http://localhost:8000`.

---

## Infraestrutura AWS

Toda a infraestrutura é provisionada com Terraform e armazenada no estado remoto em S3.

### Recursos criados

| Recurso | Descrição |
|---|---|
| VPC | /16 com subnets públicas, privadas e de banco em 2 AZs |
| Security Groups | ALB (80/443 públic), ECS (8000-8002 do ALB), RDS (5432 do ECS) |
| ALB | HTTPS com certificado ACM, redirect HTTP→HTTPS, roteamento /api/* |
| ECR | 1 repositório por serviço, lifecycle policy (últimas 10 imagens) |
| ECS Fargate | 4 serviços: gateway, auth-service, blog-service, frontend |
| RDS PostgreSQL 16 | Multi-AZ, 20GB gp3, backups diários 7 dias, Performance Insights |
| Secrets Manager | jwt-secret-key, internal-secret, admin-password, db-password |
| CloudWatch | Log groups /ecs/<project>/<service>, retenção 30 dias |
| IAM | ECS Execution Role, ECS Task Application Role (acesso restrito ao Secrets Manager) |
| AWS Cloud Map | Namespace `<project>.local` para service discovery interno |
| Auto Scaling | Políticas de CPU/memória para os serviços ECS |

### Configurando o backend do Terraform (estado remoto)

Antes do primeiro `terraform init`, crie o bucket S3 manualmente:

```bash
aws s3 mb s3://SEU_BUCKET_DE_ESTADO --region us-east-1
```

O bucket está declarado em `main.tf` na seção `backend "s3"`.

### Deploy da infraestrutura

```bash
cd infra/terraform

# Copie e preencha as variáveis
cp terraform.tfvars.example terraform.tfvars
# Edite terraform.tfvars com seus valores reais

terraform init
terraform plan
terraform apply
```

### Configurando secrets no AWS Secrets Manager

Após o `terraform apply`, preencha os secrets criados com valores reais:

```bash
aws secretsmanager put-secret-value \
  --secret-id "jwt-secret-key" \
  --secret-string "$(openssl rand -hex 32)"

aws secretsmanager put-secret-value \
  --secret-id "internal-secret" \
  --secret-string "$(openssl rand -hex 32)"

aws secretsmanager put-secret-value \
  --secret-id "admin-password" \
  --secret-string "sua-senha-admin-segura"
```

> A senha do banco de dados (`db-password`) é gerada automaticamente pelo Terraform com `random_password` (32 caracteres) e armazenada diretamente no Secrets Manager.

---

## CI/CD Pipeline

O pipeline (`.github/workflows/deploy-prod.yml`) é ativado em todo push para `main` e possui 4 estágios:

```
push → main
    │
    ├─ 1. Quality Gate (paralelo por serviço Python)
    │      ruff check (linting)
    │      pytest (testes)
    │
    ├─ 2. Quality Gate — Frontend
    │      npm ci
    │      npm run build (validação de compilação)
    │
    ├─ 3. Build, Scan & Push (paralelo por serviço)
    │      docker build --target production
    │      Trivy scan (CRITICAL/HIGH → falha o pipeline)
    │      Upload resultados → GitHub Security tab (SARIF)
    │      docker push → ECR (tag: SHA curto + latest)
    │
    └─ 4. Deploy ECS (2 serviços em paralelo)
           Registra nova Task Definition com imagem do commit
           Rolling Update (minimumHealthy=100%, maximum=200%)
           aws ecs wait services-stable (timeout 10min)
           Rollback automático via deployment_circuit_breaker
```

### Autenticação AWS — OIDC (sem credenciais estáticas)

O pipeline usa OpenID Connect para autenticar na AWS. O GitHub negocia um token temporário de 15 minutos a cada execução — nenhuma `AWS_ACCESS_KEY_ID` ou `AWS_SECRET_ACCESS_KEY` é armazenada em secrets.

Para configurar:

1. Crie um IAM Role com trust policy para o GitHub OIDC Provider
2. Adicione o ARN do role como secret no repositório GitHub:
   - **Nome:** `AWS_ROLE_ARN`
   - **Valor:** `arn:aws:iam::SUA_CONTA:role/SEU_ROLE`

### Deploy com zero downtime

O Rolling Update garante que:
- `minimumHealthyPercent=100`: nunca desce abaixo de 2 tasks ativas durante o deploy
- `maximumPercent=200`: sobe até 4 tasks temporariamente (2 novas + 2 antigas)
- O ALB só direciona tráfego para as novas tasks após passarem no health check
- Se o serviço não estabilizar em 10 minutos, o `deployment_circuit_breaker` do ECS executa rollback automático

### Concorrência controlada

```yaml
concurrency:
  group: deploy-production
  cancel-in-progress: false
```

Apenas um deploy roda por vez. Se um segundo push chegar enquanto o deploy está em progresso, ele aguarda — não cancela — para evitar estados inconsistentes.

---

## Segurança

### Na aplicação

| Mecanismo | Onde | Detalhe |
|---|---|---|
| Rate limiting | Gateway | slowapi, por IP |
| CORS | Gateway | Origens configuráveis via env |
| Security Headers | Gateway | X-Frame-Options, CSP, HSTS, etc. |
| JWT HS256 | Auth Service + Gateway | Expiração configurável |
| INTERNAL_SECRET | Gateway → Serviços | Header para comunicação interna segura |
| Sanitização HTML | Blog Service | bleach (previne XSS em posts Markdown) |
| Non-root containers | Todos Dockerfiles | Usuário `appuser` em todos os containers |
| Multi-stage builds | Todos Dockerfiles | Sem ferramentas de build na imagem final |

### Na infraestrutura

| Mecanismo | Detalhe |
|---|---|
| Secrets Manager | Todos os secrets em produção — nenhuma senha no código ou tfvars |
| RDS Multi-AZ | Failover automático em ~60s sem perda de dados |
| RDS criptografado | Storage encrypted = true |
| HTTPS obrigatório | ALB redireciona 100% do HTTP para HTTPS (301) |
| TLS 1.3 | `ELBSecurityPolicy-TLS13-1-2-2021-06` |
| VPC isolada | Serviços internos em subnets privadas, RDS em subnet de banco |
| SGs mínimos | RDS só aceita conexões do SG do ECS |
| OIDC no CI/CD | Tokens temporários de 15min, sem credenciais AWS estáticas |
| Trivy no pipeline | Bloqueia o deploy se encontrar CVE CRITICAL ou HIGH com fix disponível |
| ECR scan on push | Análise de vulnerabilidades em toda imagem enviada |
| IAM least privilege | Task role com permissão apenas nos secrets necessários |

### O que NÃO vai para o repositório

| Arquivo | Conteúdo sensível |
|---|---|
| `.env` | Senhas locais de desenvolvimento, JWT secret, email/senha admin |
| `infra/terraform/terraform.tfvars` | AWS Account ID, ARN do certificado ACM, domínio, credenciais |
| `infra/terraform/terraform.tfstate` | Estado completo da infraestrutura |
| `infra/terraform/.terraform/` | Cache de providers |

---

## Variáveis de Ambiente

### Desenvolvimento local (`.env`)

Copie `.env.example` para `.env` e preencha:

| Variável | Descrição |
|---|---|
| `POSTGRES_USER` | Usuário do PostgreSQL |
| `POSTGRES_PASSWORD` | Senha do PostgreSQL |
| `POSTGRES_DB` | Database padrão do PostgreSQL |
| `AUTH_DATABASE_URL` | URL completa do banco do auth-service |
| `JWT_SECRET_KEY` | Secret para assinar JWTs (`openssl rand -hex 32`) |
| `JWT_ALGORITHM` | Algoritmo JWT (padrão: HS256) |
| `JWT_EXPIRE_MINUTES` | Expiração do token em minutos (padrão: 180) |
| `ADMIN_EMAIL` | E-mail do usuário admin criado no startup |
| `ADMIN_PASSWORD` | Senha do usuário admin |
| `ADMIN_NAME` | Nome do usuário admin |
| `BLOG_DATABASE_URL` | URL completa do banco do blog-service |
| `INTERNAL_SECRET` | Secret para autenticação interna entre serviços |
| `AUTH_SERVICE_URL` | URL interna do auth-service (ex: `http://auth-service:8001`) |
| `BLOG_SERVICE_URL` | URL interna do blog-service (ex: `http://blog-service:8002`) |
| `CORS_ORIGINS` | Origens permitidas no CORS (separadas por vírgula) |
| `VITE_API_URL` | URL da API para o frontend (ex: `http://localhost:8000`) |

### Produção (GitHub Secrets)

| Secret | Descrição |
|---|---|
| `AWS_ROLE_ARN` | ARN do IAM Role para autenticação OIDC no GitHub Actions |

### Produção (AWS Secrets Manager)

Criados pelo Terraform, preenchidos manualmente após o primeiro `apply`:

| Secret | Descrição |
|---|---|
| `jwt-secret-key` | Secret para assinar JWTs em produção |
| `internal-secret` | Secret para comunicação interna entre serviços |
| `admin-password` | Senha do administrador |
| `db-password` | Gerado automaticamente pelo Terraform (random_password 32 chars) |

---

## Deploy em Produção

O deploy ocorre automaticamente via GitHub Actions em todo push para `main`.

Para o primeiro deploy manual ou para recriar a infraestrutura:

```bash
# 1. Infraestrutura
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
# preencha terraform.tfvars

terraform init
terraform apply

# 2. Preencha os secrets no Secrets Manager (veja seção acima)

# 3. Primeiro push das imagens (o pipeline faz isso automaticamente)
git push origin main

# 4. Configure o secret AWS_ROLE_ARN no GitHub
# Settings → Secrets and variables → Actions → New repository secret
```

### Monitoramento

- **Logs**: CloudWatch > Log Groups > `/ecs/<projeto>/<serviço>`
- **Health checks**: ALB Target Groups (console AWS)
- **Vulnerabilidades de imagem**: GitHub → Security → Code scanning
- **Performance do banco**: RDS Performance Insights

---

## Desenvolvimento

### Adicionando um novo endpoint

1. Adicione o router no serviço correspondente (`services/auth-service/app/routers/` ou `services/blog-service/app/routers/`)
2. Registre a rota no gateway (`services/gateway/app/routers/`)
3. Teste localmente com `docker compose up`
4. O pipeline faz lint + testes + scan + deploy automaticamente no push

### Gerando uma nova migration

Os serviços usam SQLAlchemy com `create_all` no startup para desenvolvimento. Para produção, implemente migrations com Alembic antes de adicionar à base de dados em uso.

### Rodando testes

```bash
cd services/auth-service
pip install -r requirements.txt pytest pytest-asyncio httpx
pytest tests/ -v
```
