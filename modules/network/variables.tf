variable "project_name" {
  type = string
  description = "Name of the project."
}

variable "cidr_block" {
  type = string
  default = "10.0.0.0/16"
  description = "CIDR for VPC."
}

variable "azs_count" {
  type = number
  default = 0
  description = "Number of availability zones where subnets should be created. By default, all availability zones in region are used."
}

variable "use_private_subnets" {
  type = bool
  default = true
}

variable "vpc_tags" {
  type = map(string)
  default = {}
}

variable "public_subnet_tags" {
  type = map(string)
  default = {}
}

variable "private_subnet_tags" {
  type = map(string)
  default = {}
}