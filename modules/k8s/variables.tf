variable "cluster_name" {
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

variable "subnet_ids" {
  type = list(string)
}

variable "instance_type" {
  type = string
  default = ""
}

variable "db_access_security_group_id" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "db_service_name" {
  type = string
}

variable "db_host" {
  type = string
}

variable "db_port" {
  type = number
}

variable "create_k8s" {
  type = bool
  default = true
}