variable "project_name" {
  type = string
}

variable "cluster_name" {
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