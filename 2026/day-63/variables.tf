variable "region" {
  type    = string
  default = "us-west-2"
}
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "project_name" {
  type = string
}

variable "environment" {
  type    = string
  default = "dev"
}
variable "allowed_ports" {
  type    = list(number)
  default = [22, 80, 443]
}
variable "extra_tags" {
  type    = map(string)
  default = {}

}

variable "bucket" {
  type    = string
  default = "tf-bucket-var"
}