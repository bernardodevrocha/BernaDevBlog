# ── SNS Topic para alertas ────────────────────────────────────────────
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"
}

# Adicione subscriptions aqui (email, Slack via Lambda, PagerDuty, etc.)
# resource "aws_sns_topic_subscription" "email" {
#   topic_arn = aws_sns_topic.alerts.arn
#   protocol  = "email"
#   endpoint  = var.alert_email
# }

# ── Dashboard CloudWatch ──────────────────────────────────────────────
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-prod"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title  = "ALB - Request Count e Erros 5xx"
          region = var.aws_region
          period = 60
          stat   = "Sum"
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.main.arn_suffix],
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", aws_lb.main.arn_suffix],
          ]
        }
      },
      {
        type = "metric"
        properties = {
          title  = "ALB - Latencia P99"
          region = var.aws_region
          period = 60
          stat   = "p99"
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.main.arn_suffix],
          ]
        }
      },
      {
        type = "metric"
        properties = {
          title  = "ECS - CPU por Servico"
          region = var.aws_region
          period = 60
          stat   = "Average"
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", "gateway"],
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", "auth-service"],
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", "blog-service"],
          ]
        }
      },
      {
        type = "metric"
        properties = {
          title  = "ECS - Task Count por Servico"
          region = var.aws_region
          period = 60
          stat   = "Average"
          metrics = [
            ["ECS/ContainerInsights", "RunningTaskCount", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", "gateway"],
            ["ECS/ContainerInsights", "RunningTaskCount", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", "blog-service"],
          ]
        }
      },
    ]
  })
}

# ── Alarme: Taxa de Erros 5xx ─────────────────────────────────────────
# Dispara se mais de 5% das requisições retornarem erro 500+ por 5min.
# Indica problema na aplicação, não no ALB.
resource "aws_cloudwatch_metric_alarm" "high_5xx_rate" {
  alarm_name          = "${var.project_name}-high-5xx-rate"
  alarm_description   = "Taxa de erros 5xx acima de 5% por 5 minutos consecutivos"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  threshold           = 5
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "error_rate"
    expression  = "(errors / requests) * 100"
    label       = "Error Rate %"
    return_data = true
  }

  metric_query {
    id = "errors"
    metric {
      metric_name = "HTTPCode_Target_5XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = 60
      stat        = "Sum"
      dimensions  = { LoadBalancer = aws_lb.main.arn_suffix }
    }
  }

  metric_query {
    id = "requests"
    metric {
      metric_name = "RequestCount"
      namespace   = "AWS/ApplicationELB"
      period      = 60
      stat        = "Sum"
      dimensions  = { LoadBalancer = aws_lb.main.arn_suffix }
    }
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

# ── Alarme: Latência P99 Alta ─────────────────────────────────────────
# Experiência do usuário degradada se P99 > 2s por mais de 5min.
resource "aws_cloudwatch_metric_alarm" "high_latency" {
  alarm_name          = "${var.project_name}-high-latency-p99"
  alarm_description   = "Latencia P99 acima de 2 segundos por 5 minutos"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  extended_statistic  = "p99"
  threshold           = 2.0
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

# ── Alarme: Healthy Hosts Abaixo do Mínimo ───────────────────────────
# Se o gateway cair para menos de 2 tasks healthy no ALB, o alarme dispara.
resource "aws_cloudwatch_metric_alarm" "low_healthy_hosts_gateway" {
  alarm_name          = "${var.project_name}-gateway-low-healthy-hosts"
  alarm_description   = "Gateway com menos de 2 instancias saudaveis no ALB"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Minimum"
  threshold           = 2
  treat_missing_data  = "breaching"

  dimensions = {
    TargetGroup  = aws_lb_target_group.gateway.arn_suffix
    LoadBalancer = aws_lb.main.arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

# ── Alarme: CPU Alta no Blog Service ─────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "blog_high_cpu" {
  alarm_name          = "${var.project_name}-blog-high-cpu"
  alarm_description   = "CPU do blog-service acima de 80% por 5 minutos"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.blog.name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

# ── Insights Query salva para debug rápido ───────────────────────────
resource "aws_cloudwatch_query_definition" "errors" {
  name = "${var.project_name}/erros-recentes"

  query_string = <<-QUERY
    fields @timestamp, @logStream, level, message, status_code, path, method
    | filter level = "ERROR" or status_code >= 500
    | sort @timestamp desc
    | limit 50
  QUERY

  log_group_names = [
    "/ecs/${var.project_name}/gateway",
    "/ecs/${var.project_name}/auth-service",
    "/ecs/${var.project_name}/blog-service",
  ]
}

resource "aws_cloudwatch_query_definition" "slow_requests" {
  name = "${var.project_name}/requisicoes-lentas"

  query_string = <<-QUERY
    fields @timestamp, method, path, duration_ms, status_code
    | filter duration_ms > 1000
    | sort duration_ms desc
    | limit 20
  QUERY

  log_group_names = [
    "/ecs/${var.project_name}/gateway",
  ]
}
