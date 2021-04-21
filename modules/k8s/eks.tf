resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id = var.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  vpc_id = var.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id = var.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  create_eks = var.create_k8s

  cluster_name = var.cluster_name
  cluster_version = local.k8s_version

  vpc_id = var.vpc_id
  subnets = var.subnet_ids

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name = "worker-group"
      instance_type = local.instance_type
      asg_desired_capacity = 3
      additional_security_group_ids = [
        aws_security_group.worker_group_mgmt_one.id
      ]
    }
  ]

  worker_additional_security_group_ids = [
    aws_security_group.all_worker_mgmt.id,
    var.db_access_security_group_id
  ]
}

resource "null_resource" "kubectl" {
  count = var.create_k8s ? 1 : 0

  triggers = {
    k8s_cluster_id = module.eks.cluster_id
  }

  depends_on = [module.eks]

  provisioner "local-exec" {
    command = "aws eks --region ${var.aws_region} update-kubeconfig --name ${var.cluster_name}"
  }
}

/*
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host = element(concat(data.aws_eks_cluster.cluster[*].endpoint, [""]), 0)
  cluster_ca_certificate = base64decode(element(concat(data.aws_eks_cluster.cluster[*].certificate_authority.0.data, [""]), 0))
  token = element(concat(data.aws_eks_cluster_auth.cluster[*].token, [""]), 0)
}*/
