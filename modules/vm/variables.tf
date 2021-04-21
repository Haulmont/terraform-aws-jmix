variable "project_name" {
  type = string
}

variable "env_type" {
  type = string

  validation {
    condition = contains(["dev", "staging", "prod"], var.env_type)
    error_message = "The env_type value must be one of \"dev\", \"staging\" or \"prod\"."
  }
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "db_access_security_group_id" {
  type = string
}

variable "image" {
  type = string
}

variable "env" {
  type = map(string)
}

variable "server_port" {
  type = number
  default = 8080
}

variable "vm_instance_type" {
  type = string
  default = ""
}

variable "enable_https" {
  type = bool
  default = null
}

variable "key_pair_name" {
  type = string
  default = ""
}

variable "max_instance_size" {
  type = number
  default = 4
}

variable "min_instance_size" {
  type = number
  default = 1
}

variable "desired_capacity" {
  type = number
  default = 1
}

variable "health-check-grace-period" {
  type = number
  default = 300
}

variable "domain_name" {
  type = string
  default = ""
}