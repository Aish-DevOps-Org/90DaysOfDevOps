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
variable "region" {
  type    = string
  default = "us-west-2"
}