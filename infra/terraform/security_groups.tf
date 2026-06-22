# ── ALB Security Group ────────────────────────────────────────────────
# Único ponto de entrada da internet. Só aceita 80 (redirect) e 443 (HTTPS).
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Entrada da internet para o Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS da internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP — redireciona para HTTPS no listener"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Saida para os containers ECS"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ── ECS Tasks Security Group ──────────────────────────────────────────
# Containers só aceitam tráfego do ALB ou de outros containers internos.
# assign_public_ip = false garante que eles não são acessíveis diretamente.
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project_name}-ecs-tasks-sg"
  description = "Containers ECS: aceita apenas trafego do ALB e interno"
  vpc_id      = aws_vpc.main.id

  # Gateway: recebe do ALB
  ingress {
    description     = "ALB → Gateway (8000)"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Frontend: recebe do ALB
  ingress {
    description     = "ALB → Frontend (80)"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Comunicação interna entre microserviços (gateway → auth, gateway → blog)
  ingress {
    description = "Comunicacao interna entre containers"
    from_port   = 8001
    to_port     = 8002
    protocol    = "tcp"
    self        = true
  }

  egress {
    description = "Saida para RDS, ECR (via endpoint), CloudWatch, Secrets Manager"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ── RDS Security Group ────────────────────────────────────────────────
# O banco só é acessível pelos containers ECS. Nunca pela internet.
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "RDS PostgreSQL: aceita apenas trafego dos containers ECS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL apenas dos containers ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
