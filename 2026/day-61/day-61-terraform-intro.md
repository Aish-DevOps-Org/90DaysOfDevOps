#### Task 1: Understand Infrastructure as Code

1. What is Infrastructure as Code (IaC)? Why does it matter in DevOps?

**IaaC** - helps us create, manage and destroy complex infrastructure automatically with few commands. Removes human errors and dependency, repetitive tasks and reduces expense.
For DevOps it is very important when it comes to create and manage complex infrastructure in daily basis. With Iaac, we can create the infrastructure in declarative code and use the same code in different environments. No need to click on the UI again and again for same task.

2. What problems does IaC solve compared to manually creating resources in the AWS console?

It helps us write infrastructure in declarative manner in the code, we just need to mention the state we desire and with one command it will be up and running. Once the code is ready, we do not need to click on the UI and do repetitive tasks for creating same resource again.

3. How is Terraform different from AWS CloudFormation, Ansible, and Pulumi?

**AWS cloudFormation:** is also IaC but it is only for AWS resource. Terraform can be integrated and has plugins for many different cloud providers.
**Ansible:** is configuration management tool and not infrastructure creation. Once we have the infrastructure then it helps with managing it for ex. installing a software is 20 VMs.
**Pulumi**:This is also Iac but mostly for operations team than developer. Pulumi uses familiar, general-purpose programming languages (like Python, TypeScript, Go, etc.) for infrastructure as code (IaC), while Terraform uses its own domain-specific language (DSL), HCL (HashiCorp Configuration Language).
**Terraform**: IaC, widely used, works on HCL. It is stateful, where we declare the desired state and it compares it with existing infra state and spins up or down the resource to meet the desired state.

4. What does it mean that Terraform is "declarative" and "cloud-agnostic"?

&#x20;  **Declarative**: We do not write step by step process of creating the resources, instead we just mention what needs to be created and then terraform uses the provider plugins and smart enough to create those resources in the required sequence and achieve the desired state mentioned in the .tf files.

&#x20;**Cloud-agnostic:** It supports multiple cloud providers, avoiding reliance on any single vendor's proprietary tools. Which is one of the reason of it being widely used.



#### Task 2: Install Terraform and Configure AWS

1. Install Terraform:

```

\# Linux (amd64)

wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb \[signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb\_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update \&\& sudo apt install terraform

```



2\. Verify

```

Terraform v1.14.8

on linux\_amd64

```



3\. Install and configure the AWS CLI:

```

aws configure

done

```



4\. Verify AWS access

```

aws sts get-caller-identity

{

&#x20;   "UserId": "AID\*\*\*\*\*2VGD",

&#x20;   "Account": "580\*\*\*52",

&#x20;   "Arn": "arn:aws:iam::580\*\*\*\*\*\*52:user/tf\_user"

}



```



#### Task 3: Your First Terraform Config -- Create an S3 Bucket



1. create main.tf with provider "aws" and resource "aws\_s3\_bucket"

```

provider "aws" {

&#x20; region = "us-west-2"

}



resource "aws\_s3\_bucket" "tf\_s3" {

&#x20; bucket = "aish-tf-s3-bucket"



}

```

2\. Initialize terraform

```

erraform init

Initializing the backend...

Initializing provider plugins...

\- Finding latest version of hashicorp/aws...

\- Installing hashicorp/aws v6.38.0...

\- Installed hashicorp/aws v6.38.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider

selections it made above. Include this file in your version control repository

so that Terraform can guarantee to make the same selections by default when

you run "terraform init" in the future.



Terraform has been successfully initialized!

```



3\. .terraform directory

```

aishuser@aish-ubuntu-tws:\~/terraform$ tree .terraform

.terraform

└── providers

&#x20;   └── registry.terraform.io

&#x20;       └── hashicorp

&#x20;           └── aws

&#x20;               └── 6.38.0

&#x20;                   └── linux\_amd64

&#x20;                       ├── LICENSE.txt

&#x20;                       └── terraform-provider-aws\_v6.38.0\_x5

```



4\. Terraform plan

```

Terraform will perform the following actions:



&#x20; # aws\_s3\_bucket.tf\_s3 will be created

&#x20; + resource "aws\_s3\_bucket" "tf\_s3"



Plan: 1 to add, 0 to change, 0 to destroy.



```

5\. terraform apply

```

aws\_s3\_bucket.tf\_s3: Creating...

aws\_s3\_bucket.tf\_s3: Creation complete after 1s \[id=aish-tf-s3-bucket]



Created..

```





#### Task 4: Add an EC2 Instance

1. Add aws\_instance with below ami and instance type for my region -

ubuntu ami -> ami-0d76b909de1a0595d

t3.micro

us-west-2

```

provider "aws" {

&#x20; region = "us-west-2"

}



resource "aws\_s3\_bucket" "tf\_s3" {

&#x20; bucket = "aish-tf-s3-bucket"



}



resource "aws\_instance" "tf\_ec2" {

&#x20; ami          = "ami-0d76b909de1a0595d"

&#x20; instance\_type = "t3.micro"

&#x20; tags = {

&#x20;   name = "TerraWeek-Day1"

&#x20; }



}

```



2\. Current terraform state

```

aishuser@aish-ubuntu-tws:\~/terraform$ terraform state list

aws\_s3\_bucket.tf\_s3

```



3\. terraform plan and apply

```

aws\_s3\_bucket.tf\_s3: Refreshing state... \[id=aish-tf-s3-bucket]



Terraform used the selected providers to generate the following execution plan.

Resource actions are indicated with the following symbols:

&#x20; + create



Terraform will perform the following actions:



&#x20; # aws\_instance.tf\_ec2 will be created

&#x20; + resource "aws\_instance" "tf\_ec2"



Plan: 1 to add, 0 to change, 0 to destroy.

aws\_instance.tf\_ec2: Creating...

aws\_instance.tf\_ec2: Still creating... \[00m10s elapsed]

aws\_instance.tf\_ec2: Creation complete after 13s \[id=i-0df8e7faa542367f3]



Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

```



4.Final state

``` 

aishuser@aish-ubuntu-tws:\~/terraform$ terraform state list

aws\_instance.tf\_ec2

aws\_s3\_bucket.tf\_s3

```

#### Task 5: Understand the State File

1. The terraform state show command gives the details of the current resource created.

2\. What information does the state file store about each resource?

3\. Why should you never manually edit the state file?

\-> It will cause inconsistency between infrastructure and configuration, and will break the state management.



4\. Why should the state file not be committed to Git?

\-> it can have sensitive information.

\-> Git has no state locking system

\-> it will cause stale state and inconsistency in state as git wont be able to update it the way terraform does if it is stored in local or remote backends.



#### Task 6: Modify, Plan, and Destroy

1. What do the \~, +, and - symbols mean?
 **\~** -> means it will only update the resource
 **+** -> resource will be added
 **-** -> Resource will be deleted
2. Is this an in-place update or a destroy-and-recreate?

\-> Updating tag in EC2 instance is and in-place upgrade, it only modifies the existing resource and does not delete and recreate it.

3\. terraform destroy -> Successfully deleted both the resources.



```

aishuser@aish-ubuntu-tws:\~/terraform$ terraform destroy

aws\_s3\_bucket.tf\_s3: Refreshing state... \[id=aish-tf-s3-bucket]

aws\_instance.tf\_ec2: Refreshing state... \[id=i-0df8e7faa542367f3]



Terraform used the selected providers to generate the following execution plan.

Resource actions are indicated with the following symbols:

&#x20; - destroy



Terraform will perform the following actions:



&#x20; # aws\_instance.tf\_ec2 will be destroyed

&#x20; - resource "aws\_instance" "tf\_ec2"



\---

\# aws\_s3\_bucket.tf\_s3 will be destroyed

&#x20; - resource "aws\_s3\_bucket" "tf\_s3"

\---

Plan: 0 to add, 0 to change, 2 to destroy.



Do you really want to destroy all resources?

&#x20; Terraform will destroy all your managed infrastructure, as shown above.

&#x20; There is no undo. Only 'yes' will be accepted to confirm.



&#x20; Enter a value: yes



aws\_s3\_bucket.tf\_s3: Destroying... \[id=aish-tf-s3-bucket]

aws\_instance.tf\_ec2: Destroying... \[id=i-0df8e7faa542367f3]

aws\_s3\_bucket.tf\_s3: Destruction complete after 0s

aws\_instance.tf\_ec2: Still destroying... \[id=i-0df8e7faa542367f3, 00m10s elapsed]

aws\_instance.tf\_ec2: Destruction complete after 19s



Destroy complete! Resources: 2 destroyed.

```

