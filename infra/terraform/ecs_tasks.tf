# ── Log Groups (um por serviço) ───────────────────────────────────────
resource "aws_cloudwatch_log_group" "services" {
  for_each          = toset(["gateway", "auth-service", "blog-service", "frontend"])
  name              = "/ecs/${var.project_name}/${each.key}"
  retention_in_days = 30
}

# ── Locals: URLs internas dos serviços via ECS Service Discovery ──────
# Em Fargate, a comunicação interna usa os nomes de serviço ECS.
# O gateway chama auth e blog pelos nomes resolvidos pelo Cloud Map.
locals {
  auth_internal_url = "http://auth-service.${var.project_name}.local:8001"
  blog_internal_url = "http://blog-service.${var.project_name}.local:8002"
}

# ── Task Definition: Gateway ──────────────────────────────────────────
resource "aws_ecs_task_definition" "gateway" {
  family                   = "${var.project_name}-gateway"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.gateway_cpu
  memory                   = var.gateway_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_application.arn

  container_definitions = jsonencode([{
    name      = "gateway"
    image     = "${aws_ecr_repository.services["gateway"].repository_url}:latest"
    essential = true

    portMappings = [{
      containerPort = 8000
      protocol      = "tcp"
    }]

    environment = [
      { name = "APP_ENV",            value = "production" },
      { name = "AUTH_SERVICE_URL",   value = local.auth_internal_url },
      { name = "BLOG_SERVICE_URL",   value = local.blog_internal_url },
      { name = "JWT_ALGORITHM",      value = var.jwt_algorithm },
      { name = "CORS_ORIGINS",       value = var.cors_origins },
    ]

    secrets = [
      { name = "JWT_SECRET_KEY",  valueFrom = aws_secretsmanager_secret.jwt_secret_key.arn },
      { name = "INTERNAL_SECRET", valueFrom = aws_secretsmanager_secret.internal_secret.arn },
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.services["gateway"].name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
        "mode"                  = "non-blocking"
        "max-buffer-size"       = "25m"
      }
    }

    healthCheck = {
      command     = ["CMD-SHELL", "python -c \"import urllib.request; urllib.request.urlopen('http://localhost:8000/api/health')\" || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 60
    }
  }])
}

# ── Task Definition: Auth Service ─────────────────────────────────────
resource "aws_ecs_task_definition" "auth" {
  family                   = "${var.project_name}-auth-service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.auth_cpu
  memory                   = var.auth_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_application.arn

  container_definitions = jsonencode([{
    name      = "auth-service"
    image     = "${aws_ecr_repository.services["auth-service"].repository_url}:latest"
    essential = true

    portMappings = [{
      containerPort = 8001
      protocol      = "tcp"
    }]

    environment = [
      { name = "APP_ENV",              value = "production" },
      { name = "JWT_ALGORITHM",        value = var.jwt_algorithm },
      { name = "JWT_EXPIRE_MINUTES",   value = tostring(var.jwt_expire_minutes) },
      { name = "ADMIN_EMAIL",          value = var.admin_email },
      { name = "ADMIN_NAME",           value = var.admin_name },
      # DATABASE_URL sem senha: postgresql+asyncpg://user@host:5432/auth_db
      # A senha vem do secret abaixo e é substituída em runtime pela aplicação
      { name = "DB_HOST",              value = aws_db_instance.main.address },
      { name = "DB_USER",              value = var.db_username },
      { name = "DB_NAME_AUTH",         value = "auth_db" },
    ]

    secrets = [
      { name = "JWT_SECRET_KEY",    valueFrom = aws_secretsmanager_secret.jwt_secret_key.arn },
      { name = "INTERNAL_SECRET",   valueFrom = aws_secretsmanager_secret.internal_secret.arn },
      { name = "ADMIN_PASSWORD",    valueFrom = aws_secretsmanager_secret.admin_password.arn },
      { name = "DB_PASSWORD",       valueFrom = aws_secretsmanager_secret.db_password.arn },
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.services["auth-service"].name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
        "mode"                  = "non-blocking"
        "max-buffer-size"       = "25m"
      }
    }

    healthCheck = {
      command     = ["CMD-SHELL", "python -c \"import urllib.request; urllib.request.urlopen('http://localhost:8001/health')\" || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 90
    }
  }])
}

# ── Task Definition: Blog Service ─────────────────────────────────────
resource "aws_ecs_task_definition" "blog" {
  family                   = "${var.project_name}-blog-service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.blog_cpu
  memory                   = var.blog_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_application.arn

  container_definitions = jsonencode([{
    name      = "blog-service"
    image     = "${aws_ecr_repository.services["blog-service"].repository_url}:latest"
    essential = true

    portMappings = [{
      containerPort = 8002
      protocol      = "tcp"
    }]

    environment = [
      { name = "APP_ENV",         value = "production" },
      { name = "DB_HOST",         value = aws_db_instance.main.address },
      { name = "DB_USER",         value = var.db_username },
      { name = "DB_NAME_BLOG",    value = "blog_db" },
    ]

    secrets = [
      { name = "INTERNAL_SECRET", valueFrom = aws_secretsmanager_secret.internal_secret.arn },
      { name = "DB_PASSWORD",     valueFrom = aws_secretsmanager_secret.db_password.arn },
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.services["blog-service"].name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
        "mode"                  = "non-blocking"
        "max-buffer-size"       = "25m"
      }
    }

    healthCheck = {
      command     = ["CMD-SHELL", "python -c \"import urllib.request; urllib.request.urlopen('http://localhost:8002/health')\" || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 90
    }
  }])
}

# ── Task Definition: Frontend ─────────────────────────────────────────
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.project_name}-frontend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.frontend_cpu
  memory                   = var.frontend_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_application.arn

  container_definitions = jsonencode([{
    name      = "frontend"
    image     = "${aws_ecr_repository.services["frontend"].repository_url}:latest"
    essential = true

    portMappings = [{
      containerPort = 80
      protocol      = "tcp"
    }]

    environment = [
      { name = "APP_ENV", value = "production" },
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.services["frontend"].name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
        "mode"                  = "non-blocking"
        "max-buffer-size"       = "25m"
      }
    }

    healthCheck = {
      command     = ["CMD-SHELL", "wget -qO- http://localhost:80/ > /dev/null || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 30
    }
  }])
}
