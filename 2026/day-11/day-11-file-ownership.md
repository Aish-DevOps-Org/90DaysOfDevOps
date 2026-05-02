# Day 11 – File Ownership Challenge (chown & chgrp)

## Task 1: Understanding Ownership

Run ls -l in your home directory
Identify the owner and group columns
Check who owns your files
Format: -rw-r--r-- 1 owner group size date filename

```sh
aishuser@aish-ubuntu-tws:~/day10$ ls -l
total 12
-r--r--r-- 1 aishuser aishuser    0 Apr 30 18:12 devops.txt
-rw-r----- 1 aishuser aishuser    9 Apr 30 18:12 notes.txt
```

Owner - aishuser -> User
group - aishuser -> group of users

## Task 2: Basic chown Operations

Create file devops-file.txt
Check current owner: ls -l devops-file.txt
Change owner to tokyo (create user if needed)
Change owner to berlin
Verify the changes

```sh
aishuser@aish-ubuntu-tws:~/day11$ touch devops-file.txt
aishuser@aish-ubuntu-tws:~/day11$ ls -l
total 0
-rw-rw-r-- 1 aishuser aishuser 0 Apr 30 18:40 devops-file.txt

 
aishuser@aish-ubuntu-tws:~/day11$ sudo chown tokyo devops-file.txt
 
aishuser@aish-ubuntu-tws:~/day11$ ls -l
total 0
-rw-rw-r-- 1 tokyo aishuser 0 Apr 30 18:40 devops-file.txt

aishuser@aish-ubuntu-tws:~/day11$ sudo chown berlin devops-file.tx
t 
aishuser@aish-ubuntu-tws:~/day11$ ls -l
total 0
-rw-rw-r-- 1 berlin aishuser 0 Apr 30 18:40 devops-file.txt
```

## Task 3: Basic chgrp Operations

Create file team-notes.txt
Check current group: ls -l team-notes.txt
Create group: sudo groupadd heist-team
Change file group to heist-team
Verify the change

```sh
aishuser@aish-ubuntu-tws:~/day11$ touch team-notes.txt
aishuser@aish-ubuntu-tws:~/day11$ ls -l team-notes.txt 

-rw-rw-r-- 1 aishuser aishuser 0 Apr 30 18:44 team-notes.txt

aishuser@aish-ubuntu-tws:~/day11$ sudo groupadd heist-team
aishuser@aish-ubuntu-tws:~/day11$ sudo chgrp heist-team team-notes.txt 

aishuser@aish-ubuntu-tws:~/day11$ ls -l team-notes.txt 
-rw-rw-r-- 1 aishuser heist-team 0 Apr 30 18:44 team-notes.txt
```

## Task 4: Combined Owner & Group Change

Create file project-config.yaml
Change owner to professor AND group to heist-team (one command)
Create directory app-logs/
Change its owner to berlin and group to heist-team
Syntax: sudo chown owner:group filename

```sh
aishuser@aish-ubuntu-tws:~/day11$ touch project-config.yaml
aishuser@aish-ubuntu-tws:~/day11$ sudo chown professor:heist-team project-config.yaml 
aishuser@aish-ubuntu-tws:~/day11$ ls -l project-config.yaml 
-rw-rw-r-- 1 professor heist-team 0 Apr 30 18:46 project-config.yaml

aishuser@aish-ubuntu-tws:~/day11$ mkdir app-logs
aishuser@aish-ubuntu-tws:~/day11$ sudo chown berlin:heist-team app-logs/
aishuser@aish-ubuntu-tws:~/day11$ ls -l
total 4
drwxrwxr-x 2 berlin    heist-team 4096 Apr 30 18:47 app-logs
```

## Task 5: Recursive Ownership

Create directory structure

```sh
aishuser@aish-ubuntu-tws:~/day11$ tree heist-project/
heist-project/
├── plans
│   └── strategy.conf
└── vault
    └── gold.txt

3 directories, 2 files
```

Change ownership of entire heist-project/ directory:
Owner: professor
Group: planners
Use recursive flag (-R)
Verify all files and subdirectories changed: ls -lR heist-project/

```sh
drwxrwxr-x 4 aishuser  aishuser   4096 Apr 30 18:50 heist-project

aishuser@aish-ubuntu-tws:~/day11$ sudo chown professor:planners -R heist-p
roject/

drwxrwxr-x 4 professor planners   4096 Apr 30 18:50 heist-project

aishuser@aish-ubuntu-tws:~/day11/heist-project$ ls -l
total 8
drwxrwxr-x 2 professor planners 4096 Apr 30 18:50 plans
drwxrwxr-x 2 professor planners 4096 Apr 30 18:50 vault

aishuser@aish-ubuntu-tws:~/day11/heist-project$ ls -l plans/
total 0
-rw-rw-r-- 1 professor planners 0 Apr 30 18:50 strategy.conf

aishuser@aish-ubuntu-tws:~/day11/heist-project$ ls -l vault/
total 0
-rw-rw-r-- 1 professor planners 0 Apr 30 18:50 gold.txt
```

## Task 6: Practice Challenge

Create groups: vault-team, tech-team

```sh
aishuser@aish-ubuntu-tws:~/day11$ sudo groupadd vault-team
aishuser@aish-ubuntu-tws:~/day11$ sudo groupadd tech-team
```

Create directory: bank-heist/
Create 3 files inside:
touch bank-heist/access-codes.txt
touch bank-heist/blueprints.pdf
touch bank-heist/escape-plan.txt

```sh
aishuser@aish-ubuntu-tws:~/day11$ tree bank-heist/
bank-heist/
├── access-codes.txt
├── blueprints.pdf
└── escape-plan.txt

1 directory, 3 files
```

Set different ownership:
access-codes.txt → owner: tokyo, group: vault-team
blueprints.pdf → owner: berlin, group: tech-team
escape-plan.txt → owner: nairobi, group: vault-team
Verify: ls -l bank-heist/

```sh
aishuser@aish-ubuntu-tws:~/day11/bank-heist$ sudo chown tokyo:vault-team access-codes.txt 
aishuser@aish-ubuntu-tws:~/day11/bank-heist$ sudo chown berlin:tech-team blueprints.pdf 
aishuser@aish-ubuntu-tws:~/day11/bank-heist$ sudo chown nairobi:vault-team escape-plan.txt 
aishuser@aish-ubuntu-tws:~/day11/bank-heist$ ls -l
total 0
-rw-rw-r-- 1 tokyo   vault-team 0 May  2 17:00 access-codes.txt
-rw-rw-r-- 1 berlin  tech-team  0 May  2 17:00 blueprints.pdf
-rw-rw-r-- 1 nairobi vault-team 0 May  2 17:00 escape-plan.txt
```

## Key Commands Reference

```sh
# View ownership
ls -l filename

# Change owner only
sudo chown newowner filename

# Change group only
sudo chgrp newgroup filename

# Change both owner and group
sudo chown owner:group filename

# Recursive change (directories)
sudo chown -R owner:group directory/

# Change only group with chown
sudo chown :groupname filename

# list all usernames
compgen -u

# list all groups
compgen -g
```