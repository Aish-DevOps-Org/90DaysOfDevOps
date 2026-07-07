# Day 17 – Shell Scripting: Loops, Arguments & Error Handling

## Task 1: For Loop
1. Create for_loop.sh that:
- Loops through a list of 5 fruits and prints each one
```bash
for fruits in apple, mango, bananan, kiwi, orange
        do 
                echo $fruits
        done

aishuser@aish-ubuntu-tws:~/Shellscript$ chmod +x for_loop.sh 
aishuser@aish-ubuntu-tws:~/Shellscript$ ./for_loop.sh 
apple,
mango,
bananan,
kiwi,
orange
```

2. Create count.sh that:
- Prints numbers 1 to 10 using a for loop
```bash
aishuser@aish-ubuntu-tws:~/Shellscript$ cat count.sh 
#!/bin/bash
for ((i=1; i<=10; i++))
do 
        echo "$i"
done

aishuser@aish-ubuntu-tws:~/Shellscript$ ./count.sh 
1
2
3
4
5
6
7
8
9
10
```

And
```bash
aishuser@aish-ubuntu-tws:~/Shellscript$ cat count2.sh 
#!/bin/bash
for i in {1..10}
do
    echo "$i"
done
```

## Task 2: While Loop
1. Create countdown.sh that:
- Takes a number from the user
- Counts down to 0 using a while loop
- Prints "Done!" at the end

```bash
aishuser@aish-ubuntu-tws:~/Shellscript$ cat countdown.sh 
#!/bin/bash

read -p "Choose a number: " n

while [ $n -ge 0 ]
do 
        echo "$n"
        n=$((n-1))
done
echo "Done!"

aishuser@aish-ubuntu-tws:~/Shellscript$ ./countdown.sh 
Choose a number: 5
5
4
3
2
1
0
Done!
```

## Task 3: Command-Line Arguments
1. Create greet.sh that:
- Accepts a name as $1
- Prints Hello, <name>!
- If no argument is passed, prints "Usage: ./greet.sh "

```bash
aishuser@aish-ubuntu-tws:~/Shellscript$ cat greet.sh 
#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: ./greet.sh <name>"
else
    echo "Hello, $1!"
fi
aishuser@aish-ubuntu-tws:~/Shellscript$ ./greet.sh
Usage: ./greet.sh <name>
aishuser@aish-ubuntu-tws:~/Shellscript$ ./greet.sh aish
Hello, aish!
```

**Note:**
-z = string length is zero (empty)
If no argument is passed, $1 is empty
-n = string length is non-zero

2. Create args_demo.sh that:

- Prints total number of arguments ($#)
- Prints all arguments ($@)
- Prints the script name ($0)

```bash
aishuser@aish-ubuntu-tws:~/Shellscript$ cat args_demo.sh 
#!/bin/bash

echo "Total number of arguments: $#"
echo "All arguments: $@"
echo "The script name is: $0"
aishuser@aish-ubuntu-tws:~/Shellscript$ chmod +x args_demo.sh
aishuser@aish-ubuntu-tws:~/Shellscript$ ./args_demo.sh Aish demo script arguments
Total number of arguments: 4
All arguments: Aish demo script arguments
The script name is: ./args_demo.sh
```

## Task 4: Install Packages via Script
1. Create install_packages.sh that:
- Defines a list of packages: nginx, curl, wget
- Loops through the list
- Checks if each package is installed (use dpkg -s or rpm -q)
- Installs it if missing, skips if already present
- Prints status for each package
> Run as root: sudo -i or sudo su

```bash
#!/bin/bash

for pkg in nginx curl wget
do 
       if dpkg -s $pkg >/dev/null 2>&1
        then 
                echo "$pkg already installed, skipping..."

        else
                echo "installing $pkg..."
                sudo apt install -y $pkg
fi
done
```

## Task 5: Error Handling
1. Create safe_script.sh that:
- Uses set -e at the top (exit on error)
- Tries to create a directory /tmp/devops-test
- Tries to navigate into it
- Creates a file inside
- Uses || operator to print an error if any step fails

Example:
> mkdir /tmp/devops-test || echo "Directory already exists"

```bash
#!/bin/bash
set -e
mkdir /tmp/devops-test && cd /tmp/devops-test && touch file.txt || echo "Already exists"

aishuser@aish-ubuntu-tws:/tmp$ tree devops-test2/
devops-test2/
└── file.txt

1 directory, 1 file
aishuser@aish-ubuntu-tws:~/Shellscript$ ./safe_script.sh 
mkdir: cannot create directory ‘/tmp/devops-test2’: File exists
Already exists

```

2. Modify your install_packages.sh to check if the script is being run as root — exit with a message if not.

```bash
aishuser@aish-ubuntu-tws:~/Shellscript$ cat install_packages.sh 
#!/bin/bash

if [ "$EUID" == 0 ]
then 
        echo "running as root"
else
        echo "not running as root"
        exit 1

fi

for pkg in nginx curl wget
do 
        if dpkg -s $pkg >/dev/null 2>&1
then 
        echo "$pkg already installed, skipping..."

else
        echo "installing $pkg..."
        sudo apt install -y $pkg
fi
done

aishuser@aish-ubuntu-tws:~/Shellscript$ ./install_packages.sh 
not running as root
aishuser@aish-ubuntu-tws:~/Shellscript$ sudo ./install_packages.sh 
running as root
nginx already installed, skipping...
curl already installed, skipping...
wget already installed, skipping..
```
