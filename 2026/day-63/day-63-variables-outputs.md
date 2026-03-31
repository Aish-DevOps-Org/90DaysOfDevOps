#### Task 1: Extract Variables

Take your Day 62 infrastructure config and refactor it:

Create a variables.tf file with input variables:
```
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
```
main.tf
```
# create VPC - CIDR block 10.0.0.0/16, tag it "TerraWeek-VPC"
resource "aws_vpc" "aish_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "TerraWeek-VPC"
  }
}

# Create subnet - CIDR block 10.0.1.0/24, reference the VPC ID from step 1, enable public IP on launch, tag it "TerraWeek-Public-Subnet"
resource "aws_subnet" "aish_subnet" {
  cidr_block              = var.subnet_cidr
  vpc_id                  = aws_vpc.aish_vpc.id
  map_public_ip_on_launch = "true"
  tags = {
    Name = "TerraWeek-Public-Subnet"
  }
}

# Create internet gateway and attach to VPC
resource "aws_internet_gateway" "aish_int_gateway" {
  vpc_id = aws_vpc.aish_vpc.id
  tags = {
    Name = "TerraWeek-int-gateway"
  }
}

# Create a VPC route table - add a route for 0.0.0.0/0 pointing to the internet gateway
resource "aws_route_table" "aish_route_table" {
  vpc_id = aws_vpc.aish_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aish_int_gateway.id
  }
  tags = {
    Name = "TerraWeek-route-table"
  }

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

  tags = {
    Name = "TerraWeek-SG"
  }

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
  ami                         = "ami-014d82945a82dfba3"
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.aish_security_group.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.aish_key.key_name
  tags = {
    name = "TerraWeek-server"
  }
  lifecycle {
    create_before_destroy = true
  }
}

# create S3 bucket
resource "aws_s3_bucket" "aish_bucket" {
  bucket     = "var.bucket"
  depends_on = [aws_instance.aish_instance]
}
```
terraform plan
```
aishuser@aish-ubuntu-tws:\~/terraform-aws-adv$ terraform plan

var.project_name

Enter a value: my_project

```
-> What are the five variable types in Terraform? (string, number, bool, list, map)
- String: A sequence of Unicode characters representing text, such as names or IDs.
- Number: A numeric value, which can be either a whole number (integer) or a fractional value (float).
- Bool: A boolean value that represents either true or false, typically used for conditional logic.
- List (or tuple): An ordered sequence of values, where all elements are typically of the same type in a simple list.
- Map (or object): A group of values identified by named string labels (key-value pairs)

---

#### Task 2: Variable Files and Precedence

Write the variable precedence order from lowest to highest priority.

1. Default values in the variable declaration (default argument in a variable block).
2. Environment variables (prefixed with TF\_VAR\_, e.g., TF\_VAR\_instance\_type).
3. terraform.tfvars file (if present).
4. terraform.tfvars.json file (if present; overrides the .tfvars file if both define the same variable).
5. Any \*.auto.tfvars or \*.auto.tfvars.json files (loaded in lexical/alphabetical order).
6. \-var-file flags on the command line (in the order they are provided; later files override earlier ones).
7. \-var flags on the command line (in the order they are provided; the last one for a given variable wins and has the highest precedence).

#### Task 3: Add Outputs
```
output "vpc_id" {
  description = "ID of VPC"
  value       = aws_vpc.aish_vpc.id
}
output "subnet_id" {
  description = "ID of subnet"
  value       = aws_subnet.aish_subnet.id
}
output "instance_id" {
  description = "ID of instance"
  value       = aws_instance.aish_instance.id
}
output "instance_public_ip" {
  description = "public ip of instance"
  value       = aws_instance.aish_instance.instance_public_ip
}
output "instance_public_dns" {
  description = "public dns of instance"
  value       = aws_instance.aish_instance.instance_public_dns
}
output "security_group_id" {
  description = "ID of SG"
  value       = aws_security_group.aish_security_group.id
}

```
terraform plan
```
Plan: 10 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + instance_id         = (known after apply)
  + instance_public_dns = (known after apply)
  + instance_public_ip  = (known after apply)
  + security_group_id   = (known after apply)
  + subnet_id           = (known after apply)
  + vpc_id              = (known after apply)
```

