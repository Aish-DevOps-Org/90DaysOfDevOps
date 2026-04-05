#### Task 1: Understand Module Structure

###### What is the difference between a "root module" and a "child module"?

**Root module:** dir where terraform starts evaluating the infrastructure. Where we run TF commands.

**Child module:** Any module that is called from another module, usually root module.

Child modules can themselves call other modules — forming a module tree.

**ex.** Root Module

&#x20;	└── calls ──> Child Module (vpc)

&#x20;                   	  └── calls ──> Child Module (subnets)

#### Task 2: Build a Custom EC2 Module

```

main.tf

\---

resource "aws\_instance" "aish\_instance" {

&#x20;   instance\_type = var.instance\_type

&#x20;   associate\_public\_ip\_address = true

&#x20;   ami = var.ami\_id

&#x20;   subnet\_id = var.subnet\_id

&#x20;   vpc\_security\_group\_ids = var.security\_group\_ids

&#x20;   tags = var.tags

}



variables.tf

\---

variable "ami\_id" {

&#x20;   type = "string"

}



variable "instance\_type" {

&#x20;   type = "string"

&#x20;   default = "t3.micro"

}



variable "subnet\_id" {

&#x20;   type = "string"

}



variable "security\_group\_ids" {

&#x20;   type = "list(string)"

}

variable "instance\_name" {

&#x20;   type = "string"

}



variable "tags" {

&#x20;   type = "map(string)"

&#x20;   default = {}

}



output.tf

\---

output "instance\_id" {

&#x20;   description = "ID of the e2"

&#x20;   value = aws\_instance.aish\_instance.id

}



output "public\_ip" {

&#x20;   description = "public ip of the ec2"

&#x20;   value = aws\_instance.aish\_instance.public\_ip

}



output "private\_ip" {

&#x20;   description = "private ip oif the ec2"

&#x20;   value = aws\_instance.aish\_instance.private\_ip

}

```



#### Task 3: Build a Custom Security Group Module

```

main.tf

\---

resource "aws\_security\_group" "aish\_security\_group" {

&#x20;   name = var.sg\_name

&#x20;   tags = var.tags

&#x20;   vpc\_id = var.vpc\_id

&#x20;   dynamic "ingress" {

&#x20;       for\_each = var.ingress\_ports

&#x20;       content {

&#x20;           from\_port = ingress.value

&#x20;           to\_port = ingress.value

&#x20;           protocol = "tcp"

&#x20;           cidr\_blocks = \["0.0.0.0/0"]

&#x20;       }

&#x20;   }

}



resource "aws\_vpc\_security\_group\_egress\_rule" "allow\_all\_traffic" {

&#x20;   security\_group\_id = aws\_security\_group.aish\_security\_group.id

&#x20;   cidr\_ipv4 = "0.0.0.0/0"

&#x20;   ip\_protocol = "-1"

}



variables.tf

\---

variable "vpc\_id" {

&#x20;   type = "string"

}



variable "sg\_name" {

&#x20;   type = "string"

}



variable "ingress\_ports" {

&#x20;   type = "list(numbers)"

&#x20;   default = \[22, 80]

}





variable "tags" {

&#x20;   type = "map(strings)"

&#x20;   default = {}

}



outputs.tf

\---

output "sg\_id" {

&#x20;   description = "security group id"

&#x20;   value = aws\_security\_group.aish\_security\_group.id

}



#### Task 4: Call Your Modules from Root

Uploaded all the files in the repo.   

terraform plan and apply created 6 resources.



#### Task 5: Use a Public Registry Module

this creates 21 resources now

```

Outputs:



api\_server\_ip = "34.217.64.152"

web\_server\_ip = "44.255.121.171"

```

\---------------------



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



&#x20;                  

