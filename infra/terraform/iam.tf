# ── Task Execution Role ───────────────────────────────────────────────
# Usada pelo ECS Agent (não pela aplicação) para:
# - Puxar imagem do ECR
# - Enviar logs para CloudWatch
# - Ler secrets do Secrets Manager na inicialização do container
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project_name}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_managed" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Acesso restrito ao Secrets Manager: apenas os ARNs deste projeto
resource "aws_iam_role_policy" "ecs_secrets_read" {
  name = "${var.project_name}-secrets-read"
  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["secretsmanager:GetSecretValue"]
      Resource = [
        aws_secretsmanager_secret.jwt_secret_key.arn,
        aws_secretsmanager_secret.internal_secret.arn,
        aws_secretsmanager_secret.admin_password.arn,
        aws_secretsmanager_secret.db_password.arn,
      ]
    }]
  })
}

# ── Task Application Role ─────────────────────────────────────────────
# Usada pela aplicação em tempo de execução.
# Não tem acesso a ECR nem CloudWatch — princípio do mínimo privilégio.
# Adicione aqui apenas o que a aplicação precisa em runtime (ex: S3, SES).
resource "aws_iam_role" "ecs_task_application" {
  name = "${var.project_name}-ecs-application-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# ── OIDC Provider: GitHub Actions ────────────────────────────────────
# Elimina credenciais estáticas (AWS_ACCESS_KEY_ID/SECRET).
# O GitHub negocia um token temporário de 15min com a AWS a cada run.
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

variable "github_repo" {
  description = "Repositorio GitHub no formato usuario/repo"
  type        = string
}

resource "aws_iam_role" "github_actions" {
  name = "${var.project_name}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringLike = {
          # Restringe para apenas este repo e branch main — nunca use "*"
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:ref:refs/heads/main"
        }
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "github_actions_deploy" {
  name = "${var.project_name}-github-deploy-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRAuth"
        Effect = "Allow"
        Action = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Sid    = "ECRPush"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
        ]
        # Restrito aos repositórios deste projeto
        Resource = [for repo in aws_ecr_repository.services : repo.arn]
      },
      {
        Sid    = "ECSDescribe"
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService",
          "ecs:ListTaskDefinitions",
        ]
        Resource = "*"
      },
      {
        Sid    = "PassRoleToECS"
        Effect = "Allow"
        Action = ["iam:PassRole"]
        Resource = [
          aws_iam_role.ecs_task_execution.arn,
          aws_iam_role.ecs_task_application.arn,
        ]
      }
    ]
  })
}
