# ── Secrets Manager ───────────────────────────────────────────────────
# Segredos são criados vazios pelo Terraform.
# Os VALORES são preenchidos manualmente via Console ou CLI:
#   aws secretsmanager put-secret-value \
#     --secret-id portfolio/prod/jwt-secret-key \
#     --secret-string "seu-valor-aqui"
#
# Motivo: nunca colocar valores sensíveis no estado do Terraform (tfstate).

resource "aws_secretsmanager_secret" "jwt_secret_key" {
  name                    = "${var.project_name}/${var.environment}/jwt-secret-key"
  description             = "Chave secreta para assinar tokens JWT"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret" "internal_secret" {
  name                    = "${var.project_name}/${var.environment}/internal-secret"
  description             = "Segredo para autenticacao entre microservicos internos"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret" "admin_password" {
  name                    = "${var.project_name}/${var.environment}/admin-password"
  description             = "Senha do usuario administrador"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${var.project_name}/${var.environment}/db-password"
  description             = "Senha do banco de dados PostgreSQL RDS"
  recovery_window_in_days = 7
}

# Rotação automática de senha do banco a cada 30 dias (opcional mas recomendado)
# Requer que a aplicação suporte reconexão graceful.
# resource "aws_secretsmanager_secret_rotation" "db_password" {
#   secret_id           = aws_secretsmanager_secret.db_password.id
#   rotation_lambda_arn = aws_lambda_function.rotate_secret.arn
#   rotation_rules {
#     automatically_after_days = 30
#   }
# }
