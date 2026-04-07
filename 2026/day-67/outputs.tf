output "vpc_id" {
  value = module.tf_vpc.vpc_id
}

output "public_subnet_id" {
  value = module.tf_vpc.subnet_id
}

output "sg_id" {
  value = module.tf_sg.sg_id
}

output "ec2_instance_id" {
  value = module.tf_ec2.instance_id
}