variable "aws_region" {
  description = "Região AWS onde a infraestrutura será provisionada"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto, usado como prefixo nos recursos"
  type        = string
  default     = "portfolio"
}

variable "environment" {
  description = "Ambiente de deploy"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["prod", "staging"], var.environment)
    error_message = "Environment deve ser 'prod' ou 'staging'."
  }
}

# ── Rede ─────────────────────────────────────────────────────────────
variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# ── Domínio ───────────────────────────────────────────────────────────
variable "domain_name" {
  description = "Domínio principal da aplicação (ex: meuportfolio.com.br)"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN do certificado ACM para HTTPS no ALB (deve estar em us-east-1)"
  type        = string
}

# ── RDS ───────────────────────────────────────────────────────────────
variable "db_instance_class" {
  description = "Tipo de instância do RDS"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_username" {
  description = "Usuário master do banco de dados"
  type        = string
  default     = "portfolio"
  sensitive   = true
}

# ── ECS Tasks ─────────────────────────────────────────────────────────
variable "gateway_cpu" {
  description = "CPU units para o gateway (1024 = 1 vCPU)"
  type        = number
  default     = 256
}

variable "gateway_memory" {
  description = "Memória em MB para o gateway"
  type        = number
  default     = 512
}

variable "auth_cpu" {
  type    = number
  default = 256
}

variable "auth_memory" {
  type    = number
  default = 512
}

variable "blog_cpu" {
  type    = number
  default = 512
}

variable "blog_memory" {
  type    = number
  default = 1024
}

variable "frontend_cpu" {
  type    = number
  default = 256
}

variable "frontend_memory" {
  type    = number
  default = 512
}

# ── App Settings (não-sensíveis) ──────────────────────────────────────
variable "cors_origins" {
  description = "Origens permitidas no CORS (separadas por vírgula)"
  type        = string
}

variable "admin_email" {
  description = "E-mail do administrador"
  type        = string
}

variable "admin_name" {
  description = "Nome do administrador"
  type        = string
}

variable "jwt_algorithm" {
  type    = string
  default = "HS256"
}

variable "jwt_expire_minutes" {
  type    = number
  default = 180
}
