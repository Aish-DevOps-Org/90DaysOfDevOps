variable "region" {
    type = string
    default = "us-west-2"
}

variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "tags" {
    type = map(string)
    default = {}
}

variable "project_name" {
    type = string
}

variable "environment" {
    type = string
}

