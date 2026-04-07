# Day 67 -- TerraWeek Capstone: Multi-Environment Infrastructure with Workspaces and Modules

## Workspaces

**Reuse code:** Workspaces let you use the same code for multiple environments by switching the “workspace context.” In other words, Terraform separates your state file based on the active workspace (default, dev, prod, etc.).

**Separate state file:** Terraform stores different terraform.tfstate files within the same folder, based on the selected workspace.

### Task 1: Learn Terraform Workspaces

```bash
aishuser@aish-ubuntu-tws:~/terraweek-capstone$ terraform workspace show
default

aishuser@aish-ubuntu-tws:~/terraweek-capstone$ terraform workspace new dev
Created and switched to workspace "dev"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.

aishuser@aish-ubuntu-tws:~/terraweek-capstone$ terraform workspace list
  default
  dev
* prod
  staging

aishuser@aish-ubuntu-tws:~/terraweek-capstone$ terraform workspace select dev
Switched to workspace "dev".

---
aishuser@aish-ubuntu-tws:~/terraweek-capstone$ tree .terraform/
.terraform/
└── environment

1 directory, 1 file
aishuser@aish-ubuntu-tws:~/terraweek-capstone$ tree terraform.tfstate.d/
terraform.tfstate.d/
├── dev
├── prod
└── staging

4 directories, 0 files
```

#### What does **terraform.workspace** return inside a config?

  Returns the name of the currently selected workspace as a string.

#### Where does each workspace store its state file?

Local backend: when we create the workspace, terraform creates a directory for that workspace and stores the state file of that workspace in respective directory.
Path: terraform.tfstate.d/<WORKSPACE_NAME>/terraform.tfstate

Remote backend: the workspace name gets incorporated into the state file path
Example-
Multiple workspaces:
  backend-path/terraform.tfstate          (default)
  backend-path/env:/dev/terraform.tfstate  (dev)
  backend-path/env:/prod/terraform.tfstate (prod)

#### How is this different from using separate directories per environment?

**Workspace:**

- In workspaces the codebase is shared and the state files are separate for each workspace.
- Differences come from the terraform.workspace variable and workspace-specific tfvars.
- All workspaces share the same backend config, differentiated by key prefix.
- If all the environment are idetical with very less difference like sizing and counts then workspace is useful.
- Else, it can become very complex with all the conditionals.
- By mistake, if the commands are run in different environment than it can be a disaster.

**Environment Dir structure:**

- In dir structure, each env has it's own directory with its own tf config.
- Each env dir needs to call the shared module.
- Each env can have separate backend configured.
- In env dir structure, the intial config is duplication of work but maintenance is scalable and better.
- Changes to shared modules needs to be applied in each env separately.
- But when you have different resource sets in each env and different team needs to mainatin them, strict access control and infra is complex then this is a better choice.

### Task 2: Set Up the Project Structure

Layout is created and pushed. Check terraweek-capstone directory.

```bash
terraweek-capstone/
├── dev.tfvars
├── locals.tf
├── main.tf
├── modules
│   ├── ec2-instance
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── security-group
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── vpc
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── outputs.tf
├── prod.tfvars
├── providers.tf
├── staging.tfvars
├── terraform.tfstate.d
│   ├── dev
│   ├── prod
│   └── staging
└── variables.tf

9 directories, 17 files
```

#### Why is this file structure considered best practice?

The file sructure uses root modules and child modules, .tfvars files for different environments, and a variable.tf file for root variables, separate files for providers, outputs, locals, and the main.tf file for calling child module.
This makes the project and configuration easy to understand and less complex. Reusability becomes easier.

### Task 3: Build the Custom Modules

Check custom modules under terraweek-capstone/modules

```bash
aishuser@aish-ubuntu-tws:~/terraweek-capstone$ terraform validate
Success! The configuration is valid.
```

### Task 4: Wire It All Together with Workspace-Aware Config

Check custom modules under terraweek-capstone.

### Task 5: Deploy All Three Environments

```bash
terraform apply -var-file="dev.tfvars" -auto-approve
ec2_instance_id = "i-027c757b45783c5bb"
public_subnet_id = "subnet-0b07a6e1e1b837468"
sg_id = "sg-03fcdb021c77b3730"
vpc_id = "vpc-05a21b0d733e58571"
```
And I can ssh into this ec2 insatnce

```bash
aishuser@aish-ubuntu-tws:~$ ssh -i .ssh/id_ed25519  ec2-user@35.93.115.185
The authenticity of host '35.93.115.185 (35.93.115.185)' can't be established.
ED25519 key fingerprint is SHA256:tM8JdqfcmpwQ8aItOfyjf1prO3livTsQZiE6+yWwKcg.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '35.93.115.185' (ED25519) to the list of known hosts.
   ,     #_
   ~\_  ####_        Amazon Linux 2
  ~~  \_#####\
  ~~     \###|       AL2 End of Life is 2026-06-30.
  ~~       \#/ ___
   ~~       V~' '->
    ~~~         /    A newer version of Amazon Linux is available!
      ~~._.   _/
         _/ _/       Amazon Linux 2023, GA and supported until 2028-03-15.
       _/m/'           https://aws.amazon.com/linux/amazon-linux-2023/

[ec2-user@ip-10-0-1-191 ~]$ 
```

Similarly for prod

```bash
Apply complete! Resources: 9 added, 0 changed, 0 destroyed.

Outputs:

ec2_instance_id = "i-0b189f9de3145f5ea"
public_subnet_id = "subnet-035bee19d8f1fbf0e"
sg_id = "sg-00ca6f1b8218f5430"
vpc_id = "vpc-0d9bbfa68f4b03e5b"
```

### Task 6: Document Best Practices

#### Everything we have learned this week as a Terraform best practices guide

1. File structure -- separate files for providers, variables, outputs, main, locals
2. State management -- always use remote backend, enable locking, enable versioning
3. Variables -- never hardcode, use tfvars per environment, validate with validation blocks
4. Modules -- one concern per module, always define inputs/outputs, pin registry module versions
5. Workspaces -- use for environment isolation, reference terraform.workspace in configs
6. Security -- .gitignore for state and tfvars, encrypt state at rest, restrict backend access
7. Commands -- always run plan before apply, use fmt and validate before committing
8. Tagging -- tag every resource with project, environment, and managed-by
9. Naming -- consistent prefix pattern: 

```text
<project>-<environment>-<resource>
```

10. Cleanup -- always terraform destroy non-production environments when not in use.

### Task 7: Destroy All Environments

```bash
aishuser@aish-ubuntu-tws:~/terraweek-capstone$ tree terraform.tfstate.d/
terraform.tfstate.d/

0 directories, 0 files
```

#### Table mapping each TerraWeek day to the concepts learned

| Day | Concepts |
|-----|----------|
| 61 | IaC, HCL, init/plan/apply/destroy, state basics |
| 62 | Providers, resources, dependencies, lifecycle |
| 63 | Variables, outputs, data sources, locals, functions |
| 64 | Remote backend, locking, import, drift |
| 65 | Custom modules, registry modules, versioning |
| 66 | EKS with modules, real-world provisioning |
| 67 | Workspaces, multi-env, capstone project |
