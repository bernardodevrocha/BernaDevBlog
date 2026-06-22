output "alb_dns_name" {
  description = "DNS do ALB — aponte seu dominio para este valor via CNAME"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID do ALB para uso em registros Route53 tipo ALIAS"
  value       = aws_lb.main.zone_id
}

output "ecr_urls" {
  description = "URLs dos repositorios ECR por servico"
  value       = { for k, v in aws_ecr_repository.services : k => v.repository_url }
}

output "ecs_cluster_name" {
  description = "Nome do cluster ECS"
  value       = aws_ecs_cluster.main.name
}

output "rds_endpoint" {
  description = "Endpoint do RDS (host:port)"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "github_actions_role_arn" {
  description = "ARN da IAM Role para o GitHub Actions — use em role-to-assume no workflow"
  value       = aws_iam_role.github_actions.arn
}

output "secrets_arns" {
  description = "ARNs dos secrets no Secrets Manager — preencha os valores manualmente"
  value = {
    jwt_secret_key  = aws_secretsmanager_secret.jwt_secret_key.arn
    internal_secret = aws_secretsmanager_secret.internal_secret.arn
    admin_password  = aws_secretsmanager_secret.admin_password.arn
    db_password     = aws_secretsmanager_secret.db_password.arn
  }
  sensitive = true
}
