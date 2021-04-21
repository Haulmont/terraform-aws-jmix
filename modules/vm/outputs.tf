output "address" {
  value = "${local.enable_https ? "https" : "http"}://${aws_lb.lb.dns_name}"
}