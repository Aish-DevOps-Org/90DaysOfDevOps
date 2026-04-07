variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "ami_id" {
  type = string  
}

variable "instance_type" {
    type = string  
}

variable "subnet_id" {
  type = string
}

variable "sg_id" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}