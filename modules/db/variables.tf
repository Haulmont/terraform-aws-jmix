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

variable "subnet_ids" {
  type = list(string)
}

variable "allocated_storage" {
  type = number
  default = 10
}

variable "instance_class" {
  type = string
  default = ""
}

variable "engine" {
  type = string
}

variable "engine_version" {
  type = string
  default = ""
}

variable "name" {
  type = string
  default = ""
}

variable "username" {
  type = string
  default = ""
}

variable "password" {
  type = string
  default = ""
}