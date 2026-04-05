#resource "aws_vpc" "aish_vpc" {
#    cidr_block = var.vpc_cidr
#    tags = merge(local.common_tags, {
#        Name = "${local.name_prefix}-vpc"
#})
#}

#resource "aws_subnet" "aish_subnet" {
#    cidr_block = var.subnet_cidr
#    vpc_id = var.vpc_id
#    map_public_ip_on_launch = "true"
#    tags = merge(local.common_tags, {
#        Name = "${local.name_prefix}-subnet"
#})
#}

# Call registry VPC module
module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "6.6.1"
    name = "terraweek-vpc"
    cidr = "10.0.0.0/16"

    azs             = ["us-west-2a", "us-west-2b"]
    public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]
  
    enable_nat_gateway = false
    enable_dns_hostnames = true
  
    tags = local.common_tags   
}

# call custom SG module
module "web_sg" {
    source = "./modules/security-group"
    vpc_id = module.vpc.vpc_id
    sg_name = "terraweek-web-sg"
    ingress_ports = [20, 80, 443]
    tags = local.common_tags
}

# call custom ec2 instance module
module "web_server" {
    source = "./modules/ec2-instance"
    ami_id = data.aws_ami.amazon_linux.id
    instance_type      = "t3.micro"
    subnet_id          = module.vpc.public_subnets[0]
    security_group_ids = [module.web_sg.sg_id]
    instance_name      = "terraweek-web"
    tags               = local.common_tags
}

module "api_server" {
  source             = "./modules/ec2-instance"
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t3.micro"
  subnet_id          = module.vpc.public_subnets[1]
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-api"
  tags               = local.common_tags
}
