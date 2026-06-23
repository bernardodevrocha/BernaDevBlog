# ── AWS Cloud Map: Service Discovery ─────────────────────────────────
# Cria o namespace DNS privado "bernadevblog.local" dentro da VPC.
# Permite que o gateway resolva "auth-service.bernadevblog.local"
# e "blog-service.bernadevblog.local" para os IPs privados das tasks.

resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "${var.project_name}.local"
  description = "Namespace DNS privado para comunicacao interna entre microservicos"
  vpc         = aws_vpc.main.id
}

# ── Service: Auth ─────────────────────────────────────────────────────
resource "aws_service_discovery_service" "auth" {
  name = "auth-service"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    # MULTIVALUE: retorna todos os IPs das tasks saudaveis (ate 8).
    # O gateway faz o balanceamento no cliente — sem necessidade de ALB interno.
    routing_policy = "MULTIVALUE"
  }

  # Delega o health check para o ECS — evita duplicar a logica de health check
  health_check_custom_config {
    failure_threshold = 1
  }
}

# ── Service: Blog ─────────────────────────────────────────────────────
resource "aws_service_discovery_service" "blog" {
  name = "blog-service"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
