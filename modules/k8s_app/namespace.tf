resource "kubernetes_namespace" "ns" {
  metadata {
    annotations = {
      name = local.ns_name
    }

    name = local.ns_name
  }
}