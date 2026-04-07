variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "cidr" {
    type = string  
}

variable "public_subnet_cidr" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "availability_zone" {
  type = string
}