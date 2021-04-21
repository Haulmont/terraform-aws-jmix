data "aws_rds_engine_version" "default" {
  engine = var.engine
}

resource "random_password" "password" {
  length = 16
  special = true
  override_special = "!#$?-_"
}

locals {
  prefix = "${var.project_name}-${terraform.workspace}"

  engine_version = var.engine_version != "" ? var.engine_version : data.aws_rds_engine_version.default.version

  name = var.name != "" ? var.name : var.project_name
  username = var.username != "" ? var.username : var.project_name
  password = var.password != "" ? var.password : random_password.password.result

  instance_class_defaults = {
    dev = "db.t2.micro"
    staging = "db.t2.small"
    prod = "db.t2.medium"
  }
  instance_class = var.instance_class != "" ? var.instance_class : local.instance_class_defaults[var.env_type]

  skip_final_snapshot = var.env_type != "prod"
  multi_az = var.env_type == "prod"
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  subnet_ids = var.subnet_ids
  name = "${local.prefix}-rds-subnet-group"

  tags = {
    Name = "${local.prefix}-rds-subnet-group"
  }
}

resource "aws_db_instance" "rds" {
  identifier = "${local.prefix}-db"
  allocated_storage = var.allocated_storage
  instance_class = local.instance_class
  engine = var.engine
  engine_version = var.engine_version
  name = local.name
  username = local.username
  password = local.password
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.id
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot = local.skip_final_snapshot
  multi_az = local.multi_az

  tags = {
    Name = "${local.prefix}-rds"
  }
}
