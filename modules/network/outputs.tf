output "vpc_id" {
  value = module.vpc.vpc_id
  description = "The identifier of the created VPC."
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
  description = "The identifiers of the created public subnets."
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
  description = "The identifiers of the created private subnets for compute instances."
}

output "db_subnet_ids" {
  value = module.vpc.database_subnets
  description = "The identifiers of the created private subnets for database."
}