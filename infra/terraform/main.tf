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

  # State remoto: previne conflitos em apply paralelos e mantém histórico
  # Crie o bucket e a tabela antes do primeiro `terraform init`:
  #   aws s3 mb s3://portfolio-terraform-state-prod --region us-east-1
  #   aws dynamodb create-table --table-name portfolio-terraform-locks \
  #     --attribute-definitions AttributeName=LockID,AttributeType=S \
  #     --key-schema AttributeName=LockID,KeyType=HASH \
  #     --billing-mode PAY_PER_REQUEST --region us-east-1
  backend "s3" {
    bucket         = "portfolio-terraform-state-prod"
    key            = "portfolio/prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "portfolio-terraform-locks"
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
