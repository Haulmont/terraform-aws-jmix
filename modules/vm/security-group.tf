resource "aws_security_group" "ecs" {
  name = "${local.full_name}-ecs-security-group"
  vpc_id = var.vpc_id

  tags = {
    Name = "${local.full_name}-ecs-security-group"
  }
}

resource "aws_security_group_rule" "ecs_egress" {
  type = "egress"
  security_group_id = aws_security_group.ecs.id
  protocol = "-1"
  from_port = 0
  to_port = 0
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ecs_ingress_http" {
  type = "ingress"
  security_group_id = aws_security_group.ecs.id
  from_port = var.server_port
  to_port = var.server_port
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ecs_ingress_ssh" {
  type = "ingress"
  security_group_id = aws_security_group.ecs.id
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "lb" {
  name = "${local.full_name}-lb-security-group"
  vpc_id = var.vpc_id

  tags = {
    Name = "${local.full_name}-lb-security-group"
  }
}

resource "aws_security_group_rule" "lb_egress" {
  type = "egress"
  security_group_id = aws_security_group.lb.id
  protocol = "-1"
  from_port = 0
  to_port = 0
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "lb_ingress_http" {
  type = "ingress"
  security_group_id = aws_security_group.lb.id
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "lb_ingress_https" {
  type = "ingress"
  security_group_id = aws_security_group.lb.id
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}