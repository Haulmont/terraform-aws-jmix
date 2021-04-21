output "rds_subnet_group_id" {
  value = aws_db_subnet_group.rds_subnet_group.id
}

output "rds_access_sg_id" {
  value = aws_security_group.rds_access_sg.id
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}

output "rds_id" {
  value = aws_db_instance.rds.id
}

output "rds_hostname" {
  value = aws_db_instance.rds.address
}

output "rds_port" {
  value = aws_db_instance.rds.port
}

output "rds_name" {
  value = aws_db_instance.rds.name
}

output "rds_username" {
  value = aws_db_instance.rds.username
}

output "rds_password" {
  value = aws_db_instance.rds.password
}

output "env" {
  value = {
    DB_HOSTNAME = aws_db_instance.rds.address
    DB_PORT = aws_db_instance.rds.port
    DB_NAME = aws_db_instance.rds.name
    DB_USERNAME = aws_db_instance.rds.username
    DB_PASSWORD = aws_db_instance.rds.password
  }
}