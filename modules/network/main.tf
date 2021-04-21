terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name = "${var.project_name}-${terraform.workspace}"

  azs = data.aws_availability_zones.available.names
  azs_count = var.azs_count != 0 ? max(min(var.azs_count, length(local.azs)), 2) : length(local.azs)

  subnet_count = local.azs_count * 3   # public (lb), private (app), private (db)
  subnet_newbits = ceil(log(local.subnet_count, 2))
  subnets = [for num in range(local.subnet_count) : cidrsubnet(var.cidr_block, local.subnet_newbits, num)]

  lb_subnets = slice(local.subnets, 0, local.azs_count)
  app_subnets = slice(local.subnets, local.azs_count, local.azs_count * 2)
  db_subnets = slice(local.subnets, local.azs_count * 2, local.azs_count * 3)

  public_subnets = var.use_private_subnets ? local.lb_subnets : concat(local.lb_subnets, local.app_subnets)
  private_subnets = var.use_private_subnets ? local.app_subnets : []
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.name}-vpc"

  cidr = var.cidr_block

  azs = slice(local.azs, 0, local.azs_count)
  private_subnets = local.public_subnets
  public_subnets = local.private_subnets

  database_subnets = local.db_subnets
  create_database_subnet_group = false

  enable_nat_gateway = var.use_private_subnets
  single_nat_gateway = true

  enable_dns_hostnames = true

  tags = var.vpc_tags
  public_subnet_tags = var.public_subnet_tags
  private_subnet_tags = var.private_subnet_tags
}