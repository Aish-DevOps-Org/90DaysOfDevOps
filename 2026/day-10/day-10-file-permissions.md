# Day 10 – File Permissions & File Operations Challenge

## Task 1: Create Files

```sh
aishuser@aish-ubuntu-tws:~/day10$ touch devops.txt
aishuser@aish-ubuntu-tws:~/day10$ touch notes.txt
aishuser@aish-ubuntu-tws:~/day10$ echo "my notes" >> notes.txt 
aishuser@aish-ubuntu-tws:~/day10$ cat notes.txt 
my notes
aishuser@aish-ubuntu-tws:~/day10$ vim scripts.sh
aishuser@aish-ubuntu-tws:~/day10$ ls -l
total 8
-rw-rw-r-- 1 aishuser aishuser  0 Apr 30 18:12 devops.txt
-rw-rw-r-- 1 aishuser aishuser  9 Apr 30 18:12 notes.txt
-rw-rw-r-- 1 aishuser aishuser 20 Apr 30 18:13 scripts.sh

```

## Task 2: Read Files

```sh
aishuser@aish-ubuntu-tws:~/day10$ head -n 5 /etc/passwd
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
---
aishuser@aish-ubuntu-tws:~/day10$ tail -n 5 /etc/passwd
dnsmasq:x:997:65534:dnsmasq:/var/lib/misc:/usr/sbin/nologin
tokyo:x:1001:1001::/home/tokyo:/bin/sh
berlin:x:1002:1002::/home/berlin:/bin/sh
professor:x:1003:1003::/home/professor:/bin/sh
nairobi:x:1004:1006::/home/nairobi:/bin/sh
```

## Task 3: Understand Permissions

Format: rwxrwxrwx (owner-group-others)

r = read (4), w = write (2), x = execute (1)

```sh
aishuser@aish-ubuntu-tws:~/day10$ ls -l
total 8
-rw-rw-r-- 1 aishuser aishuser  0 Apr 30 18:12 devops.txt
-rw-rw-r-- 1 aishuser aishuser  9 Apr 30 18:12 notes.txt
-rw-rw-r-- 1 aishuser aishuser 20 Apr 30 18:13 scripts.sh
```

Owner and group can read and write
others can oly read
noone can execute

## Task 4: Modify Permissions

Make script.sh executable → run it with ./script.sh

```sh
aishuser@aish-ubuntu-tws:~/day10$ ./scripts.sh
-bash: ./scripts.sh: Permission denied
aishuser@aish-ubuntu-tws:~/day10$ chmod 755 scripts.sh 
aishuser@aish-ubuntu-tws:~/day10$ ./scripts.sh
Hello DevOps
aishuser@aish-ubuntu-tws:~/day10$ ls -l scripts.sh
-rwxr-xr-x 1 aishuser aishuser 20 Apr 30 18:13 scripts.sh
```

Set devops.txt to read-only (remove write for all)

```sh
aishuser@aish-ubuntu-tws:~/day10$ ls -l devops.txt
-rw-rw-r-- 1 aishuser aishuser 0 Apr 30 18:12 devops.txt
aishuser@aish-ubuntu-tws:~/day10$ chmod -w devops.txt
aishuser@aish-ubuntu-tws:~/day10$ ls -l devops.txt
-r--r--r-- 1 aishuser aishuser 0 Apr 30 18:12 devops.txt
aishuser@aish-ubuntu-tws:~/day10$ echo "add line " >> devops.txt 
-bash: devops.txt: Permission denied
```

Set notes.txt to 640 (owner: rw, group: r, others: none)

```sh
aishuser@aish-ubuntu-tws:~/day10$ ls -l notes.txt 
-rw-rw-r-- 1 aishuser aishuser 9 Apr 30 18:12 notes.txt
aishuser@aish-ubuntu-tws:~/day10$ chmod 640 notes.txt 
aishuser@aish-ubuntu-tws:~/day10$ ls -l notes.txt 
-rw-r----- 1 aishuser aishuser 9 Apr 30 18:12 notes.txt
```

Create directory project/ with permissions 755

```sh
aishuser@aish-ubuntu-tws:~/day10$ mkdir project && chmod 755 project
aishuser@aish-ubuntu-tws:~/day10$ ls -l
drwxr-xr-x 2 aishuser aishuser 4096 Apr 30 18:25 project
```

## Task 5: Test Permissions

```sh
Try writing to a read-only file - what happens?
> it gives error -

-bash: devops.txt: Permission denied

Try executing a file without execute permission
> -bash: ./scripts.sh: Permission denied

```