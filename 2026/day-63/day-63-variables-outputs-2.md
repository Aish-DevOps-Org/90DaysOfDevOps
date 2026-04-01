#### Task 4: Use Data Sources



```

data "aws\_ami" "amazon\_linux" {

&#x20; most\_recent = true

&#x20; owners      = \["amazon"]



&#x20; filter {

&#x20;   name   = "name"

&#x20;   values = \["amzn2-ami-hvm-\*-x86\_64-gp2"]

&#x20; }

}



data "aws\_availability\_zones" "available" {

&#x20; state = "available"



}

```



Changed the region and plan, it works without changing the AMI.



###### \-> What is the difference between a resource and a data source-

**resource** - used to creat5e update and manage the aws infrastructure components. It manages the lifecycle of the infra.

**data source** - block used to fetch the existing information. This is read only block. Only queries the data to be used in configuration.



#### Task 5: Use Locals for Dynamic Values

```

locals {

&#x20; name\_prefix = "${var.project\_name}-${var.environment}"

&#x20; common\_tags = {

&#x20;   Project     = var.project\_name

&#x20;   Environment = var.environment

&#x20;   ManagedBy   = "Terraform"

&#x20; }

}

```

And then merged the tags with common tags



```

tags = merge(local.common\_tags, {

&#x20; Name = "${local.name\_prefix}-server"

})

```



So the output is like

```

tags                                 = {

&#x20;         + "Environment" = "prod"

&#x20;         + "ManagedBy"   = "Terraform"

&#x20;         + "Name"        = "terraweek-prod-vpc"

&#x20;         + "Project"     = "terraweek"

&#x20;       }

```



#### Task 6: Built-in Functions and Conditional Expressions

Used

```

instance\_type = var.environment == "prod" ? "t2.micro" : "t3.micro"

```



And verified that the instance type changes with env



```

\+ instance\_type                        = "**t2.micro**"

tags                                 = {

&#x20;         + "name" = "terraweek-**prod**-server"

}

```

And when



```

&#x20;+ instance\_type                        = "**t3.micro**"

tags                                 = {

&#x20;         + "name" = "terraweek**-dev-**server"

&#x20;       }

```



Final apply output

```

Outputs:



instance\_id = "i-0056c04d236196237"

instance\_public\_dns = "ec2-44-221-80-139.compute-1.amazonaws.com"

instance\_public\_ip = "44.221.80.139"

security\_group\_id = "sg-06f34c941f99bb353"

subnet\_id = "subnet-05b063437849fd710"

vpc\_id = "vpc-031cbffa201925002"



```



I can login to this machine

```

aishuser@aish-ubuntu-tws:\~$ ssh -i /home/aishuser/.ssh/id\_ed25519 ec2-user@44.221.80.139

&#x20;  ,     #\_

&#x20;  \~\\\_  ####\_        Amazon Linux 2

&#x20; \~\~  \\\_#####\\

&#x20; \~\~     \\###|       AL2 End of Life is 2026-06-30.

&#x20; \~\~       \\#/ \_\_\_

&#x20;  \~\~       V\~' '->

&#x20;   \~\~\~         /    A newer version of Amazon Linux is available!

&#x20;     \~\~.\_.   \_/

&#x20;        \_/ \_/       Amazon Linux 2023, GA and supported until 2028-03-15.

&#x20;      \_/m/'           https://aws.amazon.com/linux/amazon-linux-2023/



\[ec2-user@ip-172-31-75-193 \~]$ 

```



##### Pick five functions you find most useful and explain what each does

1. merge(map1, map2, ...)

Takes multiple maps or objects and merges them into a single map

Use: It is essential for combining default resource tags with environment-specific tags, or merging default settings with variable overrides.



2\. lookup(map, key, default)

Retrieves the value of a single element from a map based on a given key. If the key is not found, it returns the provided default value.

Example: lookup(var.instance\_types, "prod", "t3.micro")

Use: It provides a safe way to access map values without causing an error if the key is missing, making it ideal for creating environment-specific configurations.



3\. fileexists(path)

checks if file exists at given path, and returns true or false.

Use: It enables conditional logic to determine if optional configuration files (like SSH public keys or specific startup scripts) should be loaded, preventing "file not found" errors during planning.

example:

> fileexists("${path.module}/hello.txt")

true



4\. file(path)

Reads the content of the file at given path and returns as string

example

> file("${path.module}/hello.txt")

Hello World



5\. replace(string, substring, replacement)

searches a given string for another given substring, and replaces each occurrence with a given replacement string

example

> replace("1 + 2 + 3", "+", "-")

1 - 2 - 3

