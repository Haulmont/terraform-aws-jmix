resource "aws_security_group" "rds_access_sg" {
  vpc_id = var.vpc_id
  name = "${local.prefix}-rds-access-security-group"

  tags = {
    Name = "${local.prefix}-rds-access-security-group"
  }
}

resource "aws_security_group" "rds_sg" {
  vpc_id = var.vpc_id
  name = "${local.prefix}-rds-security-group"

  tags = {
    Name = "${local.prefix}-rds-security-group"
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "rds_ingress_db_port" {
  type = "ingress"
  from_port = aws_db_instance.rds.port
  to_port = aws_db_instance.rds.port
  protocol = "tcp"
  security_group_id = aws_security_group.rds_sg.id
  source_security_group_id = aws_security_group.rds_access_sg.id
}