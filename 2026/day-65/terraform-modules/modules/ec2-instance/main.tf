resource "aws_instance" "aish_instance" {
    instance_type = var.instance_type
    associate_public_ip_address = true
    ami = var.ami_id
    subnet_id = var.subnet_id
    vpc_security_group_ids = var.security_group_ids
    tags = var.tags
}