locals {
  services = ["gateway", "auth-service", "blog-service", "frontend"]
}

resource "aws_ecr_repository" "services" {
  for_each = toset(local.services)

  name                 = "${var.project_name}/${each.key}"
  image_tag_mutability = "MUTABLE" # permite reutilizar a tag :latest

  # Scan automático em todo push — detecta CVEs antes de qualquer deploy
  image_scanning_configuration {
    scan_on_push = true
  }

  # Criptografia com CMK opcional (padrão AES-256 já é suficiente para maioria dos casos)
  encryption_configuration {
    encryption_type = "AES256"
  }
}

# Política de lifecycle: mantém apenas as últimas 10 imagens por tag e
# remove imagens sem tag com mais de 1 dia.
# Evita crescimento ilimitado e custo de armazenamento desnecessário.
resource "aws_ecr_lifecycle_policy" "services" {
  for_each   = aws_ecr_repository.services
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Remove imagens sem tag com mais de 1 dia"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Mantém apenas as ultimas 10 imagens tagueadas"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["main", "v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = { type = "expire" }
      }
    ]
  })
}
