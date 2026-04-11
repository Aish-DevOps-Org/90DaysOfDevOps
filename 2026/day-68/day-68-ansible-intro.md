# day-68-ansible-intro.md

## Task 1: Understand Ansible

1. What is configuration management? Why do we need it?

- When we have "n" number of target servers to manage, install something and configure something in those becomes difficult and time consuming with alot of repetitive work, if needs to be done manually.
- With configuration management tool like, ansible, chef, puppet, this can be automated. Where we can have a control node which can talk to all other n servers, we define the state we require and with push or pull method we can make those changes with few commands in all those target servers.
- This removes any human errors which might happen while repetitive work, also reduces time to business. Which reduces expense as well.

2. How is Ansible different from Chef, Puppet, and Salt?

- Ansible is agentless, where we do not need any agent configured. All the machines should have python and SSH connection should be there between the control node and managed nodes.
- Ansible is push based, where it pushes the changes to the managed nodes, and if the state matches then it makes no changes, and if it does not match then the changes are applied.
- Chef, puppet and salt are, declarative and agent based. They work on pull and push based mechanism. Where they pull the server info time to time to keep the state off the server updated and push the changes.
- Steeper learning curve, often requiring knowledge of Ruby (Puppet uses a declarative DSL, Chef uses Ruby-based recipes). But Ansible uses very simple YAML syntax which makes it very easy for beginners.

3. What does "agentless" mean? How does Ansible connect to managed nodes?

- Ansilble  does not have any agent running to manage the worker nodes. It connected with WN using SSH and the only prerequisite is to have pythion installed in each server as Ansible is based on python.

4. Draw or describe the Ansible architecture: Check  [Ansible Architecture](https://github.com/Aish-DevOps-Org/90DaysOfDevOps/blob/master/2026/day-68/Ansible%20Architecture.png) \
    a. Control Node -- the machine where Ansible runs (your laptop or a jump server) \
    b. Managed Nodes -- the servers Ansible configures (your EC2 instances) \
    Inventory -- the list of managed nodes  \
    c. Modules -- units of work Ansible executes (install a package, copy a file, start a service) \
    d. Playbooks -- YAML files that define what to do on which hosts 

## Task 2: Set Up Your Lab Environment

See Terrform folder -> for env created for ansible

```bash
aishuser@aish-ubuntu-tws:~/ansible-infra$ terraform apply -auto-approve
var.project_name
  Enter a value: ansible

aws_default_subnet.aish_default_subnet: Refreshing state... [id=subnet-04367bdaaa2a75a91]
aws_default_vpc.aish_vpc: Refreshing state... [id=vpc-09e72be1d9115e740]
aws_key_pair.aish_key: Refreshing state... [id=tf_ec2_key]
aws_security_group.aish_security_group: Refreshing state... [id=sg-0080ee96c6125206b]
aws_instance.aish_instance[0]: Refreshing state... [id=i-0b72c01da30b564f7]
aws_instance.aish_instance[2]: Refreshing state... [id=i-025a819fede13ea15]
aws_vpc_security_group_egress_rule.allow_all_traffic: Refreshing state... [id=sgr-068257539d87f2ad0]
aws_instance.aish_instance[1]: Refreshing state... [id=i-04958654b62478e25]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are
needed.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

all_instance_ids = [
  "i-0b72c01da30b564f7",
  "i-04958654b62478e25",
  "i-025a819fede13ea15",
]
instance_name = [
  "Master node",
  "Worker Node - 1",
  "Worker Node - 2",
]
instance_public_dns = [
  "ec2-34-222-252-54.us-west-2.compute.amazonaws.com",
  "ec2-54-185-177-115.us-west-2.compute.amazonaws.com",
  "ec2-35-167-101-189.us-west-2.compute.amazonaws.com",
]
instance_public_ip = [
  "34.222.252.54",
  "54.185.177.115",
  "35.167.101.189",
]
security_group_id = "sg-0080ee96c6125206b"
subnet_id = "subnet-04367bdaaa2a75a91"
vpc_id = "vpc-09e72be1d9115e740"
```

verfied that I can SSH to all 3 nodes.

## Task 3: Install Ansible

1. On which machine did you install Ansible? Why is it only needed on the control node?

We installed ansible in control node, as ansible does not need agent setup, it conencts with managed nodes using SSH and the details of the managed nodes should be mentioned in the inventory files which is stored in controle node.

```bash
ubuntu@ip-172-31-35-176:~$ ansible --version
ansible [core 2.16.3]
  config file = None
  configured module search path = ['/home/ubuntu/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /home/ubuntu/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.12.3 (main, Mar  3 2026, 12:15:18) [GCC 13.3.0] (/usr/bin/python3)
  jinja version = 3.1.2
  libyaml = True
  ```

## Task 4: Create Your Inventory File

Inventory.ini

```bash
ubuntu@ip-172-31-35-176:~/ansible-practice$ cat inventory.ini 
[web]
Workernode1 ansible_host=54.185.177.115

[app]
Workernode2 ansible_host=35.167.101.189

[all:vars]
ansible_user=ubuntu
ansible_ssh_privatye_key_file=~/ansible-practice/tf-instance-key.pem
```

Output

```bash

ubuntu@ip-172-31-35-176:~/ansible-practice$ ansible all -i inventory.ini -m ping
Workernode1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
Workernode2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

## Task 5: Run Ad-Hoc Commands

1. Check uptime

```bash
ubuntu@ip-172-31-35-176:~/ansible-practice$ ansible all -i inventory.ini -m command -a "uptime"
Workernode2 | CHANGED | rc=0 >>
 11:53:57 up  1:03,  1 user,  load average: 0.00, 0.00, 0.00
Workernode1 | CHANGED | rc=0 >>
 11:53:57 up  1:03,  1 user,  load average: 0.00, 0.00, 0.00
```

2. check free memory

```bash
ubuntu@ip-172-31-35-176:~/ansible-practice$ ansible all -i inventory.ini -m command -a "free -h"
Workernode2 | CHANGED | rc=0 >>
               total        used        free      shared  buff/cache   available
Mem:           911Mi       381Mi       273Mi       2.7Mi       415Mi       530Mi
Swap:             0B          0B          0B
Workernode1 | CHANGED | rc=0 >>
               total        used        free      shared  buff/cache   available
Mem:           911Mi       364Mi       284Mi       2.7Mi       420Mi       547Mi
Swap:             0B          0B          0B

```

3. Check disk space

```bash
ubuntu@ip-172-31-35-176:~/ansible-practice$ ansible all -i inventory.ini -m command -a "df -h"
Workernode2 | CHANGED | rc=0 >>
Filesystem       Size  Used Avail Use% Mounted on
/dev/root        6.8G  1.9G  4.9G  28% /
tmpfs            456M     0  456M   0% /dev/shm
tmpfs            183M  876K  182M   1% /run
tmpfs            5.0M     0  5.0M   0% /run/lock
efivarfs         128K  3.6K  120K   3% /sys/firmware/efi/efivars
/dev/nvme0n1p16  881M   94M  726M  12% /boot
/dev/nvme0n1p15  105M  6.2M   99M   6% /boot/efi
tmpfs             92M   12K   92M   1% /run/user/1000
Workernode1 | CHANGED | rc=0 >>
Filesystem       Size  Used Avail Use% Mounted on
/dev/root        6.8G  1.9G  4.9G  28% /
tmpfs            456M     0  456M   0% /dev/shm
tmpfs            183M  872K  182M   1% /run
tmpfs            5.0M     0  5.0M   0% /run/lock
efivarfs         128K  3.6K  120K   3% /sys/firmware/efi/efivars
/dev/nvme0n1p16  881M   94M  726M  12% /boot
/dev/nvme0n1p15  105M  6.2M   99M   6% /boot/efi
tmpfs             92M   12K   92M   1% /run/user/1000
```

4. Install a package on the web group:

```bash
ubuntu@ip-172-31-35-176:~/ansible-practice$ ansible all -i inventory.ini -m apt -a "name=git state=present" --become
Workernode1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "cache_update_time": 1773439990,
    "cache_updated": false,
    "changed": false
}
Workernode2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "cache_update_time": 1773439990,
    "cache_updated": false,
    "changed": false
}
ubuntu@ip-172-31-35-176:~/ansible-practice$ ansible all -i inventory.ini -m command -a "git --version"
Workernode2 | CHANGED | rc=0 >>
git version 2.43.0
Workernode1 | CHANGED | rc=0 >>
git version 2.43.0
```

5. Copy file to all servers 

```bash
ubuntu@ip-172-31-35-176:~/ansible-practice$ ansible all -i inventory.ini -m copy -a "src=hello.txt dest=/tmp/hello.txt"
Workernode1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": true,
    "checksum": "9b02adc484350380842c4c735d57a1ad071ff0a1",
    "dest": "/tmp/hello.txt",
    "gid": 1000,
    "group": "ubuntu",
    "md5sum": "914d64e550abfbc035d79d50e214e47d",
    "mode": "0664",
    "owner": "ubuntu",
    "size": 19,
    "src": "/home/ubuntu/.ansible/tmp/ansible-tmp-1775908762.5515516-2744-9932024569975/source",
    "state": "file",
    "uid": 1000
}
Workernode2 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": true,
    "checksum": "9b02adc484350380842c4c735d57a1ad071ff0a1",
    "dest": "/tmp/hello.txt",
    "gid": 1000,
    "group": "ubuntu",
    "md5sum": "914d64e550abfbc035d79d50e214e47d",
    "mode": "0664",
    "owner": "ubuntu",
    "size": 19,
    "src": "/home/ubuntu/.ansible/tmp/ansible-tmp-1775908762.560825-2745-100792484008444/source",
    "state": "file",
    "uid": 1000
}
```

6. Check the file was copied

```bash
ubuntu@ip-172-31-35-176:~/ansible-practice$ ansible all -i inventory.ini -m command -a "cat /tmp/hello.txt"
Workernode1 | CHANGED | rc=0 >>
Hello from Ansible
Workernode2 | CHANGED | rc=0 >>
Hello from Ansible
```

## Task 6: Explore Inventory Groups and Patterns

1. updated inventory.ini

```ini
[application:children]
app

[all_servers:children]
application
web

[web]
Workernode1 ansible_host=54.185.177.115

[app]
Workernode2 ansible_host=35.167.101.189

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/ansible-practice/tf-instance-key.pem
```

2. Run commands against diff groups

```bash
ubuntu@ip-172-31-35-176:~/ansible-practice$ ansible application -i inventory.ini -m ping
Workernode2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}

ubuntu@ip-172-31-35-176:~/ansible-practice$ ansible web -i inventory.ini -m ping
Workernode1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}

ubuntu@ip-172-31-35-176:~/ansible-practice$ ansible all_servers -i inventory.ini -m ping
Workernode1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
Workernode2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

3. Create ansible.cfg to avoid typing -i inventory every time

```bash
[defaults]
inventory = inventory.ini
host_key_checking = False
remote_user = ubuntu
private_key_file = ~/ansible-practice/tf-instance-key.pem
```

```bash
ubuntu@ip-172-31-35-176:~/ansible-practice$ ansible all -m ping
Workernode2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
Workernode1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

### Question: Difference between command and shell module?

Shell module is almost exactly like the ansible.builtin.command module but runs the command through a shell (/bin/sh) on the remote node. Command module does not support some shell features like pipe (|), redirects (>) etc.

Use shel module: When you specifically need shell-specific logic, such as using grep with pipes, redirecting logs to a file, or if you need to use a specific shell like /bin/bash via the executable parameter

Use command module: For simple tasks that only require running a specific binary with arguments. It is the safer and preferred choice whenever specialized modules are unavailable.

```bash
ubuntu@ip-172-31-35-176:~/ansible-practice$ ansible all -m shell -a "chdir=/tmp/ cat hello.txt"
Workernode1 | CHANGED | rc=0 >>
Hello from Ansible
Workernode2 | CHANGED | rc=0 >>
Hello from Ansible
```
