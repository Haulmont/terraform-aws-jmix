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

variable "region" {
  type = string
}

#### Network ####

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "azs_count" {
  default = 0
}

#### DB ####

variable "db_engine" {
  type = string
}

variable "db_engine_version" {
  type = string
  default = ""
}

variable "db_instance_class" {
  type = string
  default = ""
}

variable "db_name" {
  type = string
  default = ""
}

variable "db_username" {
  type = string
  default = ""
}

variable "db_password" {
  type = string
  default = ""
}

#### LB ####

variable "enable_https" {
  type = bool
  default = null
}

variable "domain_name" {
  type = string
  default = ""
}

#### App ####

variable "docker_image" {
  type = string
}

variable "deploy_type" {
  type = string
  default = "vm"

  validation {
    condition = contains(["vm", "k8s"], var.deploy_type)
    error_message = "The env_type value must be either \"vm\" or \"k8s\"."
  }
}

variable "env" {
  type = map(any)
  default = {}
}

