resource "aws_cloudwatch_log_group" "logs" {
  name = "/aws/${local.full_name}"
}