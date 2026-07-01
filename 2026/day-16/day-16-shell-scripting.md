# Day 16 – Shell Scripting Basics

## Task 1: Your First Script

1. Create a file hello.sh
2. Add the shebang line #!/bin/bash at the top
3. Print Hello, DevOps! using echo
4. Make it executable and run it
chmod +x hello.sh
./hello.sh

```bash
aishuser@aish-ubuntu-tws:~/Shellscript$ cat hello.sh 
#!/bin/bash

echo "Hello, DevOps!"
aishuser@aish-ubuntu-tws:~/Shellscript$ ls -lrta
total 12
-rw-rw-r--  1 aishuser aishuser   36 Jul  1 14:26 hello.sh
drwxr-x--- 21 aishuser aishuser 4096 Jul  1 14:26 ..
drwxrwxr-x  2 aishuser aishuser 4096 Jul  1 14:26 .
aishuser@aish-ubuntu-tws:~/Shellscript$ chmod 777 hello.sh 
aishuser@aish-ubuntu-tws:~/Shellscript$ ls -lrta
total 12
-rwxrwxrwx  1 aishuser aishuser   24 Jul  1 14:27 hello.sh
drwxr-x--- 21 aishuser aishuser 4096 Jul  1 14:27 ..
drwxrwxr-x  2 aishuser aishuser 4096 Jul  1 14:27 .
aishuser@aish-ubuntu-tws:~/Shellscript$ ./hello.sh 
Hello, DevOps!

aishuser@aish-ubuntu-tws:~/Shellscript$ vim hello.sh 
aishuser@aish-ubuntu-tws:~/Shellscript$ cat hello.sh 

echo "Hello, DevOps!"

aishuser@aish-ubuntu-tws:~/Shellscript$ ./hello.sh 
Hello, DevOps!

```

### Document: What happens if you remove the shebang line?

- It attempts to execute the code using your default parent shell.

#### Note
- To find the shell you have on the default environment you can check the value of the SHELL environment variable:

echo $SHELL

- To find the current shell
echo $0

- To find the current shell instance, look for the process (shell) having the PID of the current shell instance.

To find the PID of the current instance of shell:

echo "$$"

- Now to find the process having the PID:

ps -p <PID>
Putting it together:

ps -p "$$" 

## Task 2: Variables

1. Create variables.sh with:
    a. A variable for your NAME
    b. A variable for your ROLE (e.g., "DevOps Engineer")
    c. Print: Hello, I am <NAME> and I am a <ROLE>
```bash
aishuser@aish-ubuntu-tws:~/Shellscript$ cat vriables.sh 
echo "what is your: name"
read name

echo "what is your: role"
read role

echo "Hello, I am $name and I am a $role"

aishuser@aish-ubuntu-tws:~/Shellscript$ ./vriables.sh 
what is your: name
Aish
what is your: role
DevOps engineer
Hello, I am Aish and I am a DevOps engineer
```
Or
```bash
aishuser@aish-ubuntu-tws:~/Shellscript$ cat variables.sh 
Name="Aish"
Role="Devloper"

echo "Hello, I am $Name and I am a $Role"

aishuser@aish-ubuntu-tws:~/Shellscript$ chmod +x variables.sh 
aishuser@aish-ubuntu-tws:~/Shellscript$ ./variables.sh 
Hello, I am Aish and I am a Devloper
```

2. Try using single quotes vs double quotes — what's the difference?
```bash
aishuser@aish-ubuntu-tws:~/Shellscript$ cat variables.sh 
Name="Aish"
Role="Devloper"

echo 'Hello, I am $Name and I am a $Role'
aishuser@aish-ubuntu-tws:~/Shellscript$ ./variables.sh 
Hello, I am $Name and I am a $Role
```

- Variables are not expanded.
- Everything inside single quotes is treated as literal text.

#### Note:
*** Use double quotes when you want Bash to substitute variables. Use single quotes when you want the text to be treated exactly as written. ***

## Task 3: User Input with read
1. Create greet.sh that:
2. Asks the user for their name using read
3. Asks for their favourite tool
4. Prints: Hello <name>, your favourite tool is <tool>
```bash
aishuser@aish-ubuntu-tws:~/Shellscript$ cat greet.sh 
echo "what is your: name"
read name

echo "what is your: favourite tool"
read tool

echo "Hello $name, your favourite tool is $tool"

aishuser@aish-ubuntu-tws:~/Shellscript$ ./greet.sh 
what is your: name
Aish
what is your: favourite tool
Ansible
Hello Aish, your favourite tool is Ansible
```

## Task 4: If-Else Conditions
1. Create check_number.sh that:

* Takes a number using read
* Prints whether it is positive, negative, or zero

```bash
read -p "Enter a number: " num

if [ "$num" -gt 0 ]
then 
        echo "$num is a positive number"
elif [ "$num" -lt 0 ]
then 
        echo "$num is a negative number"

else
        echo "$num is zero"

fi

aishuser@aish-ubuntu-tws:~/Shellscript$ ./check_number.sh 
Enter a number: 0
0 is zero
aishuser@aish-ubuntu-tws:~/Shellscript$ ./check_number.sh 
Enter a number: 4
4 is a positive number
aishuser@aish-ubuntu-tws:~/Shellscript$ ./check_number.sh 
Enter a number: -5
-5 is a negative number
```

2. Create file_check.sh that:

* Asks for a filename
* Checks if the file exists using -f
* Prints appropriate message

```bash
aishuser@aish-ubuntu-tws:~/Shellscript$ cat file_check.sh 
read -p "Enter the filename: " file
if [ -f "$file" ]
then 
        echo "file exists"
else 
        echo "file does not exist"
fi

aishuser@aish-ubuntu-tws:~/Shellscript$ ./file_check.sh 
Enter the filename: hello.sh
file exists
aishuser@aish-ubuntu-tws:~/Shellscript$ ./file_check.sh 
Enter the filename: 1.sh
file does not exist
```

## Task 5: Combine It All
Create server_check.sh that:

1. Stores a service name in a variable (e.g., nginx, sshd)
2. Asks the user: "Do you want to check the status? (y/n)"
3. If y — runs systemctl status <service> and prints whether it's active or not
4. If n — prints "Skipped."

```bash
aishuser@aish-ubuntu-tws:~/Shellscript$ cat server_check.sh 
read -p "Which service: " service
read -p "Do you want to check the status: " status
if [ "$status" == "y" ]
then 
        systemctl status $service
else 
        echo "skipped"
fi

aishuser@aish-ubuntu-tws:~/Shellscript$ chmod +x server_check.sh 
aishuser@aish-ubuntu-tws:~/Shellscript$ ./server_check.sh 
Which service: nginx
Do you want to check the status: y
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; preset: enabled)
     Active: active (running) since Wed 2026-07-01 12:51:11 UTC; 3h 30min ago
---
aishuser@aish-ubuntu-tws:~/Shellscript$ ./server_check.sh 
Which service: nginx
Do you want to check the status: n
skipped
```

