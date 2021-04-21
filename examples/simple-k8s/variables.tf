variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "env_type" {
  type = string
}

variable "db_engine" {
  type = string
}

variable "db_engine_version" {
  type = string
  default = ""
}

variable "image" {
  type = string
}

variable "env" {
  type = map(any)
  default = {}
}

variable "enable_https" {
  type = bool
  default = false
}

variable "domain_name" {
  type = string
  default = ""
}

variable "deploy_type" {
  type = string
  default = ""
}