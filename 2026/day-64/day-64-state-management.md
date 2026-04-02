#### Task 1: Inspect Your Current State

Terraform show                                    # Full state in human-readable format

\-> showing every details it shows while we run plan or apply command and not only what we defined in the config.



terraform state list                              # All resources tracked by Terraform

\-> lists all the resources it created as per plan



terraform state show aws\_instance.<name>          # Every attribute of the instance

terraform state show aws\_vpc.<name>               # Every attribute of the VPC

\-> Filters the details of only EC2/vpc resource it created



###### **Answer**:

How many resources does Terraform track? -> 2 in my case as I created EC2 and S3 bucket.

What attributes does the state store for an EC2 instance? (hint: way more than what you defined) -> All the details it was showing during plan

Open terraform.tfstate in an editor -- find the serial number. What does it represent? 

\-> Serial: 11, this maintains the version control for terraform. showing this many times the state changed. The number increases every time a terraform apply or terraform refresh modifies the state file.

\-> During destroy it changes with +2. The serial increases during the initial planning/deletion phase and again during the final state update to confirm all resources are gone, indicating a healthy, two-phase operation.



#### Task 2: Set Up S3 Remote Backend

error 

```

Error: Error acquiring the state lock

│

│ Error message: operation error DynamoDB: PutItem, https response error

│ StatusCode: 400, RequestID:

│ F45V90V7CUI3FH36EJ9FH9G7TRVV4KQNSO5AEMVJF66Q9ASUAAJG, api error

│ ValidationException: One or more parameter values were invalid: Missing

│ the key LockId in the item

│ Unable to retrieve item from DynamoDB table "terraweek-state-lock":

│ operation error DynamoDB: GetItem, https response error StatusCode: 400,

│ RequestID: CFB5NSMRJ8AKS3POS7VTM16LIJVV4KQNSO5AEMVJF66Q9ASUAAJG, api

│ error ValidationException: The provided key element does not match the

│ schema

```



This happened because the primary key was set to "LockId", and the correct key is "LockID".

After updating it, the plan was successful.



\-> After terraform apply I see the state is moved to S3 bucket check - [backend.png](https://github.com/Aish-DevOps-Org/90DaysOfDevOps/blob/master/2026/day-64/backend.png)

and local state looks like below

```

{

&#x20; "version": 4,

&#x20; "terraform\_version": "1.14.8",

&#x20; "serial": 29,

&#x20; "lineage": "be0ad56b-0a5f-692b-5809-252beb166139",

&#x20; "outputs": {},

&#x20; "resources": \[],

&#x20; "check\_results": null

}

```

Though terraform state list shows many resources

```

data.aws\_ami.amazon\_linux

data.aws\_availability\_zones.available

aws\_instance.aish\_instance

aws\_internet\_gateway.aish\_int\_gateway

aws\_key\_pair.aish\_key

aws\_route\_table.aish\_route\_table

aws\_route\_table\_association.aish\_route\_table\_association

aws\_s3\_bucket.aish\_bucket

aws\_security\_group.aish\_security\_group

aws\_subnet.aish\_subnet

aws\_vpc.aish\_vpc

aws\_vpc\_security\_group\_egress\_rule.allow\_all\_traffic

```



\-> And terraform plan shows

```

No changes. Your infrastructure matches the configuration.



Terraform has compared your real infrastructure against your

configuration and found no differences, so no changes are needed.

```

#### Task 3: Test State Locking

###### What is the error message? Why is locking critical for team environments?



```

&#x20;Error: Error acquiring the state lock

│ 

│ Error message: operation error DynamoDB: PutItem, https response error

│ StatusCode: 400, RequestID:

│ 0QADLB8TFSJIFF9U53KJ861QGJVV4KQNSO5AEMVJF66Q9ASUAAJG,

│ ConditionalCheckFailedException: The conditional request failed

│ Lock Info:

│   ID:        a2dd9268-cbb0-72f3-a3a4-e8c074e27d79

│   Path:      terraweek-state-aish/dev/terraform.tfstate

│   Operation: OperationTypeApply

│   Who:       aishuser@aish-ubuntu-tws

│   Version:   1.14.8

│   Created:   2026-04-02 15:33:58.936535709 +0000 UTC

│   Info:      

│ 

│ 

│ Terraform acquires a state lock to protect the state from being

│ written

│ by multiple users at the same time. Please resolve the issue above and

│ try

│ again. For most commands, you can disable locking with the

│ "-lock=false"

│ flag, but this is not recommended.

```



the above message indicates that, an apply operation is already in place which has locked the state with id - a2dd9268-cbb0-72f3-a3a4-e8c074e27d79. in team environment this is very crucial as it helps prevent multiple changes at the same time which can break the existing state of the infra. as not everyone will have the current state if the state file is in local.



#### Task 4: Import an Existing Resource

Created a bucket manually from console.

while importing got error

```

Error: Cannot import non-existent remote object

│

│ While attempting to import an existing object to

│ "aws\_s3\_bucket.import\_bucket", the provider detected that no object    

│ exists with the given id. Only pre-existing objects can be imported;   

│ check that the id is correct and that it is associated with the        

│ provider's configured region or endpoint, or use "terraform apply" to  

│ create a new remote object for this resource.

```

My providers region was us-west-1 but the bucket was created in us-west-2. Once I created the bucket in provider's region, the issue got fixed.



```

aishuser@aish-ubuntu-tws:\~/terraform-aws-adv$ terraform state list aws\_s3\_bucket.import\_bucket

aws\_s3\_bucket.import\_bucket

```



###### What is the difference between terraform import and creating a resource from scratch?

\-> Import updates the terraform state with manually created resource which already exist in aws but not through terraform.

\-> Creating resource from scratch means creating a new resource.



#### Task 5: State Surgery -- mv and rm

```

aishuser@aish-ubuntu-tws:\~/terraform-aws-adv$ terraform state mv aws\_s3\_bucket.import\_bucket aws\_s3\_bucket.logs\_bucket

Move "aws\_s3\_bucket.import\_bucket" to "aws\_s3\_bucket.logs\_bucket"

Successfully moved 1 object(s).

aishuser@aish-ubuntu-tws:\~/terraform-aws-adv$ terraform state list aws\_s3\_bucket.logs\_bucket

aws\_s3\_bucket.logs\_bucket

```



Terraform plan shows no changes after updating the main.tf file with updated bucket resource name

```

aws\_s3\_bucket.logs\_bucket: Refreshing state... \[id=terraweek-aish2]

...

No changes. Your infrastructure matches the configuration.



Terraform has compared your real infrastructure against your

configuration and found no differences, so no changes are needed.  

``` 

Remove resource from state file

```

aishuser@aish-ubuntu-tws:\~/terraform-aws-adv$ terraform state rm aws\_s3\_bucket.logs\_bucket

Removed aws\_s3\_bucket.logs\_bucket

Successfully removed 1 resource instance(s).

\---

Terraform plan adds 1 now -

\# aws\_s3\_bucket.logs\_bucket will be created

Plan: 1 to add, 0 to change, 0 to destroy.

```



import again

```

aishuser@aish-ubuntu-tws:\~/terraform-aws-adv$ terraform import aws\_s3\_bucket.logs\_bucket terraweek-aish2

aws\_s3\_bucket.logs\_bucket: Importing from ID "terraweek-aish2"...

data.aws\_availability\_zones.available: Reading...

aws\_s3\_bucket.logs\_bucket: Import prepared!

&#x20; Prepared aws\_s3\_bucket for import

data.aws\_ami.amazon\_linux: Reading...

aws\_s3\_bucket.logs\_bucket: Refreshing state... \[id=terraweek-aish2]      

data.aws\_availability\_zones.available: Read complete after 0s \[id=us-east-1]

data.aws\_ami.amazon\_linux: Read complete after 1s \[id=ami-0622c21dd3d2b1075]



Import successful!



The resources that were imported are shown above. These resources are now in

your Terraform state and will henceforth be managed by Terraform.  

```



###### \-> When would you use state mv in a real project? When would you use state rm?

state mv -> If we want to change the resource name or move it in the files, then the state mv would be helpful as terraform might thing we are destrying and creating new resource.

state rm -> if we want a terraform to stop managing a resource but dont want to delete that resource.



#### Task 6: Simulate and Fix State Drift

Manually added tag to the S3 bucket from aws console

Terraform detects the change

```

\~ update in-place



Terraform will perform the following actions:



&#x20; # aws\_s3\_bucket.logs\_bucket will be updated in-place

&#x20; \~ resource "aws\_s3\_bucket" "logs\_bucket" {

&#x20;     + force\_destroy               = false

&#x20;       id                          = "terraweek-aish2"

&#x20;     \~ tags                        = {

&#x20;         - "tag" = "new" -> null

&#x20;       }

&#x20;     \~ tags\_all                    = {

&#x20;         - "tag" = "new" -> null

&#x20;       }

&#x20;       # (11 unchanged attributes hidden)



&#x20;       # (3 unchanged blocks hidden)

&#x20;   }



Plan: 0 to add, 1 to change, 0 to destroy.

```

Applied the change and the tag is deleted from the bucket.



###### How do teams prevent state drift in production? (hint: restrict console access, use CI/CD for all changes)

If we stop the access to the console and all the changes are only made through automation using pipelines, then there will be only one way to manage the infrastructure so no drift will happen in production. Which is a best practice for prod env.

