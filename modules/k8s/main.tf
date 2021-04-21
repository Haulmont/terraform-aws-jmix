terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

locals {
  k8s_version = "1.19"

  instance_type_defaults = {
    dev = "t2.medium"
    staging = "t2.small"
    prod = "t2.medium"
  }
  instance_type = var.instance_type != "" ? var.instance_type : local.instance_type_defaults[var.env_type]
}