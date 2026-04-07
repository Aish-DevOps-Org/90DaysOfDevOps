module "tf_vpc" {
  source = "./modules/vpc"
  cidr = var.vpc_cidr
  public_subnet_cidr = var.subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  environment = local.environment
  project_name = var.project_name
  tags = local.common_tags
}

module "tf_sg" {
  source = "./modules/security-group"
  vpc_id = module.tf_vpc.vpc_id
  environment = local.environment
  project_name = var.project_name
  tags = local.common_tags
  ingress_ports = var.ingress_ports
}

module "tf_ec2" {
  source = "./modules/ec2-instance"
  ami_id = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id = module.tf_vpc.subnet_id
  sg_id = [module.tf_sg.sg_id]
  environment = local.environment
  project_name = var.project_name
  tags = local.common_tags
}