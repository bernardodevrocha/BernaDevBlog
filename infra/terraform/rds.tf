resource "random_password" "db" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Armazena a senha gerada no Secrets Manager logo após criação
resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db.result
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = aws_subnet.database[*].id
}

resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-postgres-prod"

  engine               = "postgres"
  engine_version       = "16.3"
  instance_class       = var.db_instance_class
  allocated_storage    = 20
  max_allocated_storage = 100 # auto scaling de storage até 100GB
  storage_type         = "gp3"
  storage_encrypted    = true

  db_name  = "portfolio"
  username = var.db_username
  password = random_password.db.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # Multi-AZ: replica síncrona em outra AZ — failover automático em ~60s
  # Essencial para produção. Dobra o custo mas elimina SPOF no banco.
  multi_az = true

  # Backups automáticos diários com retenção de 7 dias
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  # Protege contra delete acidental via terraform destroy
  deletion_protection = true
  skip_final_snapshot = false
  final_snapshot_identifier = "${var.project_name}-final-snapshot"

  # Performance Insights: visibilidade de queries lentas sem agente externo
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  # Enhanced Monitoring: métricas de SO a cada 60s (CPU steal, IOPS, etc.)
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn
}

resource "aws_iam_role" "rds_monitoring" {
  name = "${var.project_name}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "monitoring.rds.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
