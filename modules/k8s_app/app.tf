resource "kubernetes_deployment" "app" {
  depends_on = [ kubernetes_namespace.ns ]

  metadata {
    name = var.project_name
    namespace = local.ns_name

    labels = {
      app = var.project_name
    }
  }
  spec {
    selector {
      match_labels = {
        app = var.project_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.project_name
        }
      }
      spec {
        container {
          name = var.project_name
          image = var.image

          resources {
            limits = {
              cpu = "0.5"
              memory = "800Mi"
            }
            requests = {
              cpu = "0.5"
              memory = "800Mi"
            }
          }

//          liveness_probe {
//            http_get {
//              path = "/"
//              port = var.server_port
//            }
//
//            initial_delay_seconds = 3
//            period_seconds = 3
//          }

          dynamic "env" {
            for_each = local.env
            content {
              name = env.key
              value = env.value
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name = var.project_name
    namespace = local.ns_name
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb-ip"
    }
    labels = {
      app = var.project_name
    }
  }
  spec {
    selector = {
      app = var.project_name
    }
    type = "LoadBalancer"
    session_affinity = "ClientIP"
    port {
      port = var.server_port
      target_port = var.server_port
    }
  }

  depends_on = [ helm_release.alb_ingress, kubernetes_namespace.ns ]
}