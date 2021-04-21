terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

locals {
  full_name = "${var.project_name}-${terraform.workspace}"

  vm_instance_type_defaults = {
    dev = "t2.micro"
    staging = "t2.small"
    prod = "t2.medium"
  }
  vm_instance_type = var.vm_instance_type != "" ? var.vm_instance_type : local.vm_instance_type_defaults[var.env_type]

  enable_https_defaults = {
    dev = false
    staging = false
    prod = true
  }
  enable_https = var.enable_https != null ? var.enable_https : local.enable_https_defaults[var.env_type]

  domain_name = var.domain_name != "" ? var.domain_name : "${terraform.workspace}.${var.project_name}.com"
}