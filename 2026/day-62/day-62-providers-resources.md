#### Task 1: Explore the AWS Provider



1. Create a new project directory: terraform-aws-infra
2. Write a providers.tf file:

   * Define the terraform block with required\_providers pinning the AWS provider to version \~> 5.0
   * Define the provider "aws" block with your region

```
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = "us-west-2"
}
```

3\. Run terraform init and check the output -- what version was installed? -> **5.100.0**

```

aishuser@aish-ubuntu-tws:\~/terraform-aws-infra$ terraform init

Initializing the backend...

Initializing provider plugins...

**- Finding hashicorp/aws versions matching "\~> 5.0"...**

**- Installing hashicorp/aws v5.100.0...**

**- Installed hashicorp/aws v5.100.0 (signed by HashiCorp)**

Terraform has created a lock file .terraform.lock.hcl to record the provider

selections it made above. Include this file in your version control repository

so that Terraform can guarantee to make the same selections by default when

you run "terraform init" in the future.



Terraform has been successfully initialized!

```

4\. Read the provider lock file .terraform.lock.hcl -- what does it do? -> a dependency lock file used by Terraform to record the **exact versions and cryptographic hashes of the provider plugins** used in a project. This is maintained automatically by terraform with every init execution.



\-> The init created a **.terraform** directory and a **.terraform.lock.hcl** file

```
-> **.terraform.lock.hcl**

provider "registry.terraform.io/hashicorp/aws" {
  version     = "5.100.0"
  constraints = "~> 5.0"
  hashes = []}

-> .terraform directory
.terraform
└── providers
    └── registry.terraform.io
        └── hashicorp
            └── aws
                └── 5.100.0
                    └── linux_amd64
                        ├── LICENSE.txt
                        └── terraform-provider-aws_v5.100.0_x5

```



5\. Document: What does \~> 5.0 mean? How is it different from >= 5.0 and = 5.0.0?

\~> is a pessimistic constraint operator

\~> 5.0 **->** allows any version **equal or higher than 5.0.0 but less than 6.0.0**. Includes **minor** and **patch** updates in 5.0.0. This is a **lock to a major** version.

>= 5.0 -> Does not allow patch updates only **minor and major updates, equal and above 5.0. Ex.** 5.0, 5.5, 6.0, 7.0

= 5.0.0 -> Only 5.0.0 version

\---

#### Task 2: Build a VPC from Scratch

1. Create a main.tf
```
# create VPC - CIDR block 10.0.0.0/16, tag it "TerraWeek-VPC"
resource "aws_vpc" "aish_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "TerraWeek-VPC"
  }
}

# Create subnet - CIDR block 10.0.1.0/24, reference the VPC ID from step 1, enable public IP on launch, tag it "TerraWeek-Public-Subnet"
resource "aws_subnet" "aish_subnet" {
  cidr_block              = "10.0.1.0/24"
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
```
2\. Terraform plan

```
Plan: 5 to add, 0 to change, 0 to destroy.
```
3\. Apply and check the AWS VPC console. Can you see all five resources connected?
Yes, all 5 resources are connected.
\---

#### Task 3: Understand Implicit Dependencies
**Implicit dependency:** 

* helps terraform build a dependency graph and determine the correct order in which to create, update or destroy resources without manual intervention. 
* It infers these dependencies through interpolation expressions eg. vpc\_id = aws\_vpc.aish\_vpc.id.
* The resource being referenced (the dependency) is guaranteed to be created or modified before the resource that references it.

**Question**:

1. How does Terraform know to create the VPC before the subnet?
Because in subnet we used interpolation expression and referenced the vpc id which created implicit dependency. So, VPC will be created before subnet.
2. What would happen if you tried to create the subnet before the VPC existed?
If a implicit dependency is mentioned that, terraform will not create subnet before VPC.
If dependency is not mentioned, then subnet creation will fail as during subnet creation, it will look for vpc id which might not be available as the VPC is not created yet.

3. Find all implicit dependencies in your config and list them-

&#x09;Subnet -> VPC

&#x09;Internet gateway -> VPC

&#x09;Route table -> VPC

&#x09;Route table -> gateway

&#x09;route table association -> Subnet

&#x09;route table association -> route table





