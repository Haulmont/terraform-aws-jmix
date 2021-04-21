resource "aws_route53_zone" "public" {
  count = local.enable_https ? 1 : 0

  name = local.domain_name
}

resource "aws_acm_certificate" "app" {
  count = local.enable_https ? 1 : 0

  domain_name       = aws_route53_record.app[0].fqdn
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  count = local.enable_https ? 1 : 0

  allow_overwrite = true
  name = tolist(aws_acm_certificate.app[0].domain_validation_options)[0].resource_record_name
  records = [ tolist(aws_acm_certificate.app[0].domain_validation_options)[0].resource_record_value]
  type = tolist(aws_acm_certificate.app[0].domain_validation_options)[0].resource_record_type
  zone_id  = aws_route53_zone.public[0].id
  ttl = 60
}

resource "aws_acm_certificate_validation" "cert" {
  count = local.enable_https ? 1 : 0

  certificate_arn         = aws_acm_certificate.app[0].arn
  validation_record_fqdns = [ aws_route53_record.cert_validation[0].fqdn ]
}

resource "aws_route53_record" "app" {
  count = local.enable_https ? 1 : 0

  zone_id = aws_route53_zone.public[0].zone_id
  name    = "${var.project_name}.${aws_route53_zone.public[0].name}"
  type    = "A"
  alias {
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
    evaluate_target_health = false
  }
}