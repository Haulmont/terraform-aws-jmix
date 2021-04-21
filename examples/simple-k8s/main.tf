terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn = ""
    session_name = ""
    external_id = ""
  }
}

module "app" {
  source = "../../"

  project_name = var.project_name
  env_type = var.env_type
  deploy_type = var.deploy_type

  db_engine = var.db_engine
  db_engine_version = var.db_engine_version

  docker_image = var.image
  env = var.env

  enable_https = var.enable_https
  domain_name = var.domain_name
  region = var.aws_region
}

