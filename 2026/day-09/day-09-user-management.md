# Day 09 – Linux User & Group Management Challenge

## Task 1: Create Users

tokyo
berlin
professor

```sh
aishuser@aish-ubuntu-tws:~$ sudo useradd -m tokyo
aishuser@aish-ubuntu-tws:~$ sudo passwd tokyo
New password: 
Retype new password: 
passwd: password updated successfully
aishuser@aish-ubuntu-tws:/home$ ls
aishuser  berlin  professor  tokyo
aishuser@aish-ubuntu-tws:/home$
```

## Task 2: Create Groups

```sh
aishuser@aish-ubuntu-tws:/etc$ sudo groupadd developers
aishuser@aish-ubuntu-tws:/etc$ sudo groupadd admins

aishuser@aish-ubuntu-tws:/etc$ cat group
tokyo:x:1001:
berlin:x:1002:
professor:x:1003:
developers:x:1004:tokyo
admins:x:1005:
```

## Task 3: Assign to Groups

```sh
aishuser@aish-ubuntu-tws:/etc$ sudo usermod -aG admins professor 
aishuser@aish-ubuntu-tws:/etc$ sudo usermod -aG admins,developers berlin
aishuser@aish-ubuntu-tws:/etc$ cat group
tokyo:x:1001:
berlin:x:1002:
professor:x:1003:
developers:x:1004:tokyo,berlin
admins:x:1005:professor,berlin

aishuser@aish-ubuntu-tws:/etc$ groups professor
professor : professor admins
aishuser@aish-ubuntu-tws:/etc$ groups tokyo
tokyo : tokyo developers
aishuser@aish-ubuntu-tws:/etc$ groups berlin
berlin : berlin developers admins
```

## Task 4: Shared Directory

```sh
aishuser@aish-ubuntu-tws:/opt$ ls -lrt
drwxr-xr-x 2 root root 4096 Apr 26 16:40 dev-project

aishuser@aish-ubuntu-tws:/opt$ sudo chgrp developers dev-project/

aishuser@aish-ubuntu-tws:/opt$ sudo chmod 775 dev-project/

aishuser@aish-ubuntu-tws:/opt$ ls -lrt
drwxrwxr-x 2 root developers 4096 Apr 26 16:40 dev-project
---

Verify

aishuser@aish-ubuntu-tws:/opt$ sudo -u tokyo touch dev-project/test
aishuser@aish-ubuntu-tws:/opt$ sudo -u berlin touch dev-project/test1
aishuser@aish-ubuntu-tws:/opt$ tree dev-project/
dev-project/
├── test
└── test1

1 directory, 2 files

aishuser@aish-ubuntu-tws:/opt$ sudo -u professor touch dev-project/test2
touch: cannot touch 'dev-project/test2': Permission denied
```

## Task 5: Team Workspace

Create user nairobi with home directory

```sh
aishuser@aish-ubuntu-tws:~$ sudo useradd nairobi
aishuser@aish-ubuntu-tws:~$ sudo passwd nairobi
New password: 
Retype new password: 
passwd: password updated successfully
aishuser@aish-ubuntu-tws:~$ ls /home/
aishuser  berlin  professor  tokyo

# Create home dir for user
aishuser@aish-ubuntu-tws:~$ sudo mkhomedir_helper nairobi 
aishuser@aish-ubuntu-tws:~$ ls /home/
aishuser  berlin  nairobi  professor  tokyo
aishuser@aish-ubuntu-tws:~$ 
```

Create group project-team

```sh
aishuser@aish-ubuntu-tws:~$ sudo groupadd project-team
```

Add nairobi and tokyo to project-team

```sh
aishuser@aish-ubuntu-tws:~$ sudo usermod -aG project-team nairobi
aishuser@aish-ubuntu-tws:~$ sudo usermod -aG project-team tokyo

aishuser@aish-ubuntu-tws:~$ groups nairobi
nairobi : nairobi project-team
```

Create /opt/team-workspace directory

```sh
aishuser@aish-ubuntu-tws:~$ sudo mkdir /opt/team-workspace
aishuser@aish-ubuntu-tws:~$ ls -lrt /opt
drwxr-xr-x 2 root root       4096 Apr 26 17:02 team-workspace
```

Set group to project-team, permissions to 775

```sh
aishuser@aish-ubuntu-tws:~$ sudo chgrp project-team /opt/team-workspace 
aishuser@aish-ubuntu-tws:~$ ls -lrt /opt/
drwxr-xr-x 2 root project-team 4096 Apr 26 17:02 team-workspace

aishuser@aish-ubuntu-tws:~$ sudo chmod 775 /opt/team-workspace
aishuser@aish-ubuntu-tws:~$ ls -lrt /opt/
drwxrwxr-x 2 root project-team 4096 Apr 26 17:02 team-workspace
```

Test by creating file as nairobi

```sh
aishuser@aish-ubuntu-tws:~$ ls -lrt /opt/team-workspace/
total 0
-rw-rw-r-- 1 nairobi nairobi 0 Apr 26 17:07 test
```

### Summary

User:

- useradd -m -> Create a user with how dir
- adduser -> Create user with home dir
- usermod -> modify a user account
- passwd -> Create passwd for user

Group:

- groupadd -> create group
- groups -> list groups, user is part of

Permissions:

- chgrp -> Change group owenership for a file/dir
- chmod -> change permission for a file/dir
- chown -> change file owner and group

### Tip

Use -m flag with useradd for home directory, -aG for adding to groups

Test: sudo -u username command
