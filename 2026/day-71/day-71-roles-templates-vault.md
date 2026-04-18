# Day 71 -- Roles, Galaxy, Templates and Vault

## Task 1: Jinja2 Templates

Result: ansible-playbook template-demo.yml --diff

```sh
ubuntu@ip-172-31-2-74:~/ansible-practice$ ansible-playbook template-demo.yml --diff

PLAY [Deploy Nginx with template] **********************************************

TASK [Gathering Facts] *********************************************************
ok: [workernode1]

TASK [Install Nginx] ***********************************************************
The following additional packages will be installed:
  nginx-common
Suggested packages:
  fcgiwrap nginx-doc ssl-cert
The following NEW packages will be installed:
  nginx nginx-common
0 upgraded, 2 newly installed, 0 to remove and 0 not upgraded.
changed: [workernode1]

TASK [Create web root] *********************************************************
--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/var/www/terraweek-app",

- "state": "absent"

+ "state": "directory"
 }

changed: [workernode1]

TASK [Deploy vhost config from template] ***************************************
--- before
+++ after: /home/ubuntu/.ansible/tmp/ansible-local-13412r1vapbpj/tmpnei1981j/nginx-vhost.conf.j2
@@ -0,0 +1,17 @@
+# Managed by Ansible -- do not edit manually
+server {
- listen 80;
- server_name ip-172-31-4-173;
-
- root /var/www/terraweek-app;
- index index.html;
-
- location / {
-        try_files $uri $uri/ =404;
- }
-
- access_log /var/log/nginx/terraweek-app_access.log;
- error_log /var/log/nginx/terraweek-app_error.log;
+}
-
-

changed: [workernode1]

TASK [Deploy index page] *******************************************************
--- before
+++ after: /var/www/terraweek-app/index.html
@@ -0,0 +1 @@
+<h1>terraweek-app</h1><p>Host: ip-172-31-4-173 | IP: 172.31.4.173</p>
\ No newline at end of file

changed: [workernode1]

RUNNING HANDLER [Restart Nginx] ************************************************
changed: [workernode1]

PLAY RECAP *********************************************************************
workernode1                : ok=6    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

```sh
ubuntu@ip-172-31-4-173:/var/www$ ls terraweek-app/
index.html
ubuntu@ip-172-31-4-173:/var/www$ cat terraweek-app/index.html 
<h1>terraweek-app</h1><p>Host: ip-172-31-4-173 | IP: 172.31.4.173</p>ubuntu@ip-172-31-4-173:/var/www$ 

------- The config file --------
ubuntu@ip-172-31-4-173:/etc/nginx/conf.d$ cat terraweek-app.conf 
# Managed by Ansible -- do not edit manually
server {
    listen 80;
    server_name ip-172-31-4-173;

    root /var/www/terraweek-app;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    access_log /var/log/nginx/terraweek-app_access.log;
    error_log /var/log/nginx/terraweek-app_error.log;
}

```

## Task 2: Understand the Role Structure

```sh
ubuntu@ip-172-31-2-74:~/roles$ tree webserver/
webserver/
├── README.md
├── defaults
│   └── main.yml
├── files
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── tasks
│   └── main.yml
├── templates
├── tests
│   ├── inventory
│   └── test.yml
└── vars
    └── main.yml

9 directories, 8 files
```

What is the difference between vars/main.yml and defaults/main.yml?
Both are variable files but vars takes precedence over defaults.

## Task 3: Build a Custom Webserver Role

```sh
ubuntu@ip-172-31-15-202:~/ansible-practice$ ansible-playbook sites.yml 

PLAY [configure web servers] ***************************************************

TASK [Gathering Facts] *********************************************************
ok: [workernode1]

TASK [webserver : Install Nginx] ***********************************************
ok: [workernode1]

TASK [webserver : Deploy Nginx config] *****************************************
changed: [workernode1]

TASK [webserver : Deploy vhost config] *****************************************
ok: [workernode1]

TASK [webserver : Create web root] *********************************************
ok: [workernode1]

TASK [webserver : Deploy index page] *******************************************
ok: [workernode1]

TASK [webserver : Start and enable Nginx] **************************************
changed: [workernode1]

RUNNING HANDLER [webserver : Restart Nginx] ************************************
changed: [workernode1]

PLAY RECAP *********************************************************************
workernode1                : ok=8    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

```html
ubuntu@ip-172-31-15-202:~/ansible-practice$ curl 54.202.61.32
<h1>terraweek</h1>
<p>Server: ip-172-31-7-67</p>
<p>IP: 172.31.7.67</p>
<p>Environment: development</p>
<p>Managed by Ansible</p>
```

## Task 4: Ansible Galaxy -- Use Community Roles

Search for community roles

```sh
ubuntu@ip-172-31-15-202:~/ansible-practice$ ansible-galaxy search mysql

Found 686 roles matching your search:

 Name                                                       Description
 ----                                                       -----------
 0amalpartida0.ansible_role_mysql57                         install mysql community 5.7
 tenequm.mysql                                              Simply installs MySQL 5.7 on Xenia>
 4linuxdevops.mysql-server                                  Instalacao e Configuracao do servi>
 4linuxhd.mysql_server
```

```sh
Found 686 roles matching your search:

 Name                                                       Description
 ----                                                       -----------
 0amalpartida0.ansible_role_mysql57                         install mysql community 5.7
 tenequm.mysql                                              Simply installs MySQL 5.7 on Xenia>
 4linuxdevops.mysql-server                                  Instalacao e Configuracao do servi>
 4linuxhd.mysql_server
```

Install a community role and run the playbook using that role

```sh
ubuntu@ip-172-31-15-202:~/ansible-practice$ ansible-playbook docker-setup.yml 
 
PLAY [Install Docker using Galaxy role] ****************************************

TASK [Gathering Facts] *********************************************************
ok: [workernode2]

TASK [geerlingguy.docker : Load OS-specific vars.] *****************************
ok: [workernode2]

TASK [geerlingguy.docker : include_tasks] **************************************
skipping: [workernode2]

TASK [geerlingguy.docker : include_tasks] **************************************
skipping: [workernode2]

TASK [geerlingguy.docker : include_tasks] **************************************
included: /home/ubuntu/.ansible/roles/geerlingguy.docker/tasks/setup-Debian.yml for workernode2

TASK [geerlingguy.docker : Ensure apt key is not present in trusted.gpg.d] *****
ok: [workernode2]

TASK [geerlingguy.docker : Ensure old apt source list is not present in /etc/apt/sources.list.d] ***
ok: [workernode2]

TASK [geerlingguy.docker : Ensure old versions of Docker are not installed.] ***
ok: [workernode2]

TASK [geerlingguy.docker : Ensure legacy repo file is not present.] ************
ok: [workernode2]

TASK [geerlingguy.docker : Ensure dependencies are installed.] *****************
ok: [workernode2]

TASK [geerlingguy.docker : Add or remove Docker repository.] *******************
changed: [workernode2]

TASK [geerlingguy.docker : Ensure handlers are notified immediately to update the apt cache.] ***

RUNNING HANDLER [geerlingguy.docker : apt update] ******************************
changed: [workernode2]

TASK [geerlingguy.docker : Install Docker packages.] ***************************
skipping: [workernode2]

TASK [geerlingguy.docker : Install Docker packages (with downgrade option).] ***
changed: [workernode2]

TASK [geerlingguy.docker : Install docker-compose plugin.] *********************
skipping: [workernode2]

TASK [geerlingguy.docker : Install docker-compose-plugin (with downgrade option).] ***
ok: [workernode2]

TASK [geerlingguy.docker : Ensure /etc/docker/ directory exists.] **************
skipping: [workernode2]

TASK [geerlingguy.docker : Configure Docker daemon options.] *******************
skipping: [workernode2]

TASK [geerlingguy.docker : Get Docker service status] **************************
skipping: [workernode2]

TASK [geerlingguy.docker : Patch docker.service] *******************************
skipping: [workernode2]

TASK [geerlingguy.docker : Reload systemd services] ****************************
skipping: [workernode2]

TASK [geerlingguy.docker : Ensure Docker is started and enabled at boot.] ******
ok: [workernode2]

TASK [geerlingguy.docker : Ensure handlers are notified now to avoid firewall conflicts.] ***

RUNNING HANDLER [geerlingguy.docker : restart docker] **************************
changed: [workernode2]

TASK [geerlingguy.docker : include_tasks] **************************************
skipping: [workernode2]

TASK [geerlingguy.docker : Get docker group info using getent.] ****************
skipping: [workernode2]

TASK [geerlingguy.docker : Check if there are any users to add to the docker group.] ***
skipping: [workernode2]

TASK [geerlingguy.docker : include_tasks] **************************************
skipping: [workernode2]

PLAY RECAP *********************************************************************
workernode2                : ok=14   changed=4    unreachable=0    failed=0    skipped=13   rescued=0    ignored=0
```

docker is installed now

```sh
ubuntu@ip-172-31-15-202:~/ansible-practice$ ansible workernode2 -m command -a "docker --version"
workernode2 | CHANGED | rc=0 >>
Docker version 29.4.0, build 9d7ad9f
```

## Task 5: Ansible Vault -- Encrypt Secrets

```sh
ansible-practice$ cat group_vars/db/vault.yml 
$ANSIBLE_VAULT;1.1;AES256
38643462653837666363346563326532383964633166356439353861613236393236656636633533
6631343463663135303765613761313766653038323830340a333333643635393139336339666431
62656165623038356236333363336639366338663961343530656633363534396339626635643162
3462633331643237660a343139303738383762336466373838343934326131393832616666386665
32373232363864346665366162613361343136333836656563646432663339616635393633313063
37636233613861616332626466356666333265646364613164336365633664373732363934353434
36393836336662633165626131643433376661333266363963643233353336626466376539323662
66353433393139373431396136356666376239663835663065653061323137373362386537316665
39333937333930666262383866323132646537666232613666393831373637666539
ubuntu@ip-172-31-15-202:~/ansible-practice$

```

Encrypt existing file

```sh
ubuntu@ip-172-31-15-202:~/ansible-practice$ cat group_vars/db/secrets.ym
vault_db_password: SuperSecretP@ssw0rd
vault_db_root_password: R00tP@ssw0rd123
vault_api_key: sk-abc123xyz789

ubuntu@ip-172-31-15-202:~/ansible-practice$ ansible-vault encrypt group_vars/db/secrets.yml
New Vault password: 
Confirm New Vault password: 
Encryption successful
ubuntu@ip-172-31-15-202:~/ansible-practice$ cat group_vars/db/secrets.yml
$ANSIBLE_VAULT;1.1;AES256
34333038386235613231323430303032363562353832363238613661376631656330383432656362
6534663335666464643037323039306666383831626462320a323462373234663764343930333437
30336134333731636130623861663364653836383561376635326530353466316534383432656161
3636343739346237360a393666623164313237396132616232383231663839633431346630376230
33316533383732343364373738316163626537346237323034326637636361646333313061333039
38393030393636316638323932396434323138323037313564633237373363376332303262323531
39363336393937633233646664653333613366636263383730353535653337353635646438366334
61343130303766383661353535343264373738336630666665656166313335306232356562653263
31363038313462363263356661356661303639663538396264613264393039353035
```

Use password file

```sh
ubuntu@ip-172-31-15-202:~/ansible-practice$ echo "YourVaultPassword" > .vault_pass
ubuntu@ip-172-31-15-202:~/ansible-practice$ chmod 600 .vault_pass
ubuntu@ip-172-31-15-202:~/ansible-practice$ echo ".vault_pass" >> .gitignore
ubuntu@ip-172-31-15-202:~/ansible-practice$ ansible-playbook db-setup.yml --vault-password-file .vault_pass

PLAY [Configure database] ******************************************************
ERROR! Decryption failed (no vault secrets were found that could decrypt) on /home/ubuntu/ansible-practice/group_vars/db/secrets.yml
ubuntu@ip-172-31-15-202:~/ansible-practice$ vim .vault_pass 
ubuntu@ip-172-31-15-202:~/ansible-practice$ ansible-playbook db-setup.yml --vault-password-file .vault_pass

PLAY [Configure database] ******************************************************

TASK [Gathering Facts] *********************************************************
ok: [localhost]

TASK [Show DB password (never do this in production)] **************************
ok: [localhost] => {
    "msg": "DB password is set: True"
}

PLAY RECAP *********************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  

```

Add the vault pass file in the ansible.cfg

```sh
ubuntu@ip-172-31-15-202:~/ansible-practice$ vim ansible.cfg 
ubuntu@ip-172-31-15-202:~/ansible-practice$ ansible-playbook db-setup.yml

PLAY [Configure database] ******************************************************

TASK [Gathering Facts] *********************************************************
ok: [localhost]

TASK [Show DB password (never do this in production)] **************************
ok: [localhost] => {
    "msg": "DB password is set: True"
}

PLAY RECAP *********************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

### Why is --vault-password-file better than --ask-vault-pass for automated pipelines

Because, --ash-vault-pass needs manual intervention. Pipeline is automated and it will get stuck during this step as it is not interactive. So passing the password with file will not interrupt it's automated flow.

## Task 6: Combine Roles, Templates, and Vault

```sh
ubuntu@ip-172-31-15-202:/etc$ sudo cat db-config.env 
# Database Configuration -- Managed by Ansible
DB_HOST=172.31.15.202
DB_PORT=3306
DB_PASSWORD=SuperSecretP@ssw0rd
DB_ROOT_PASSWORD=R00tP@ssw0rd123

ubuntu@ip-172-31-15-202:/etc$ ls -lrta db-config.env
-rw------- 1 root root 147 Apr 18 13:13 db-config.env
```