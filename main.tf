terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

locals {
  k8s = var.deploy_type == "k8s"
  full_name = "${var.project_name}-${terraform.workspace}"
  k8s_cluster_name = "${local.full_name}-eks-cluster"
  vpc_tags = local.k8s ? tomap({
    "kubernetes.io/cluster/${local.k8s_cluster_name}" = "shared"
  }) : {}
  public_subnet_tags = local.k8s ? tomap({
    "kubernetes.io/cluster/${local.k8s_cluster_name}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }) : {}
  private_subnet_tags = local.k8s ? tomap({
    "kubernetes.io/cluster/${local.k8s_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }) : {}
}

module "network" {
  source = "./modules/network"

  project_name = var.project_name
  cidr_block = var.vpc_cidr_block
  azs_count = var.azs_count

  vpc_tags = local.vpc_tags
  public_subnet_tags = local.public_subnet_tags
  private_subnet_tags = local.private_subnet_tags
}

module "db" {
  source = "./modules/db"

  project_name = var.project_name
  env_type = var.env_type

  engine = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class
  name = var.db_name
  username = var.db_username
  password = var.db_password

  vpc_id = module.network.vpc_id
  subnet_ids = module.network.db_subnet_ids

  depends_on = [ module.network ]
}

module "vm" {
  count = var.deploy_type == "vm" ? 1 : 0

  source = "./modules/vm"

  project_name = var.project_name
  env_type = var.env_type

  image = var.docker_image
  env = merge(var.env, module.db.env)

  enable_https = var.enable_https
  domain_name = var.domain_name

  vpc_id = module.network.vpc_id

  public_subnet_ids = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids

  db_access_security_group_id = module.db.rds_access_sg_id

  depends_on = [ module.network, module.db ]
}

module "k8s" {
  source = "./modules/k8s"

  create_k8s = local.k8s

  cluster_name = local.k8s_cluster_name
  env_type = var.env_type

  vpc_id = module.network.vpc_id
  subnet_ids = module.network.private_subnet_ids

  db_access_security_group_id = module.db.rds_access_sg_id
  aws_region = var.region

  db_host = module.db.rds_hostname
  db_port = module.db.rds_port
  db_service_name = var.db_engine

  depends_on = [ module.network, module.db ]
}

data "aws_eks_cluster" "cluster" {
  count = local.k8s ? 1 : 0
  name = module.k8s.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  count = local.k8s ? 1 : 0

  name = module.k8s.cluster_id
}

provider "kubernetes" {
  host = element(concat(data.aws_eks_cluster.cluster[*].endpoint, [""]), 0)
  cluster_ca_certificate = base64decode(element(concat(data.aws_eks_cluster.cluster[*].certificate_authority.0.data, [""]), 0))
  token = element(concat(data.aws_eks_cluster_auth.cluster[*].token, [""]), 0)
}

provider "helm" {
  kubernetes {
    host = element(concat(data.aws_eks_cluster.cluster[*].endpoint, [""]), 0)
    cluster_ca_certificate = base64decode(element(concat(data.aws_eks_cluster.cluster[*].certificate_authority.0.data, [""]), 0))
    token = element(concat(data.aws_eks_cluster_auth.cluster[*].token, [""]), 0)
  }
}

module "k8s_app" {
  count = local.k8s ? 1 : 0

  source = "./modules/k8s_app"

  project_name = var.project_name
  db_host = module.db.rds_hostname
  db_port = module.db.rds_port
  db_service_name = var.db_engine

  image = var.docker_image
  env = merge(var.env, module.db.env)
  cluster_name = local.k8s_cluster_name

  depends_on = [ module.k8s ]
}