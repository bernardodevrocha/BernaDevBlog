# ── Auto Scaling: Blog Service ────────────────────────────────────────
# O blog é o serviço que recebe tráfego externo direto de usuários.
# É o principal candidato a scaling por pico de leituras.

resource "aws_appautoscaling_target" "blog" {
  max_capacity       = 10
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.blog.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Política 1: CPU Tracking
# Target Tracking mantém a CPU média em 70%.
# Se subir acima, o ECS sobe tasks automaticamente.
# Se cair abaixo por 5min (scale_in_cooldown), reduz tasks.
resource "aws_appautoscaling_policy" "blog_cpu" {
  name               = "${var.project_name}-blog-cpu-tracking"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.blog.resource_id
  scalable_dimension = aws_appautoscaling_target.blog.scalable_dimension
  service_namespace  = aws_appautoscaling_target.blog.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

# Política 2: Memória Tracking
# Vaza de memória ou caching agressivo pode encher a RAM antes da CPU.
resource "aws_appautoscaling_policy" "blog_memory" {
  name               = "${var.project_name}-blog-memory-tracking"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.blog.resource_id
  scalable_dimension = aws_appautoscaling_target.blog.scalable_dimension
  service_namespace  = aws_appautoscaling_target.blog.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 75.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}

# ── Auto Scaling: Gateway ─────────────────────────────────────────────
resource "aws_appautoscaling_target" "gateway" {
  max_capacity       = 6
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.gateway.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "gateway_cpu" {
  name               = "${var.project_name}-gateway-cpu-tracking"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.gateway.resource_id
  scalable_dimension = aws_appautoscaling_target.gateway.scalable_dimension
  service_namespace  = aws_appautoscaling_target.gateway.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

# ── Auto Scaling: Auth Service ────────────────────────────────────────
resource "aws_appautoscaling_target" "auth" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.auth.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "auth_cpu" {
  name               = "${var.project_name}-auth-cpu-tracking"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.auth.resource_id
  scalable_dimension = aws_appautoscaling_target.auth.scalable_dimension
  service_namespace  = aws_appautoscaling_target.auth.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}
