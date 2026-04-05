#### Task 1: Understand Module Structure

###### What is the difference between a "root module" and a "child module"?

**Root module:** dir where terraform starts evaluating the infrastructure. Where we run TF commands.

**Child module:** Any module that is called from another module, usually root module.

Child modules can themselves call other modules — forming a module tree.

**ex.** Root Module

	          └── calls ──> Child Module (vpc)

                  	          └── calls ──> Child Module (subnets)

#### Task 2: Build a Custom EC2 Module

```
main.tf
---
resource "aws_instance" "aish_instance" {
    instance_type = var.instance_type
    associate_public_ip_address = true
    ami = var.ami_id
    subnet_id = var.subnet_id
    vpc_security_group_ids = var.security_group_ids
    tags = var.tags
}

variables.tf
---
variable "ami_id" {
    type = string
}

variable "instance_type" {
    type = string
    default = "t3.micro"
}

variable "subnet_id" {
    type = string
}

variable "security_group_ids" {
    type = list(string)
}
variable "instance_name" {
    type = string
}

variable "tags" {
    type = map(string)
    default = {}
}

output.tf
---
output "instance_id" {
    description = "ID of the ec2"
    value = aws_instance.aish_instance.id
}

output "public_ip" {
    description = "public ip of the ec2"
    value = aws_instance.aish_instance.public_ip
}

output "private_ip" {
    description = "private ip oif the ec2"
    value = aws_instance.aish_instance.private_ip
}

```
#### Task 3: Build a Custom Security Group Module

```
main.tf
---
resource "aws_security_group" "aish_security_group" {
    name = var.sg_name
    tags = var.tags
    vpc_id = var.vpc_id
    dynamic "ingress" {
        for_each = var.ingress_ports
        content {
            from_port = ingress.value
            to_port = ingress.value
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
    security_group_id = aws_security_group.aish_security_group.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"
}

variables.tf
---
variable "vpc_id" {
    type = string
}

variable "sg_name" {
    type = string
}

variable "ingress_ports" {
    type = list(number)
    default = [22, 80]
}

variable "tags" {
    type = map(string)
    default = {}
}

outputs.tf
---
output "sg_id" {
    description = "security group id"
    value = aws_security_group.aish_security_group.id
}

```

Outputs:
```
api\_server\_ip = "34.217.64.152"

web\_server\_ip = "44.255.121.171"

```
---------------------
Module directory structure

```
terraform-modules/

├── data.tf

├── locals.tf

├── main.tf

├── modules

│   ├── ec2-instance

│   │   ├── main.tf

│   │   ├── outputs.tf

│   │   └── variables.tf

│   └── security-group

│       ├── main.tf

│       ├── outputs.tf

│       └── variables.tf

├── outputs.tf

├── providers.tf

└── variables.tf

4 directories, 12 files

```

#### Task 6: Module Versioning and Best Practices

```

aishuser@aish-ubuntu-tws:\~/terraform-modules$ terraform state list

data.aws\_ami.amazon\_linux

module.api\_server.aws\_instance.aish\_instance

module.vpc.aws\_default\_network\_acl.this\[0]

module.vpc.aws\_default\_route\_table.default\[0]

module.vpc.aws\_default\_security\_group.this\[0]

module.vpc.aws\_internet\_gateway.this\[0]

module.vpc.aws\_route.public\_internet\_gateway\[0]

module.vpc.aws\_route\_table.private\[0]

module.vpc.aws\_route\_table.private\[1]

module.vpc.aws\_route\_table.public\[0]

module.vpc.aws\_route\_table\_association.private\[0]

module.vpc.aws\_route\_table\_association.private\[1]

module.vpc.aws\_route\_table\_association.public\[0]

module.vpc.aws\_route\_table\_association.public\[1]

module.vpc.aws\_subnet.private\[0]

module.vpc.aws\_subnet.private\[1]

module.vpc.aws\_subnet.public\[0]

module.vpc.aws\_subnet.public\[1]

module.vpc.aws\_vpc.this\[0]

module.web\_server.aws\_instance.aish\_instance

module.web\_sg.aws\_security\_group.aish\_security\_group

module.web\_sg.aws\_vpc\_security\_group\_egress\_rule.allow\_all\_traffic

```
###### Comparison: hand-written VPC vs registry VPC module (resources created)

**Custom VPC module -** only created the VPC, subnet and the route table with associations we mentioned in our configuration.

**Registry VPC -** created the VPC, with 4 subnets, 2 public and 2 private in different azs. It also created SG, network interface and network gateway. There are many resources mentioned in the registry module we just need to provide the required value while calling this module.

Example:

Add a Nat gateway with enable\_nat\_gateway = true

Add VPN gateway with  enable\_vpn\_gateway = true

So we do not need to write the whole config for all these resources, we just need to call the module and pass on the required values fort tjose resources.

###### Module best practices:

1. Have a readme.md file to mention what the module does.
2. Follow the module structure - main.tf, variables.tf, outputs.tf, so anyone can understand where to find which config.
3. keep it monolithic and focused and do nopt add multiple type of resources in one module.
4. Define all the required variables while module creation, if it is missing in module and only mentioned during calling the module, it might not take an effect.
5. Do not hardcode environment specific values. Use input variables and data sources effectively to make the module useful in multiple env.
                 

