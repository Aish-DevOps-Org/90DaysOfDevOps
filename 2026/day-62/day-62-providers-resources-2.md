#### Task 4: Add a Security Group and EC2 Instance

```
# Create security group inside the VPC
resource "aws_security_group" "aish_security_group" {
  name        = "tf_sg"
  description = "allow TLS inbound and outbound traffic"
  vpc_id      = aws_vpc.aish_vpc.id
  tags = {
    Name = "TerraWeek-SG"
  }
}

# Create ingress rule
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.aish_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Create ingress rule
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.aish_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
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
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.aish_security_group.id]

  associate_public_ip_address = true
  key_name                    = aws_key_pair.aish_key.key_name
  tags = {
    name = "TerraWeek-server"
  }
}

```
###### Got **error** in apply

```
aws\_instance.aish\_instance: Creating...

╷

│ Error: creating EC2 Instance: operation error EC2: RunInstances, https response error StatusCode: 400, RequestID: 892bcfa3-1eee-49d5-98bd-ce1d68c2edea, api error InvalidParameter: Security group sg-0ca7228778333eaf4 and subnet subnet-04367bdaaa2a75a91 belong to different networks.

│

│   with aws\_instance.aish\_instance,

│   on main.tf line 89, in resource "aws\_instance" "aish\_instance":

│   89: resource "aws\_instance" "aish\_instance" {

```
**Cause:** It is picking a subnet ID from different VPC

**Resolution**: i mentioned subnet id as well using interpolation, which was missing.

\-> Instance is created with public IP and i am able to SSH to it

```
aishuser@aish-ubuntu-tws:~/terraform-aws-infra$ ssh -i ../.ssh/id_ed25519 ec2-user@44.248.252.245
The authenticity of host '44.248.252.245 (44.248.252.245)' can't be established.
ED25519 key fingerprint is SHA256:zz9iZg4/Fw6Akdx9T3zKngPanXoiCILSmpAjxZRAEYc.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '44.248.252.245' (ED25519) to the list of known hosts.
   ,     #_
   ~\_  ####_        Amazon Linux 2023
  ~~  \_#####\
  ~~     \###|
  ~~       \#/ ___   https://aws.amazon.com/linux/amazon-linux-2023
   ~~       V~' '->
    ~~~         /
      ~~._.   _/
         _/ _/
       _/m/'
[ec2-user@ip-10-0-1-70 ~]$
```

#### Task 5: Explicit Dependencies with depends\_on

Add S3 bucket

```
# create S3 bucket
resource "aws_s3_bucket" "aish_bucket" {
  bucket     = "tf_bucket"
  depends_on = [aws_instance.aish_instance]
}
```
terraform graph

```
result uploaded as - [day-62/terraform-graph.png](https://github.com/Aish-DevOps-Org/90DaysOfDevOps/blob/master/2026/day-62/terraform-graph.png)
```

###### \-> When would you use depends\_on in real projects? Give two examples.

You only need to explicitly specify a dependency when a resource or module relies on another resource's behavior but does not access any of that resource's data in its arguments.

Like assigning a IAM policy to a resource like EC2 or AWS lambda before it performs certain action.

#### Task 6: Lifecycle Rules and Destroy

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:

&#x20; + create

+/- **create replacement and then destroy**

Terraform will perform the following actions:

&#x20; # aws\_instance.aish\_instance must be replaced

+/- resource "aws\_instance" "aish\_instance"

\-> observe destroy order is reverse

```

Plan: 0 to add, 0 to change, 11 to destroy.

aws\_instance.aish\_instance: Destroying... \[id=i-0c307beb76c3fc351]

aws\_vpc\_security\_group\_ingress\_rule.allow\_ssh: Destroying... \[id=sgr-0451ab74abeee041a]

aws\_route\_table\_association.aish\_route\_table\_association: Destroying... \[id=rtbassoc-094ab07d4f1ef040f]

aws\_vpc\_security\_group\_ingress\_rule.allow\_http: Destroying... \[id=sgr-0cfce8d358b824603]

aws\_vpc\_security\_group\_egress\_rule.allow\_all\_traffic: Destroying... \[id=sgr-0c2bfe58952737b01]

aws\_vpc\_security\_group\_ingress\_rule.allow\_http: Destruction complete after 0s

aws\_vpc\_security\_group\_ingress\_rule.allow\_ssh: Destruction complete after 0s

aws\_route\_table\_association.aish\_route\_table\_association: Destruction complete after 0s

aws\_route\_table.aish\_route\_table: Destroying... \[id=rtb-09cca8299fee25e9a]

aws\_vpc\_security\_group\_egress\_rule.allow\_all\_traffic: Destruction complete after 0s

aws\_route\_table.aish\_route\_table: Destruction complete after 1s

aws\_internet\_gateway.aish\_int\_gateway: Destroying... \[id=igw-08b74fd5dd128a3a4]

aws\_instance.aish\_instance: Still destroying... \[id=i-0c307beb76c3fc351, 00m10s elapsed]

aws\_internet\_gateway.aish\_int\_gateway: Still destroying... \[id=igw-08b74fd5dd128a3a4, 00m10s elapsed]

aws\_internet\_gateway.aish\_int\_gateway: Destruction complete after 17s

aws\_instance.aish\_instance: Still destroying... \[id=i-0c307beb76c3fc351, 00m20s elapsed]

aws\_instance.aish\_instance: Still destroying... \[id=i-0c307beb76c3fc351, 00m30s elapsed]

aws\_instance.aish\_instance: Destruction complete after 30s

aws\_subnet.aish\_subnet: Destroying... \[id=subnet-023188f0c2151a2b3]

aws\_security\_group.aish\_security\_group: Destroying... \[id=sg-0ca7228778333eaf4]

aws\_key\_pair.aish\_key: Destroying... \[id=tf\_ec2\_key]

aws\_key\_pair.aish\_key: Destruction complete after 1s

aws\_security\_group.aish\_security\_group: Destruction complete after 1s

aws\_subnet.aish\_subnet: Destruction complete after 1s

aws\_vpc.aish\_vpc: Destroying... \[id=vpc-072b04f6d4812d415]

aws\_vpc.aish\_vpc: Destruction complete after 1s

```

VPC was deleted in the end.

\-> What are the three lifecycle arguments (create\_before\_destroy, prevent\_destroy, ignore\_changes) and when would you use each?

create\_before\_destroy -> Terraform normally destroys the old one first, then creates the new one. Setting create\_before\_destroy = true ensures the new resource is created and provisioned before the old one is destroyed. It ensures, continuous availability of that resource.

prevent\_destroy -> Avoid accidental deletion

ignore\_changes -> once a resource is created, and we want to avoid changes to its attributes by external sources, automation etc. then this list or all, will prevent any changes in that resource.

