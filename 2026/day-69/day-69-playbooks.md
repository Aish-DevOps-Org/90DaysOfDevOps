# Day 69 -- Ansible Playbooks and Modules

## Task 1: Your First Playbook

1. create a playbook to install nginx

```yml
- name: install nginx
  hosts: web
  become: true
    
  tasks:
    - name: installing nginx
      apt:
        name: nginx
        state: present
          
    - name: start and enable nginx
      service:
        name: nginx
        state: started
        enabled: true
          
    - name: create a custom index page
      copy:
        content: "<h1> Deployed by ansible - terraweek server </h1>"
        dest: /usr/share/nginx/html/index.html
```

outcome

```bash
ubuntu@ip-172-31-35-176:~/ansible-practice$ ansible-playbook install-nginx.yml 

PLAY [install nginx] ********************************************************************

TASK [Gathering Facts] ******************************************************************
ok: [Workernode1]

TASK [installing nginx] *****************************************************************
changed: [Workernode1]

TASK [start and enable nginx] ***********************************************************
ok: [Workernode1]

TASK [create a custom index page] *******************************************************
changed: [Workernode1]

PLAY RECAP ******************************************************************************
Workernode1                : ok=4    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

ubuntu@ip-172-31-35-176:~/ansible-practice$ ansible-playbook install-nginx.yml 

PLAY [install nginx] ********************************************************************

TASK [Gathering Facts] ******************************************************************
ok: [Workernode1]

TASK [installing nginx] *****************************************************************
ok: [Workernode1]

TASK [start and enable nginx] ***********************************************************
ok: [Workernode1]

TASK [create a custom index page] *******************************************************
ok: [Workernode1]

PLAY RECAP ******************************************************************************
Workernode1                : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

I see the default pag:

```html
ubuntu@ip-172-31-35-176:~/ansible-practice$ curl 54.185.177.115
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

Need to copy the custom page to /var/www/html/index.html

```yml
 - name: create a custom index page
      copy:
        content: "<h1> Deployed by ansible - terraweek server </h1>"
        dest: /var/www/html/index.html
      notify:
        - restart_nginx
        
handlers:
   - name: restart_nginx
     service:
       name: nginx
       state: restarted
```

output

```bash
TASK [create a custom index page] ***********************************************************************
changed: [Workernode1]

RUNNING HANDLER [restart_nginx] *************************************************************************
changed: [Workernode1]

PLAY RECAP **********************************************************************************************
Workernode1                : ok=7    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```

Now I see the custom page

```bash
ubuntu@ip-172-31-35-176:~/ansible-practice$ curl 54.185.177.115
<h1> Deployed by ansible - terraweek server </h1>
```

## Task 2: Understand the Playbook Structure

```yaml
---                                    # Start of the yaml doc
- name: install nginx                  # Play -- targets a group of hosts
  hosts: web                           # group mentioned in the inventory 
  become: true                         # run as sudo user

  tasks:                               # list of tasks in this play
    - name: installing nginx           # Task -- one unit of work
      apt:                             # Module -- what ansible does
        name: nginx                    # Module arguments
        state: present

    - name: start and enable nginx
      service:
        name: nginx
        state: started
        enabled: true

    - name: create a custom index page
      copy:
        content: "<h1> Deployed by ansible - terraweek server </h1>"
        dest: /var/www/html/index.html
      notify:                           # event which will trigger the handler if this task changed
        - restart_nginx

  handlers:                             # only runs when the notify event triggers it
   - name: restart_nginx
     service:
       name: nginx
       state: restarted
```

### Answer

1. What is the difference between a play and a task?

- task: one unit of work, uses ansible modules to define what to do.
- play: Ordered list of tasks that maps to nodes mentioned in inventory 

2. Can you have multiple plays in one playbook?

- Yes

3. What does become: true do at the play level vs the task level?

- At task level: only that task will be run as sudo user
- At play level: all the tasks inside this play will run as sudo user

4. What happens if a task fails -- do remaining tasks still run?

- For failed host: Other tasks will be skipped
- For other hosts in the list: it will run the tasks normally

## Task 3: Learn the Essential Modules

1. apt -- Install and remove packages

The playbook

```yaml
- name: insall packages
  hosts: all_servers
  become: yes

  tasks: 
  - name: Install multiple packages
    apt:
      name:
       - git
       - curl
       - wget
       - tree
      state: present
      update_cache: yes
```

Output

```yaml
ubuntu@ip-172-31-42-2:~/ansible-practice$ ansible-playbook essential-modules.yml 

PLAY [insall packages] ***********************************************************

TASK [Gathering Facts] ***********************************************************
ok: [localhost]
ok: [Workernode1]
ok: [Workernode2]

TASK [Install multiple packages] *************************************************
ok: [localhost]
changed: [Workernode2]
changed: [Workernode1]

PLAY RECAP ***********************************************************************
Workernode1                : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
Workernode2                : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```

2. service -- Manage services:

```yaml
TASK [Install multiple packages] *************************************************
changed: [Workernode1]
changed: [Workernode2]
changed: [localhost]

TASK [Ensure Nginx is running] ***************************************************
ok: [Workernode1]
ok: [Workernode2]
ok: [localhost]

PLAY RECAP ***********************************************************************
Workernode1                : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
Workernode2                : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```

3. copy -- Copy files from control node to managed nodes:

```sh
TASK [Copy config file] **********************************************************
changed: [localhost]
changed: [Workernode2]
changed: [Workernode1]
```

4. file -- Create directories and manage permissions:

```bash
TASK [create app directory] ************************************************************
changed: [localhost]
changed: [worknode1]
changed: [workernode2]

PLAY RECAP *****************************************************************************
localhost                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
workernode2                : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
worknode1                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```

5. Command -- run a command (no shell feature)

```sh
TASK [print disk space] ****************************************************************
ok: [localhost] => {
    "disk_output.stdout_lines": [
        "Filesystem       Size  Used Avail Use% Mounted on",
        "/dev/root        6.8G  2.9G  3.9G  43% /",
        "tmpfs            456M  188K  456M   1% /dev/shm",
        "tmpfs            183M  896K  182M   1% /run",
        "tmpfs            5.0M     0  5.0M   0% /run/lock",
        "efivarfs         128K  3.6K  120K   3% /sys/firmware/efi/efivars",
        "/dev/nvme0n1p16  881M  162M  657M  20% /boot",
        "/dev/nvme0n1p15  105M  6.2M   99M   6% /boot/efi",
        "tmpfs             92M   12K   92M   1% /run/user/1000"
    ]
}
ok: [worknode1] => {
    "disk_output.stdout_lines": [
        "Filesystem       Size  Used Avail Use% Mounted on",
        "/dev/root        6.8G  1.9G  4.9G  28% /",
        "tmpfs            456M     0  456M   0% /dev/shm",
        "tmpfs            183M  876K  182M   1% /run",
        "tmpfs            5.0M     0  5.0M   0% /run/lock",
        "efivarfs         128K  3.6K  120K   3% /sys/firmware/efi/efivars",
        "/dev/nvme0n1p16  881M   94M  726M  12% /boot",
        "/dev/nvme0n1p15  105M  6.2M   99M   6% /boot/efi",
        "tmpfs             92M   12K   92M   1% /run/user/1000"
    ]
}
ok: [workernode2] => {
    "disk_output.stdout_lines": [
        "Filesystem       Size  Used Avail Use% Mounted on",
        "/dev/root        6.8G  1.9G  4.9G  28% /",
        "tmpfs            456M     0  456M   0% /dev/shm",
        "tmpfs            183M  876K  182M   1% /run",
        "tmpfs            5.0M     0  5.0M   0% /run/lock",
        "efivarfs         128K  3.6K  120K   3% /sys/firmware/efi/efivars",
        "/dev/nvme0n1p16  881M   94M  726M  12% /boot",
        "/dev/nvme0n1p15  105M  6.2M   99M   6% /boot/efi",
        "tmpfs             92M   12K   92M   1% /run/user/1000"
    ]
}

PLAY RECAP *****************************************************************************
localhost                  : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
workernode2                : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
worknode1                  : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  

```

6. Shell: Run a command with shell features (pipes, redirects):

```sh
TASK [count running processes] *********************************************************
changed: [localhost]
changed: [worknode1]
changed: [workernode2]

TASK [show process count] **************************************************************
ok: [localhost] => {
    "msg": "todal processes: 127"
}
ok: [worknode1] => {
    "msg": "todal processes: 119"
}
ok: [workernode2] => {
    "msg": "todal processes: 119"
}

PLAY RECAP *****************************************************************************
localhost                  : ok=6    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
workernode2                : ok=6    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
worknode1                  : ok=6    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```

7. lineinfile -- Add or modify a single line in a file:

```sh

TASK [Set timezone in environment] *********************************************
changed: [localhost]
changed: [workernode2]
changed: [worknode1]

PLAY RECAP *********************************************************************
localhost                  : ok=7    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
workernode2                : ok=7    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
worknode1                  : ok=7    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

ubuntu@ip-172-31-33-176:~/ansible-practice$ cat /etc/environment 
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"

TZ=Asia/Kolkata
```

### What is the difference between command and shell? When should you use each?


Shell module is almost exactly like the ansible.builtin.command module but runs the command through a shell (/bin/sh) on the remote node. Command module does not support some shell features like pipe (|), redirects (>) etc.

Use shell module: When you specifically need shell-specific logic, such as using grep with pipes, redirecting logs to a file, or if you need to use a specific shell like /bin/bash via the executable parameter

Use command module: For simple tasks that only require running a specific binary with arguments. It is the safer and preferred choice whenever specialized modules are unavailable.

```bash
ubuntu@ip-172-31-35-176:~/ansible-practice$ ansible all -m shell -a "chdir=/tmp/ cat hello.txt"
Workernode1 | CHANGED | rc=0 >>
Hello from Ansible
Workernode2 | CHANGED | rc=0 >>
Hello from Ansible
```

## Task 4: Handlers -- Restart Services Only When Needed

Handlers are tasks that run only when triggered by a notify. This avoids unnecessary service restarts.

```sh
PLAY [install nginx] ******************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************
ok: [worknode1]
ok: [workernode2]

TASK [installing nginx] ***************************************************************************************************
ok: [worknode1]
ok: [workernode2]

TASK [start and enable nginx] *********************************************************************************************
ok: [workernode2]
ok: [worknode1]

TASK [create a custom index page] *****************************************************************************************
changed: [worknode1]
changed: [workernode2]

RUNNING HANDLER [restart_nginx] *******************************************************************************************
changed: [worknode1]
changed: [workernode2]

PLAY RECAP ****************************************************************************************************************
workernode2                : ok=5    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
worknode1                  : ok=5    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```

run again - the handler is not triggered

```sh
PLAY [install nginx] ***************************************************************

TASK [Gathering Facts] *************************************************************
ok: [workernode2]
ok: [worknode1]

TASK [installing nginx] ************************************************************
ok: [worknode1]
ok: [workernode2]

TASK [start and enable nginx] ******************************************************
ok: [worknode1]
ok: [workernode2]

TASK [create a custom index page] **************************************************
ok: [workernode2]
ok: [worknode1]

PLAY RECAP *************************************************************************
workernode2                : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
worknode1                  : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

```html
ubuntu@ip-172-31-33-176:~/ansible-practice$ curl http://44.244.4.78/
<h1>Managed by Ansible</h1><p>Server: workernode2</p>

ubuntu@ip-172-31-33-176:~/ansible-practice$ curl http://54.69.187.245/
<h1>Managed by Ansible</h1><p>Server: worknode1</p>

```

## Task 5: Dry Run, Diff, and Verbosity

- limit to Limited hosts

```sh
ubuntu@ip-172-31-33-176:~/ansible-practice$ ansible-playbook install-nginx.yml --limit web --list
-hosts
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see
details

playbook: install-nginx.yml

  play #1 (webservers): install nginx   TAGS: []
    pattern: ['webservers']
    hosts (1):
      worknode1
```

- List what would be affected without running:

```sh
ubuntu@ip-172-31-33-176:~/ansible-practice$ ansible-playbook install-nginx.yml --list-hosts
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see
details

playbook: install-nginx.yml

  play #1 (webservers): install nginx   TAGS: []
    pattern: ['webservers']
    hosts (2):
      workernode2
      worknode1
```

```sh
ubuntu@ip-172-31-33-176:~/ansible-practice$ ansible-playbook install-nginx.yml --list-tasks
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see
details

playbook: install-nginx.yml

  play #1 (webservers): install nginx   TAGS: []
    tasks:
      installing nginx  TAGS: []
      start and enable nginx    TAGS: []
      create a custom index page        TAGS: []
```

- Dry run and diff mode

```sh
ubuntu@ip-172-31-33-176:~/ansible-practice$ ansible-playbook nginx.yml --check -
-diff
[WARNING]: Invalid characters were found in group names but not replaced, use
-vvvv to see details

PLAY [Configure Nginx with a custom config] ************************************

TASK [Gathering Facts] *********************************************************
ok: [workernode2]
ok: [worknode1]

TASK [install multiple packages] ***********************************************
ok: [workernode2]
ok: [worknode1]

TASK [Install Nginx] ***********************************************************
ok: [worknode1]
ok: [workernode2]

TASK [Ensure Nginx is running] *************************************************
ok: [worknode1]
ok: [workernode2]

TASK [Deploy Nginx config] *****************************************************
ok: [workernode2]
ok: [worknode1]

TASK [Deploy custom index page] ************************************************
--- before: /var/www/html/index.html
+++ after: /var/www/html/index.html
@@ -1 +1 @@
-<h1>Managed by Ansible</h1><p>Server: workernode2</p>
\ No newline at end of file
+<h1>Welcome! Managed by Ansible</h1><p>Server: workernode2</p>
\ No newline at end of file

changed: [workernode2]
--- before: /var/www/html/index.html
+++ after: /var/www/html/index.html
@@ -1 +1 @@
-<h1>Managed by Ansible</h1><p>Server: worknode1</p>
\ No newline at end of file
+<h1>Welcome! Managed by Ansible</h1><p>Server: worknode1</p>
\ No newline at end of file

changed: [worknode1]

RUNNING HANDLER [Restart nginx] ************************************************
changed: [worknode1]
changed: [workernode2]

PLAY RECAP *********************************************************************
workernode2                : ok=7    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
worknode1                  : ok=7    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```

### Why is --check --diff the most important flag combination for production use?

--check - tells what will be changed, what won't be changed, what can be failed when we do actual run. This is important in production so that we can fix the issues with dry-run instead of applying few tasks successfully and then debug the failing tasks. So, we can fix issues with dry run and then apply the playbook.
For ex. in above snapshot, it did not apply the changes but showed us what will be changed

```sh
workernode2                : ok=7    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
worknode1                  : ok=7    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

--diff - tells what is the difference after last apply and current file which we are applying.
For ex. in above snapshot, it is showing what was before and after

```sh
--- before: /var/www/html/index.html
+++ after: /var/www/html/index.html
@@ -1 +1 @@
-<h1>Managed by Ansible</h1><p>Server: workernode2</p>
\ No newline at end of file
+<h1>Welcome! Managed by Ansible</h1><p>Server: workernode2</p>
\ No newline at end of file
```

## Task 6: Multiple Plays in One Playbook

Is Nginx only installed on web servers? Is MySQL only on db servers?

Apache2 is only installed in web server -
```sh
ubuntu@ip-172-31-33-176:~/ansible-practice$ ansible workernode2 -m shell -a "sudo systemctl status apache2"
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see details
workernode2 | FAILED | rc=4 >>
Unit apache2.service could not be found.non-zero return code
ubuntu@ip-172-31-33-176:~/ansible-practice$ ansible worknode1 -m shell -a "sudo systemctl status apache2"
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see details
worknode1 | CHANGED | rc=0 >>
● apache2.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/apache2.service; enabled; preset: enabled)
     Active: active (running) since Sun 2026-04-12 16:23:46 IST; 8min ago
       Docs: https://httpd.apache.org/docs/2.4/
    Process: 14010 ExecStart=/usr/sbin/apachectl start (code=exited, status=0/SUCCESS)
   Main PID: 14013 (apache2)
      Tasks: 55 (limit: 1004)
     Memory: 5.3M (peak: 5.6M)
        CPU: 54ms
     CGroup: /system.slice/apache2.service
             ├─14013 /usr/sbin/apache2 -k start
             ├─14015 /usr/sbin/apache2 -k start
             └─14016 /usr/sbin/apache2 -k start

Apr 12 16:23:46 ip-172-31-41-192 systemd[1]: Starting apache2.service - The Apache HTTP Server...
Apr 12 16:23:46 ip-172-31-41-192 systemd[1]: Started apache2.service - The Apache HTTP Server.
```

similarly the mysqp client is installed in master group only

```sh
ubuntu@ip-172-31-33-176:~/ansible-practice$ ansible worknode1 -m shell -a "mysql --version"
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to
see details
worknode1 | FAILED | rc=127 >>
/bin/sh: 1: mysql: not foundnon-zero return code
ubuntu@ip-172-31-33-176:~/ansible-practice$ mysql --version
mysql  Ver 8.0.45-0ubuntu0.24.04.1 for Linux on x86_64 ((Ubuntu))

```