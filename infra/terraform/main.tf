terraform {
  required_version = ">= 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # State remoto: mantém histórico e permite rodar terraform de qualquer máquina.
  # Crie o bucket antes do primeiro `terraform init`:
  #   aws s3 mb s3://personalblogprod --region us-east-1
  backend "s3" {
    bucket  = "personalblogprod"
    key     = "portfolio/prod/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region

  # Tags aplicadas em todos os recursos automaticamente
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}
