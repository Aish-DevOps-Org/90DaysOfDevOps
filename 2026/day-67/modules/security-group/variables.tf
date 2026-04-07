variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ingress_ports" {
  type = list(number)
}

variable "tags" {
  type = map(string)
}