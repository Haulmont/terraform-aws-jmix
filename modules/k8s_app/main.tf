locals {
  ns_name = "${var.project_name}-${terraform.workspace}"

  env = merge(var.env, {
    DB_HOSTNAME = var.db_service_name
  })
}