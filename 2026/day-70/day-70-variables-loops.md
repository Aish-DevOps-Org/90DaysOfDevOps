# Day 70 -- Variables, Facts, Conditionals and Loops

## Task 1: Variables in Playbooks

Run playbook with variables configured in the play and then define the variable while running the playbook. 

The vaiable from CLI overrides the playbook file variable.

```sh
TASK [Print app details] **********************************************************************************
ok: [localhost] => {
    "msg": "Deploying my-custom-app on port 9090 to /opt/my-custom-app"
}
ok: [Workernode1] => {
    "msg": "Deploying my-custom-app on port 9090 to /opt/my-custom-app"
}
ok: [Workernode2] => {
    "msg": "Deploying my-custom-app on port 9090 to /opt/my-custom-app"
}

```

## Task 2: group_vars and host_vars

What is the variable precedence?

```sh
PLAY [Apply common config] ***************************************************************

TASK [Gathering Facts] *******************************************************************
ok: [Workernode1]
ok: [Workernode2]
ok: [localhost]

TASK [Install common packages] ***********************************************************
ok: [Workernode2]
ok: [Workernode1]
ok: [localhost]

TASK [Show environment] ******************************************************************
ok: [localhost] => {
    "msg": "Environment: development"
}
ok: [Workernode1] => {
    "msg": "Environment: development"
}
ok: [Workernode2] => {
    "msg": "Environment: development"
}

PLAY [Configure web servers] *************************************************************

TASK [Gathering Facts] *******************************************************************
ok: [Workernode1]

TASK [Show web config] *******************************************************************
ok: [Workernode1] => {
    "msg": "HTTP port: 80, Max connections: 2000"
}

TASK [Show host-specific message] ********************************************************
ok: [Workernode1] => {
    "msg": "This is the primary web server"
}

PLAY RECAP *******************************************************************************
Workernode1                : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
Workernode2                : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```

1. I added custom message in group_vars/web.yml \
custom_message: "This is from group_vars"
But when running playbook, it takes host_vars variable.

2. Then I added same variable in playbook vars \
vars:
    custom_message: "This is from playbook_vars"

And removed from host_vars

```sh
TASK [Show host-specific message] **********************************************
ok: [Workernode1] => {
    "msg": "This is from group_vars"
}
```

3. Then I run with -e switch
 -e '{"custom_message": "from runtime"}'

```sh
TASK [Show host-specific message] **********************************************
ok: [Workernode1] => {
    "msg": "from runtime"
}
```

> So host_vars > group_vars > playbookvars > -e switch

## Task 3: Ansible Facts -- Gathering System Information

```sh
PLAY [Apply common config] *****************************************************

TASK [Gathering Facts] *********************************************************
ok: [Workernode2]
ok: [Workernode1]
ok: [localhost]

TASK [Install common packages] *************************************************
ok: [Workernode1]
ok: [Workernode2]
ok: [localhost]

TASK [Show environment] ********************************************************
ok: [localhost] => {
    "msg": "Environment: development"
}
ok: [Workernode1] => {
    "msg": "Environment: development"
}
ok: [Workernode2] => {
    "msg": "Environment: development"
}

PLAY [Configure web servers] ***************************************************

TASK [Gathering Facts] *********************************************************
ok: [Workernode1]

TASK [Show web config] *********************************************************
ok: [Workernode1] => {
    "msg": "HTTP port: 80, Max connections: 2000"
}

TASK [Show host-specific message] **********************************************
ok: [Workernode1] => {
    "msg": "from runtime"
}

PLAY RECAP *********************************************************************
Workernode1                : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
Workernode2                : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

ubuntu@ip-172-31-13-187:~/ansible-practice$ ansible-playbook facts-demo.yml 

PLAY [Facts demo] **************************************************************

TASK [Gathering Facts] *********************************************************
ok: [localhost]
ok: [Workernode1]
ok: [Workernode2]

TASK [Show OS info] ************************************************************
ok: [localhost] => {
    "msg": "Hostname: ip-172-31-13-187, OS: Ubuntu 24.04, RAM: 911MB, IP: 172.31.13.187\n"
}
ok: [Workernode1] => {
    "msg": "Hostname: ip-172-31-6-79, OS: Ubuntu 24.04, RAM: 911MB, IP: 172.31.6.79\n"
}
ok: [Workernode2] => {
    "msg": "Hostname: ip-172-31-11-140, OS: Ubuntu 24.04, RAM: 911MB, IP: 172.31.11.140\n"
}

TASK [Show all network interfaces] *********************************************
ok: [localhost] => {
    "ansible_interfaces": [
        "lo",
        "ens5"
    ]
}
ok: [Workernode1] => {
    "ansible_interfaces": [
        "ens5",
        "lo"
    ]
}
ok: [Workernode2] => {
    "ansible_interfaces": [
        "ens5",
        "lo"
    ]
}
```

Facts will use in real playbooks - these will be useful when we are targetting different flavours and versions of managed nodes. To run the tasks on specific server based on these facts will be easier.

1. ansible_all_ipv4_addresses
2. ansible_distribution
3. ansible_distribution_version
4. ansible_hostname
5. ansible_memtotal_mb
6. ansible_os_family

## Task 4: Conditionals with when

```sh
PLAY [Conditional tasks demo] *****************************************************************************

TASK [Gathering Facts] ************************************************************************************
ok: [Workernode2]
ok: [Workernode1]
ok: [localhost]

TASK [Install Nginx (only on web servers)] ****************************************************************
skipping: [localhost]
skipping: [Workernode2]
ok: [Workernode1]      -> Changed only web server

TASK [Install MySQL (only on db servers)] *****************************************************************
skipping: [Workernode1]
skipping: [Workernode2]
changed: [localhost]      -> changed only db server

TASK [Show warning on low memory hosts] *******************************************************************
ok: [localhost] => {
    "msg": "WARNING: This host has less than 1GB RAM"
}
ok: [Workernode1] => {
    "msg": "WARNING: This host has less than 1GB RAM"
}
ok: [Workernode2] => {
    "msg": "WARNING: This host has less than 1GB RAM"
}

TASK [Run only on Amazon Linux] -> Skipped all as these are ubuntu vms ***************************************************************************
skipping: [localhost] 
skipping: [Workernode1]
skipping: [Workernode2]

TASK [Run only on Ubuntu] *********************************************************************************
ok: [localhost] => {
    "msg": "This is an Ubuntu machine"
}
ok: [Workernode1] => {
    "msg": "This is an Ubuntu machine"
}
ok: [Workernode2] => {
    "msg": "This is an Ubuntu machine"
}

TASK [Run only in production] *****************************************************************************
skipping: [localhost]
skipping: [Workernode1]
skipping: [Workernode2]

TASK [Multiple conditions (AND)] **************************************************************************
skipping: [localhost]
ok: [Workernode1] => {
    "msg": "Web server with enough memory"
}
skipping: [Workernode2]

TASK [OR condition] ***************************************************************************************
skipping: [localhost]
ok: [Workernode1] => {
    "msg": "Either web or app server"
}
ok: [Workernode2] => {
    "msg": "Either web or app server"
}

PLAY RECAP ************************************************************************************************
Workernode1                : ok=6    changed=0    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0   
Workernode2                : ok=4    changed=0    unreachable=0    failed=0    skipped=5    rescued=0    ignored=0   
localhost                  : ok=4    changed=1    unreachable=0    failed=0    skipped=5    rescued=0    ignored=0   
```

## Task 5: Loops

```sh
ubuntu@ip-172-31-13-187:~/ansible-practice$ ansible-playbook loops-demo.yml

PLAY [Loops demo] ******************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [localhost]
ok: [Workernode1]
ok: [Workernode2]

TASK [create multiple groups] ******************************************************************************************
changed: [localhost]
changed: [Workernode2]
changed: [Workernode1]

TASK [Create multiple directories] *************************************************************************************
ok: [localhost] => (item=/opt/app/logs)
ok: [Workernode1] => (item=/opt/app/logs)
ok: [Workernode2] => (item=/opt/app/logs)
ok: [localhost] => (item=/opt/app/config)
ok: [Workernode1] => (item=/opt/app/config)
ok: [Workernode2] => (item=/opt/app/config)
ok: [localhost] => (item=/opt/app/data)
ok: [Workernode1] => (item=/opt/app/data)
ok: [Workernode2] => (item=/opt/app/data)
ok: [localhost] => (item=/opt/app/tmp)
ok: [Workernode1] => (item=/opt/app/tmp)
ok: [Workernode2] => (item=/opt/app/tmp)

TASK [Create multiple users] *******************************************************************************************
changed: [localhost] => (item={'name': 'deploy', 'groups': 'wheel'})
changed: [Workernode2] => (item={'name': 'deploy', 'groups': 'wheel'})
changed: [Workernode1] => (item={'name': 'deploy', 'groups': 'wheel'})
changed: [localhost] => (item={'name': 'monitor', 'groups': 'wheel'})
changed: [Workernode2] => (item={'name': 'monitor', 'groups': 'wheel'})
changed: [Workernode1] => (item={'name': 'monitor', 'groups': 'wheel'})
ok: [localhost] => (item={'name': 'appuser', 'groups': 'users'})
ok: [Workernode1] => (item={'name': 'appuser', 'groups': 'users'})
ok: [Workernode2] => (item={'name': 'appuser', 'groups': 'users'})

TASK [Install multiple packages] ***************************************************************************************
ok: [Workernode1] => (item=git)
ok: [Workernode2] => (item=git)
ok: [localhost] => (item=git)
ok: [Workernode1] => (item=curl)
ok: [Workernode2] => (item=curl)
ok: [localhost] => (item=curl)
changed: [Workernode1] => (item=unzip)
changed: [Workernode2] => (item=unzip)
ok: [Workernode1] => (item=jq)
ok: [Workernode2] => (item=jq)
changed: [localhost] => (item=unzip)
ok: [localhost] => (item=jq)

TASK [Print each user created] *****************************************************************************************
ok: [localhost] => (item={'name': 'deploy', 'groups': 'wheel'}) => {
    "msg": "Created user deploy in group wheel"
}
ok: [localhost] => (item={'name': 'monitor', 'groups': 'wheel'}) => {
    "msg": "Created user monitor in group wheel"
}
ok: [Workernode1] => (item={'name': 'deploy', 'groups': 'wheel'}) => {
    "msg": "Created user deploy in group wheel"
}
ok: [Workernode2] => (item={'name': 'deploy', 'groups': 'wheel'}) => {
    "msg": "Created user deploy in group wheel"
}
ok: [localhost] => (item={'name': 'appuser', 'groups': 'users'}) => {
    "msg": "Created user appuser in group users"
}
ok: [Workernode1] => (item={'name': 'monitor', 'groups': 'wheel'}) => {
    "msg": "Created user monitor in group wheel"
}
ok: [Workernode2] => (item={'name': 'monitor', 'groups': 'wheel'}) => {
    "msg": "Created user monitor in group wheel"
}
ok: [Workernode1] => (item={'name': 'appuser', 'groups': 'users'}) => {
    "msg": "Created user appuser in group users"
}
ok: [Workernode2] => (item={'name': 'appuser', 'groups': 'users'}) => {
    "msg": "Created user appuser in group users"
}

PLAY RECAP *************************************************************************************************************
Workernode1                : ok=6    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
Workernode2                : ok=6    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=6    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Loop: modern explicit syntax introduced in ansible 2.5. this does not flatten lists automatically, will have to use | flatter filter.

with_items: Legancy. Automatically flattend nested lists one level deep.

## Task 6: Register, Debug, and Combine Everything

```sh
PLAY [Server Health Report] ********************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [localhost]
ok: [Workernode2]
ok: [Workernode1]

TASK [Check disk space] ************************************************************************************************
changed: [Workernode2]
changed: [localhost]
changed: [Workernode1]

TASK [Check memory] ****************************************************************************************************
changed: [localhost]
changed: [Workernode1]
changed: [Workernode2]

TASK [Check running services] ******************************************************************************************
changed: [localhost]
changed: [Workernode1]
changed: [Workernode2]

TASK [Generate report] *************************************************************************************************
ok: [Workernode1] => {
    "msg": [
        "========== Workernode1 ==========",
        "OS: Ubuntu 24.04",
        "IP: 172.31.6.79",
        "RAM: 911MB",
        "Disk: /dev/root       6.8G  2.1G  4.7G  31% /",
        "Running services (first 20): 20"
    ]
}
ok: [localhost] => {
    "msg": [
        "========== localhost ==========",
        "OS: Ubuntu 24.04",
        "IP: 172.31.13.187",
        "RAM: 911MB",
        "Disk: /dev/root       6.8G  3.4G  3.4G  51% /",
        "Running services (first 20): 20"
    ]
}
ok: [Workernode2] => {
    "msg": [
        "========== Workernode2 ==========",
        "OS: Ubuntu 24.04",
        "IP: 172.31.11.140",
        "RAM: 911MB",
        "Disk: /dev/root       6.8G  2.1G  4.7G  31% /",
        "Running services (first 20): 20"
    ]
}

TASK [Flag if disk is critically low] **********************************************************************************
skipping: [localhost]
skipping: [Workernode1]
skipping: [Workernode2]

TASK [Save report to file] *********************************************************************************************
changed: [localhost]
changed: [Workernode1]
changed: [Workernode2]

PLAY RECAP *************************************************************************************************************
Workernode1                : ok=6    changed=4    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
Workernode2                : ok=6    changed=4    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
localhost                  : ok=6    changed=4    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```

the output report

```sh
ubuntu@ip-172-31-13-187:~/ansible-practice$ cat /tmp/server-report-*.txt
Server: localhost
OS: Ubuntu 24.04
IP: 172.31.13.187
RAM: 911MB
Disk: Filesystem      Size  Used Avail Use% Mounted on
/dev/root       6.8G  3.4G  3.4G  51% /
Checked at: 2026-04-15T13:55:54Z
```
