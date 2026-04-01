 
# create VPC - CIDR block 10.0.0.0/16, tag it "TerraWeek-VPC"
resource "aws_vpc" "aish_vpc" {
  cidr_block = var.vpc_cidr
  tags = merge(local.common_tags, {
  Name = "${local.name_prefix}-vpc"
})
}

# Create subnet - CIDR block 10.0.1.0/24, reference the VPC ID from step 1, enable public IP on launch, tag it "TerraWeek-Public-Subnet"
resource "aws_subnet" "aish_subnet" {
  cidr_block              = var.subnet_cidr
  vpc_id                  = aws_vpc.aish_vpc.id
  map_public_ip_on_launch = "true"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = merge(local.common_tags, {
  Name = "${local.name_prefix}-subnet"
})
}

# Create internet gateway and attach to VPC
resource "aws_internet_gateway" "aish_int_gateway" {
  vpc_id = aws_vpc.aish_vpc.id
  tags = merge(local.common_tags, {
  Name = "${local.name_prefix}-int-gateway"
})
}

# Create a VPC route table - add a route for 0.0.0.0/0 pointing to the internet gateway
resource "aws_route_table" "aish_route_table" {
  vpc_id = aws_vpc.aish_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aish_int_gateway.id
  }
  tags = merge(local.common_tags, {
  Name = "${local.name_prefix}-route-table"
})
}

# Create route table association with subnet
resource "aws_route_table_association" "aish_route_table_association" {
  subnet_id      = aws_subnet.aish_subnet.id
  route_table_id = aws_route_table.aish_route_table.id

}

# Create security group inside the VPC
resource "aws_security_group" "aish_security_group" {
  name        = "tf_sg"
  description = "allow TLS inbound and outbound traffic"
  tags = merge(local.common_tags, {
  Name = "${local.name_prefix}-sg"
})

  # Create dynamic ingress rule
  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

# Create egress rule and allow all traffic
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.aish_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Create key pair for ec2
resource "aws_key_pair" "aish_key" {
  key_name   = "tf_ec2_key"
  public_key = file("tf-instance-key.pub")
}
# Create ec2 instance with sg attached and public IP enabled
resource "aws_instance" "aish_instance" {
  #ami                         = "ami-014d82945a82dfba3"
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.aish_security_group.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.aish_key.key_name
  tags = merge(local.common_tags, {
  Name = "${local.name_prefix}-int-gateway"
})
  lifecycle {
    create_before_destroy = true
  }
}

# create S3 bucket
resource "aws_s3_bucket" "aish_bucket" {
  bucket     = "var.bucket"
  depends_on = [aws_instance.aish_instance]
}