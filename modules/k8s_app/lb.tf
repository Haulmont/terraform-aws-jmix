locals {
  alb_ns = "kube-system"
  service_account_name = "aws-load-balancer-controller"
  oidc_issuer_url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

data "aws_eks_cluster" "eks" {
  name = var.cluster_name
}

data "tls_certificate" "eks_oidc" {
  url = local.oidc_issuer_url
}

# IAM OIDC provider
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
  url             = local.oidc_issuer_url
}

# Policy
resource "aws_iam_policy" "alb" {
  name = "${var.cluster_name}-AWSLoadBalancerControllerIAMPolicy"
  policy = file("${path.module}/iam_policy.json")
}

# Role
data "aws_iam_policy_document" "alb_ingress_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [ aws_iam_openid_connect_provider.eks.arn ]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(local.oidc_issuer_url, "https://", "")}:sub"

      values = [
        "system:serviceaccount:${local.alb_ns}:${local.service_account_name}",
      ]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "alb_controller" {
  name               = "${var.cluster_name}-alb-controller-role"
  assume_role_policy = data.aws_iam_policy_document.alb_ingress_assume.json
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb.arn
}

# Service Account
resource "kubernetes_service_account" "alb" {
  metadata {
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
    name = local.service_account_name
    namespace = local.alb_ns
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
    }
  }
}

# Helm Chart
resource "helm_release" "alb_ingress" {
  depends_on = [
    null_resource.target_group_binding,
    kubernetes_service_account.alb
  ]

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = local.alb_ns

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = local.service_account_name
  }
}

resource "null_resource" "target_group_binding" {
  provisioner "local-exec" {
    command = "kubectl apply -k \"github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master\""
  }
}