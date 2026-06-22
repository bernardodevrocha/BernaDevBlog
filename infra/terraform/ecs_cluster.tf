resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}"

  setting {
    name  = "containerInsights"
    # Container Insights: métricas de CPU/mem por container, não só por instância.
    # Necessário para o Auto Scaling por container funcionar corretamente.
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  # base = 1: garante que ao menos 1 task SEMPRE rode em FARGATE pago.
  # Tasks adicionais do auto scaling podem usar FARGATE_SPOT (~70% mais barato),
  # que pode ser interrompido com 2min de aviso pela AWS.
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
}
