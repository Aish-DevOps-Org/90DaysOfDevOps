#### Task 1: Project Setup



Providers.tf



```
terraform {
    required_providers {
        aws = {
            version = ">= 6.28"
            source = "hashicorp/aws"
        }
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = ">= 2.0"
        }
    }
}

provider "aws" {
    region = var.region
}
```

#### Task 2: Create the VPC with Registry Module



vpc.tf



```
module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    name = "terraweek-vpc"
    cidr = var.vpc_cidr

    azs             = ["us-west-2a", "us-west-2b"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    public_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]
  
    enable_nat_gateway = true
    single_nat_gateway = true
    enable_dns_hostnames = true
    public_subnet_tags = {
       "kubernetes.io/role/elb" = 1
        }

       private_subnet_tags = {
        "kubernetes.io/role/internal-elb" = 1
       }
    tags = {
      Terraform = "true"
      Environment = var.environment
      
    }
}
```



This module created 19 resources

1 VPC

2 public subnet

2 private subnet

4 route table associations to subnets

2 route table - private and public

1 int gateway

1 nat gateway

1 route from private RT to NAT

1 route from public RT to int gateway

1 default SG

1 aws eip

1 nacl

1 default route table



check [vpc_mod_plan.txt](https://github.com/Aish-DevOps-Org/90DaysOfDevOps/blob/master/2026/day-66/vpc_mod_plan.txt)

##### Why does EKS need both public and private subnets? What do the subnet tags do?

###### Subnet tags:

* If we use load balancing capability of EKS auto mode, then we need to tag the subnets.
* With the help of these tags, it identifies subnets as associated with cluster and which is private and which is public.
* Public subnet will have direct access to subnets thru Int gateway
* Private subnet will not have direct access to internet and will use NAT gateway for outbound traffic.



**Private subnets** are used for internal resources such as EKS nodes that don’t need public IPs. And do not need public exposure.

**Public subnets** are used for internet facing LBs, to route traffic from internet to our applications.



**Required tags-**

public_subnet_tags = {

"kubernetes.io/role/elb" = 1

}



private\_subnet\_tags = {

"kubernetes.io/role/internal-elb" = 1

}



#### Task 3: Create the EKS Cluster with Registry Module

Created eks.tf 

terraform plan failed multiple times -> check [errors_faced.md](https://github.com/Aish-DevOps-Org/90DaysOfDevOps/blob/master/2026/day-66/Errors_faced.md)

Finally it planned 53 resources.



```

aishuser@aish-ubuntu-tws:\~/terraform-eks$ cat plan.txt | grep "# module"

&#x20; # module.eks.data.tls\_certificate.this\[0] will be read during apply

&#x20; # module.eks.aws\_cloudwatch\_log\_group.this\[0] will be created

&#x20; # module.eks.aws\_ec2\_tag.cluster\_primary\_security\_group\["Environment"] will be created

&#x20; # module.eks.aws\_ec2\_tag.cluster\_primary\_security\_group\["ManagedBy"] will be created

&#x20; # module.eks.aws\_ec2\_tag.cluster\_primary\_security\_group\["Project"] will be created

&#x20; # module.eks.aws\_eks\_cluster.this\[0] will be created

&#x20; # module.eks.aws\_iam\_openid\_connect\_provider.oidc\_provider\[0] will be created

&#x20; # module.eks.aws\_iam\_policy.cluster\_encryption\[0] will be created

&#x20; # module.eks.aws\_iam\_role.this\[0] will be created

&#x20; # module.eks.aws\_iam\_role\_policy\_attachment.cluster\_encryption\[0] will be created

&#x20; # module.eks.aws\_iam\_role\_policy\_attachment.this\["AmazonEKSClusterPolicy"] will be created

&#x20; # module.eks.aws\_security\_group.cluster\[0] will be created

&#x20; # module.eks.aws\_security\_group.node\[0] will be created

&#x20; # module.eks.aws\_security\_group\_rule.cluster\["ingress\_nodes\_443"] will be created

&#x20; # module.eks.aws\_security\_group\_rule.node\["egress\_all"] will be created

&#x20; # module.eks.aws\_security\_group\_rule.node\["ingress\_cluster\_10251\_webhook"] will be created

&#x20; # module.eks.aws\_security\_group\_rule.node\["ingress\_cluster\_443"] will be created

&#x20; # module.eks.aws\_security\_group\_rule.node\["ingress\_cluster\_4443\_webhook"] will be created

&#x20; # module.eks.aws\_security\_group\_rule.node\["ingress\_cluster\_6443\_webhook"] will be created

&#x20; # module.eks.aws\_security\_group\_rule.node\["ingress\_cluster\_8443\_webhook"] will be created

&#x20; # module.eks.aws\_security\_group\_rule.node\["ingress\_cluster\_9443\_webhook"] will be created

&#x20; # module.eks.aws\_security\_group\_rule.node\["ingress\_cluster\_kubelet"] will be created

&#x20; # module.eks.aws\_security\_group\_rule.node\["ingress\_nodes\_ephemeral"] will be created

&#x20; # module.eks.aws\_security\_group\_rule.node\["ingress\_self\_coredns\_tcp"] will be created

&#x20; # module.eks.aws\_security\_group\_rule.node\["ingress\_self\_coredns\_udp"] will be created

&#x20; # module.eks.time\_sleep.this\[0] will be created

&#x20; # module.vpc.aws\_default\_network\_acl.this\[0] will be created

&#x20; # module.vpc.aws\_default\_route\_table.default\[0] will be created

&#x20; # module.vpc.aws\_default\_security\_group.this\[0] will be created

&#x20; # module.vpc.aws\_eip.nat\[0] will be created

&#x20; # module.vpc.aws\_internet\_gateway.this\[0] will be created

&#x20; # module.vpc.aws\_nat\_gateway.this\[0] will be created

&#x20; # module.vpc.aws\_route.private\_nat\_gateway\[0] will be created

&#x20; # module.vpc.aws\_route.public\_internet\_gateway\[0] will be created

&#x20; # module.vpc.aws\_route\_table.private\[0] will be created

&#x20; # module.vpc.aws\_route\_table.public\[0] will be created

&#x20; # module.vpc.aws\_route\_table\_association.private\[0] will be created

&#x20; # module.vpc.aws\_route\_table\_association.private\[1] will be created

&#x20; # module.vpc.aws\_route\_table\_association.public\[0] will be created

&#x20; # module.vpc.aws\_route\_table\_association.public\[1] will be created

&#x20; # module.vpc.aws\_subnet.private\[0] will be created

&#x20; # module.vpc.aws\_subnet.private\[1] will be created

&#x20; # module.vpc.aws\_subnet.public\[0] will be created

&#x20; # module.vpc.aws\_subnet.public\[1] will be created

&#x20; # module.vpc.aws\_vpc.this\[0] will be created

&#x20; # module.eks.module.eks\_managed\_node\_group\["terraweek\_nodes"].aws\_eks\_node\_group.this\[0] will be created

&#x20; # module.eks.module.eks\_managed\_node\_group\["terraweek\_nodes"].aws\_iam\_role.this\[0] will be created

&#x20; # module.eks.module.eks\_managed\_node\_group\["terraweek\_nodes"].aws\_iam\_role\_policy\_attachment.this\["AmazonEC2ContainerRegistryReadOnly"] will be created

&#x20; # module.eks.module.eks\_managed\_node\_group\["terraweek\_nodes"].aws\_iam\_role\_policy\_attachment.this\["AmazonEKSWorkerNodePolicy"] will be created

&#x20; # module.eks.module.eks\_managed\_node\_group\["terraweek\_nodes"].aws\_iam\_role\_policy\_attachment.this\["AmazonEKS\_CNI\_Policy"] will be created

&#x20; # module.eks.module.eks\_managed\_node\_group\["terraweek\_nodes"].aws\_launch\_template.this\[0] will be created

&#x20; # module.eks.module.kms.data.aws\_iam\_policy\_document.this\[0] will be read during apply

&#x20; # module.eks.module.kms.aws\_kms\_alias.this\["cluster"] will be created

&#x20; # module.eks.module.kms.aws\_kms\_key.this\[0] will be created

&#x20; # module.eks.module.eks\_managed\_node\_group\["terraweek\_nodes"].module.user\_data.null\_resource.validate\_cluster\_service\_cidr will be created

```



#### Task 4: Apply and Connect kubectl

Apply failed due to permission issues -

1. IAM role creation
2. EC2
3. Cloud watch logs creation
4. creating KMS Key - create key, tagging, alias etc -> provide full kms access
5. EKS access



Assign AmazonEKSClusterPolicy.





> The apply failed because the ec2 size was not available for free tier

```

╷

│ Error: waiting for EKS Node Group (terraweek-eks:terraweek\_nodes-2026040615350919700000000b) create: unexpected state 'CREATE\_FAILED', wanted target 'ACTIVE'. last error: eks-terraweek\_nodes-2026040615350919700000000b-6eceb1b7-7a61-bb9b-bc58-426288430c97: AsgInstanceLaunchFailures: Could not launch On-Demand Instances. InvalidParameterCombination - The specified instance type is not eligible for Free Tier. For a list of Free Tier instance types, run 'describe-instance-types' with the filter 'free-tier-eligible=true'. Launching EC2 instance failed.

│

│   with module.eks.module.eks\_managed\_node\_group\["terraweek\_nodes"].aws\_eks\_node\_group.this\[0],

│   on .terraform/modules/eks/modules/eks-managed-node-group/main.tf line 449, in resource "aws\_eks\_node\_group" "this": 

│  449: resource "aws\_eks\_node\_group" "this" {

│

```

In cluster -> health issues it is showing error -

```

AsgInstanceLaunchFailures: Could not launch On-Demand Instances. InvalidParameterCombination - The specified instance type is not eligible for Free Tier. For a list of Free Tier instance types, run 'describe-instance-types' with the filter 'free-tier-eligible=true'. Launching EC2 instance failed.

```



terraform state list

```

aishuser@aish-ubuntu-tws:\~/terraform-eks$  terraform state list

module.eks.data.aws\_caller\_identity.current\[0]

module.eks.data.aws\_iam\_policy\_document.assume\_role\_policy\[0]

module.eks.data.aws\_iam\_session\_context.current\[0]

module.eks.data.aws\_partition.current\[0]

module.eks.data.tls\_certificate.this\[0]

module.eks.aws\_cloudwatch\_log\_group.this\[0]

module.eks.aws\_ec2\_tag.cluster\_primary\_security\_group\["Environment"]

module.eks.aws\_ec2\_tag.cluster\_primary\_security\_group\["ManagedBy"]

module.eks.aws\_ec2\_tag.cluster\_primary\_security\_group\["Project"]

module.eks.aws\_eks\_cluster.this\[0]

module.eks.aws\_iam\_openid\_connect\_provider.oidc\_provider\[0]

module.eks.aws\_iam\_policy.cluster\_encryption\[0]

module.eks.aws\_iam\_role.this\[0]

module.eks.aws\_iam\_role\_policy\_attachment.cluster\_encryption\[0]

module.eks.aws\_iam\_role\_policy\_attachment.this\["AmazonEKSClusterPolicy"]

module.eks.aws\_security\_group.cluster\[0]

module.eks.aws\_security\_group.node\[0]

module.eks.aws\_security\_group\_rule.cluster\["ingress\_nodes\_443"]

module.eks.aws\_security\_group\_rule.node\["egress\_all"]

module.eks.aws\_security\_group\_rule.node\["ingress\_cluster\_10251\_webhook"]

module.eks.aws\_security\_group\_rule.node\["ingress\_cluster\_443"]

module.eks.aws\_security\_group\_rule.node\["ingress\_cluster\_4443\_webhook"]

module.eks.aws\_security\_group\_rule.node\["ingress\_cluster\_6443\_webhook"]

module.eks.aws\_security\_group\_rule.node\["ingress\_cluster\_8443\_webhook"]

module.eks.aws\_security\_group\_rule.node\["ingress\_cluster\_9443\_webhook"]

module.eks.aws\_security\_group\_rule.node\["ingress\_cluster\_kubelet"]

module.eks.aws\_security\_group\_rule.node\["ingress\_nodes\_ephemeral"]

module.eks.aws\_security\_group\_rule.node\["ingress\_self\_coredns\_tcp"]

module.eks.aws\_security\_group\_rule.node\["ingress\_self\_coredns\_udp"]

module.eks.time\_sleep.this\[0]

module.vpc.aws\_default\_network\_acl.this\[0]

module.vpc.aws\_default\_route\_table.default\[0]

module.vpc.aws\_default\_security\_group.this\[0]

module.vpc.aws\_eip.nat\[0]

module.vpc.aws\_internet\_gateway.this\[0]

module.vpc.aws\_nat\_gateway.this\[0]

module.vpc.aws\_route.private\_nat\_gateway\[0]

module.vpc.aws\_route.public\_internet\_gateway\[0]

module.vpc.aws\_route\_table.private\[0]

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

module.eks.module.eks\_managed\_node\_group\["terraweek\_nodes"].data.aws\_iam\_policy\_document.assume\_role\_policy\[0]

module.eks.module.eks\_managed\_node\_group\["terraweek\_nodes"].data.aws\_ssm\_parameter.ami\[0]

module.eks.module.eks\_managed\_node\_group\["terraweek\_nodes"].aws\_eks\_node\_group.this\[0]

module.eks.module.eks\_managed\_node\_group\["terraweek\_nodes"].aws\_iam\_role.this\[0]

module.eks.module.eks\_managed\_node\_group\["terraweek\_nodes"].aws\_iam\_role\_policy\_attachment.this\["AmazonEC2ContainerRegistryReadOnly"]

module.eks.module.eks\_managed\_node\_group\["terraweek\_nodes"].aws\_iam\_role\_policy\_attachment.this\["AmazonEKSWorkerNodePolicy"]

module.eks.module.eks\_managed\_node\_group\["terraweek\_nodes"].aws\_iam\_role\_policy\_attachment.this\["AmazonEKS\_CNI\_Policy"] 

module.eks.module.eks\_managed\_node\_group\["terraweek\_nodes"].aws\_launch\_template.this\[0]

module.eks.module.kms.data.aws\_caller\_identity.current\[0]

module.eks.module.kms.data.aws\_iam\_policy\_document.this\[0]

module.eks.module.kms.data.aws\_partition.current\[0]

module.eks.module.kms.aws\_kms\_alias.this\["cluster"]

module.eks.module.kms.aws\_kms\_key.this\[0]

module.eks.module.eks\_managed\_node\_group\["terraweek\_nodes"].module.user\_data.null\_resource.validate\_cluster\_service\_cidr

aishuser@aish-ubuntu-tws:\~/terraform-eks$

```

TO BE CONTINUED...
  


