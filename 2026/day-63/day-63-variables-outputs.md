#### Task 1: Extract Variables

Take your Day 62 infrastructure config and refactor it:

Create a variables.tf file with input variables:



```

variable "region" {

&#x20; type    = string

&#x20; default = "us-west-2"

}

variable "vpc\_cidr" {

&#x20; type    = string

&#x20; default = "10.0.0.0/16"

}

variable "subnet\_cidr" {

&#x20; type    = string

&#x20; default = "10.0.1.0/24"

}

variable "instance\_type" {

&#x20; type    = string

&#x20; default = "t3.micro"

}

variable "project\_name" {

&#x20; type = string

}



variable "environment" {

&#x20; type    = string

&#x20; default = "dev"

}

variable "allowed\_ports" {

&#x20; type    = list(number)

&#x20; default = \[22, 80, 443]

}

variable "extra\_tags" {

&#x20; type    = map(string)

&#x20; default = {}

}

```



```

main.tf



\# create VPC - CIDR block 10.0.0.0/16, tag it "TerraWeek-VPC"

resource "aws\_vpc" "aish\_vpc" {

&#x20; cidr\_block = var.vpc\_cidr

&#x20; tags = {

&#x20;   Name = "TerraWeek-VPC"

&#x20; }

}



\# Create subnet - CIDR block 10.0.1.0/24, reference the VPC ID from step 1, enable public IP on launch, tag it "TerraWeek-Public-Subnet"

resource "aws\_subnet" "aish\_subnet" {

&#x20; cidr\_block              = var.subnet\_cidr

&#x20; vpc\_id                  = aws\_vpc.aish\_vpc.id

&#x20; map\_public\_ip\_on\_launch = "true"

&#x20; tags = {

&#x20;   Name = "TerraWeek-Public-Subnet"

&#x20; }

}



\# Create internet gateway and attach to VPC

resource "aws\_internet\_gateway" "aish\_int\_gateway" {

&#x20; vpc\_id = aws\_vpc.aish\_vpc.id

&#x20; tags = {

&#x20;   Name = "TerraWeek-int-gateway"

&#x20; }

}



\# Create a VPC route table - add a route for 0.0.0.0/0 pointing to the internet gateway

resource "aws\_route\_table" "aish\_route\_table" {

&#x20; vpc\_id = aws\_vpc.aish\_vpc.id

&#x20; route {

&#x20;   cidr\_block = "0.0.0.0/0"

&#x20;   gateway\_id = aws\_internet\_gateway.aish\_int\_gateway.id

&#x20; }

&#x20; tags = {

&#x20;   Name = "TerraWeek-route-table"

&#x20; }



}



\# Create route table association with subnet

resource "aws\_route\_table\_association" "aish\_route\_table\_association" {

&#x20; subnet\_id      = aws\_subnet.aish\_subnet.id

&#x20; route\_table\_id = aws\_route\_table.aish\_route\_table.id



}



\# Create security group inside the VPC

resource "aws\_security\_group" "aish\_security\_group" {

&#x20; name        = "tf\_sg"

&#x20; description = "allow TLS inbound and outbound traffic"



&#x20; tags = {

&#x20;   Name = "TerraWeek-SG"

&#x20; }



&#x20; # Create dynamic ingress rule

&#x20; dynamic "ingress" {

&#x20;   for\_each = var.allowed\_ports

&#x20;   content {

&#x20;     from\_port   = ingress.value

&#x20;     to\_port     = ingress.value

&#x20;     protocol    = "tcp"

&#x20;     cidr\_blocks = \["0.0.0.0/0"]

&#x20;   }

&#x20; }

}





\# Create egress rule and allow all traffic

resource "aws\_vpc\_security\_group\_egress\_rule" "allow\_all\_traffic" {

&#x20; security\_group\_id = aws\_security\_group.aish\_security\_group.id

&#x20; cidr\_ipv4         = "0.0.0.0/0"

&#x20; ip\_protocol       = "-1"

}





\# Create key pair for ec2

resource "aws\_key\_pair" "aish\_key" {

&#x20; key\_name   = "tf\_ec2\_key"

&#x20; public\_key = file("tf-instance-key.pub")

}

\# Create ec2 instance with sg attached and public IP enabled

resource "aws\_instance" "aish\_instance" {

&#x20; ami                         = "ami-014d82945a82dfba3"

&#x20; instance\_type               = var.instance\_type

&#x20; vpc\_security\_group\_ids      = \[aws\_security\_group.aish\_security\_group.id]

&#x20; associate\_public\_ip\_address = true

&#x20; key\_name                    = aws\_key\_pair.aish\_key.key\_name

&#x20; tags = {

&#x20;   name = "TerraWeek-server"

&#x20; }

&#x20; lifecycle {

&#x20;   create\_before\_destroy = true

&#x20; }

}



\# create S3 bucket

resource "aws\_s3\_bucket" "aish\_bucket" {

&#x20; bucket     = "tf\_bucket"

&#x20; depends\_on = \[aws\_instance.aish\_instance]

}```



\-> terraform plan - prompted for project value

```

aishuser@aish-ubuntu-tws:\~/terraform-aws-adv$ terraform plan

var.project\_name

&#x20; Enter a value: my\_project

```

\-> What are the five variable types in Terraform? (string, number, bool, list, map)





\---



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

output "vpc\_id" {

&#x20; description = "ID of VPC"

&#x20; value       = aws\_vpc.aish\_vpc.id

}

output "subnet\_id" {

&#x20; description = "ID of subnet"

&#x20; value       = aws\_subnet.aish\_subnet.id

}

output "instance\_id" {

&#x20; description = "ID of instance"

&#x20; value       = aws\_instance.aish\_instance.id

}

output "instance\_public\_ip" {

&#x20; description = "public ip of instance"

&#x20; value       = aws\_instance.aish\_instance.instance\_public\_ip

}

output "instance\_public\_dns" {

&#x20; description = "public dns of instance"

&#x20; value       = aws\_instance.aish\_instance.instance\_public\_dns

}

output "security\_group\_id" {

&#x20; description = "ID of SG"

&#x20; value       = aws\_security\_group.aish\_security\_group.id

}

```

```

Plan: 10 to add, 0 to change, 0 to destroy.



Changes to Outputs:

&#x20; + instance\_id         = (known after apply)

&#x20; + instance\_public\_dns = (known after apply)

&#x20; + instance\_public\_ip  = (known after apply)

&#x20; + security\_group\_id   = (known after apply)

&#x20; + subnet\_id           = (known after apply)

&#x20; + vpc\_id              = (known after apply)



```

