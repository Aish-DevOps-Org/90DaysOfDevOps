Error 1
Terraform init fails with
```
│ Error: Failed to query available provider packages
│
│ Could not retrieve the list of available versions for provider
│ hashicorp/aws: no available releases match the given constraints >=    
│ 4.33.0, ~> 5.0, >= 5.95.0, < 6.0.0, >= 6.28.0
│
│ To see which modules are currently depending on hashicorp/aws and what 
│ versions are specified, run the following command:
│     terraform providers
```

Cause: 
this is happening because, the VPC module is forcing - aws >= 6.28
And we are using aws version ~> 5.0 which is < 6.0
Also the EKS module (v20.0) does not support v6 version. So it is asking for < 6.0.0

here we can see conflicts in version
```
aishuser@aish-ubuntu-tws:~/terraform-eks$ terraform providers

Providers required by configuration:
.
├── provider[registry.terraform.io/hashicorp/kubernetes] >= 2.0.0        
├── provider[registry.terraform.io/hashicorp/aws] >= 6.28.0
├── module.eks
│   ├── provider[registry.terraform.io/hashicorp/tls] >= 3.0.0
│   ├── provider[registry.terraform.io/hashicorp/time] >= 0.9.0
│   ├── provider[registry.terraform.io/hashicorp/aws] >= 5.95.0, < 6.0.0 
│   ├── module.self_managed_node_group
│   │   ├── provider[registry.terraform.io/hashicorp/aws] >= 5.95.0, < 6.0.0
│   │   └── module.user_data
│   │       ├── provider[registry.terraform.io/hashicorp/cloudinit] >= 2.0.0
│   │       └── provider[registry.terraform.io/hashicorp/null] >= 3.0.0  
│   ├── module.eks_managed_node_group
│   │   ├── provider[registry.terraform.io/hashicorp/aws] >= 5.95.0, < 6.0.0
│   │   └── module.user_data
│   │       ├── provider[registry.terraform.io/hashicorp/cloudinit] >= 2.0.0
│   │       └── provider[registry.terraform.io/hashicorp/null] >= 3.0.0  
│   ├── module.fargate_profile
│   │   └── provider[registry.terraform.io/hashicorp/aws] >= 5.95.0, < 6.0.0
│   └── module.kms
│       └── provider[registry.terraform.io/hashicorp/aws] >= 4.33.0      
└── module.vpc
    └── provider[registry.terraform.io/hashicorp/aws] >= 6.28.0
```

Fix: 
provider aws version set to ~> 6.0
For EKS module, we have to use 21.0 which support v6 version of aws provider

And now the init is successful.

Error 2
```
Error: Unsupported argument
│
│   on eks.tf line 5, in module "eks":
│    5:   cluster_name    = var.cluster_name
│
│ An argument named "cluster_name" is not expected here.
╵
╷
│ Error: Unsupported argument
│
│   on eks.tf line 6, in module "eks":
│    6:   cluster_version = var.cluster_version
│
│ An argument named "cluster_version" is not expected here.
╵
╷
│ Error: Unsupported argument
│
│   on eks.tf line 11, in module "eks":
│   11:   cluster_endpoint_public_access = true
│
│ An argument named "cluster_endpoint_public_access" is not expected     
│ here.
```

Cause:
we changed the EKS module version so the keys also needs to be updated as per v21.0.

Fix:
```
name    = var.cluster_name
kubernetes_version = var.cluster_version
endpoint_public_access = true
```

Error 3
During terraform plan-
```
 Error: reading SSM Parameter (/aws/service/eks/optimized-ami/1.31/amazon-linux-2023/x86_64/standard/recommended/release_version): operation error SSM: GetParameter, https response error StatusCode: 400, RequestID: 3afe9c2b-0b15-49b4-98f1-83acfbb7d603, api error AccessDeniedException: User: arn:aws:iam::580982410752:user/tf_user is not authorized to perform: ssm:GetParameter on resource: arn:aws:ssm:us-west-2::parameter/aws/service/eks/optimized-ami/1.31/amazon-linux-2023/x86_64/standard/recommended/release_version because no identity-based policy allows the ssm:GetParameter action     
│
│   with module.eks.module.eks_managed_node_group["terraweek_nodes"].data.aws_ssm_parameter.ami[0],
│   on .terraform/modules/eks/modules/eks-managed-node-group/main.tf line 431, in data "aws_ssm_parameter" "ami":
│  431: data "aws_ssm_parameter" "ami" {
```

Cause:
The IAM identity we used is missing SSM-get parameters permission.

/aws/service/eks/optimized-ami/1.31/amazon-linux-2023/x86_64/standard/recommended/release_version -> This is a public SSM Parameter that AWS provides for:
Latest EKS optimized AMI
Used automatically by terraform-aws-modules/eks

Fix
Attached policy to the IAM identity -> AmazonSSMReadOnlyAccess
