output "address" {
  value = var.deploy_type == "vm" ? module.vm[0].address : ""
}