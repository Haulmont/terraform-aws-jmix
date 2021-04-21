resource "aws_lb" "lb" {
  name = "${var.project_name}-ecs-lb"
  security_groups = [ aws_security_group.lb.id ]
  subnets = var.public_subnet_ids
}

resource "aws_lb_target_group" "target_group" {
  name = "${var.project_name}-ecs-lb-target-group"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = var.vpc_id

  health_check {
    healthy_threshold = "5"
    unhealthy_threshold = "2"
    interval = "30"
    matcher = "200"
    path = "/"
    port = "traffic-port"
    protocol = "HTTP"
    timeout = "5"
  }
}

resource "aws_lb_listener" "http" {
  count = local.enable_https ? 0 : 1

  load_balancer_arn = aws_lb.lb.arn
  port = 80
  protocol = "HTTP"

  depends_on = [aws_lb_target_group.target_group]

  default_action {
    target_group_arn = aws_lb_target_group.target_group.arn
    type = "forward"
  }
}

resource "aws_lb_listener" "http_redirect" {
  count = local.enable_https ? 1 : 0

  load_balancer_arn = aws_lb.lb.arn
  port = 80
  protocol = "HTTP"

  depends_on = [aws_lb_target_group.target_group]

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  count = local.enable_https ? 1 : 0

  load_balancer_arn = aws_lb.lb.arn
  port = 443
  protocol = "HTTPS"
  certificate_arn = aws_acm_certificate.app[0].arn
  alpn_policy = "HTTP2Preferred"

  depends_on = [aws_lb_target_group.target_group]

  default_action {
    target_group_arn = aws_lb_target_group.target_group.arn
    type = "forward"
  }
}
