resource "kubernetes_service" "db" {
  depends_on = [ kubernetes_namespace.ns ]

  metadata {
    labels = {
      app = var.project_name
    }

    name = var.db_service_name
    namespace = local.ns_name
  }

  spec {
    type = "ExternalName"
    external_name = var.db_host
    selector = {
      app = var.project_name
    }
  }
}