# Day 18 – Shell Scripting: Functions & intermediate Concepts

## Task 1: Basic Functions
1. Create `functions.sh` with:
   - A function `greet` that takes a name as argument and prints `Hello, <name>!`
   - A function `add` that takes two numbers and prints their sum
   - Call both functions from the script

```bash
#/bin/bash
greet () {
    read -p "what is your name: " name
    echo "Hello, $name"
}

add () {
    read -p "Choose num1: " num1
    read -p "Choose num2: " num2
    echo "The sum of the numbers are: $(($num1 +$num2))"
}

greet
add

> output
aishuser@aish-ubuntu-tws:~/Shellscript$ ./functions.sh 
what is your name: aish
Hello, aish
Choose num1: 2
Choose num2: 3
The sum of the numbers are: 5
```
---

## Task 2: Functions with Return Values
1. Create `disk_check.sh` with:
   - A function `check_disk` that checks disk usage of `/` using `df -h`
   - A function `check_memory` that checks free memory using `free -h`
   - A main section that calls both and prints the results

```bash
#!/bin/bash
check_disk () {
    df -h /
}

check_memory () {
    free -h
}

echo "call the function: check_disk"
check_disk

echo "call the function: check_memory"
check_memory

> output
aishuser@aish-ubuntu-tws:~/Shellscript$ ./disk_check.sh 
call the function: check_disk
Filesystem      Size  Used Avail Use% Mounted on
/dev/root        29G   12G   17G  43% /
call the function: check_memory
               total        used        free      shared  buff/cache   available
Mem:           3.8Gi       808Mi       1.3Gi       4.0Mi       1.9Gi       3.0Gi
Swap:             0B          0B          0B
---

## Task 3: Strict Mode — `set -euo pipefail`
1. Create `strict_demo.sh` with `set -euo pipefail` at the top
2. Try using an **undefined variable** — what happens with `set -u`?
3. Try a command that **fails** — what happens with `set -e`?
4. Try a **piped command** where one part fails — what happens with `set -o pipefail`?

```bash
#!/bin/bash

set -euo pipefail

echo "Script started"

# 1. Undefined variable
echo $name

# 2. Failing command
ls /does/not/exist

# 3. Pipeline with a failing command
grep "hello" missing.txt | wc -l

echo "Script completed"

> output
for set -u
aishuser@aish-ubuntu-tws:~/Shellscript$ ./strict_demo.sh 
Script started
./strict_demo.sh: line 8: name: unbound variable

for set -e
aishuser@aish-ubuntu-tws:~/Shellscript$ ./strict_demo.sh 
Script started

ls: cannot access '/does/not/exist': No such file or directory

for set -o pipefail
aishuser@aish-ubuntu-tws:~/Shellscript$ ./strict_demo.sh 
Script started
grep: missing.txt: No such file or directory
0

> and without pipefail
aishuser@aish-ubuntu-tws:~/Shellscript$ ./strict_demo.sh 
Script started
grep: missing.txt: No such file or directory
0
Script completed

```
**Document:** What does each flag do?
- `set -e` → The script exits immediately after the failed command.
- `set -u` → The script stops immediately because name variable was never defined.
- `set -o pipefail` → if any command in the pipeline fails, make the whole pipeline fail and does not mean stop executing the rest of the pipeline.
- `set -e + set -o` → pipefail together ensure the script stops on pipeline failures.

---

## Task 4: Local Variables
1. Create `local_demo.sh` with:
   - A function that uses `local` keyword for variables
   - Show that `local` variables don't leak outside the function
   - Compare with a function that uses regular variables

Local variable
A local variable is a special type of variable which has its scope only within a specific function or block of code. Local variables can override the same variable name in the larger scope. 

```bash
#!/bin/bash
NUM=200 #Global variable

getNUM () {
    local NUM=100 #Local variable 
  
    echo "$NUM - Inside function"
}

echo "$NUM - outside function"

getNUM

echo "$NUM - After function call"
aishuser@aish-ubuntu-tws:~/Shellscript$ ./local_demo.sh 
200 - outside function
100 - Inside function
200 - After function call

**When we used local variable then the value of NUM was 100 only inside function and the value did not leak**

aishuser@aish-ubuntu-tws:~/Shellscript$ cat local_demo.sh 
#!/bin/bash
NUM=200 #Global variable

getNUM () {
    NUM=100 #Local variable 
    echo "$NUM - Inside function"
}

echo "$NUM - outside function"

getNUM

echo "$NUM - After function call"
aishuser@aish-ubuntu-tws:~/Shellscript$ ./local_demo.sh 
200 - outside function
100 - Inside function
100 - After function call

**When we did not use local variable inside funtion then after calling the function the variable value changed as per the value defined inside the function. So, value was leaked.**
```

---

## Task 5: Build a Script — System Info Reporter
Create `system_info.sh` that uses functions for everything:
1. A function to print **hostname and OS info**
2. A function to print **uptime**
3. A function to print **disk usage** (top 5 by size)
4. A function to print **memory usage**
5. A function to print **top 5 CPU-consuming processes**
6. A `main` function that calls all of the above with section headers
7. Use `set -euo pipefail` at the top

```bash
#!/bin/bash
set -euo pipefail
info () {
    echo "Hostname is: $HOSTNAME"
    echo "========================================"
    echo "Here is the OS info"
    cat /etc/os-release
}

systemup () {
    echo "Your system's uptime is"
    uptime
}

disk_usage () {
    echo "This is top 5 disk usage by size"
    df -h | sort -k 5 -r | head -n 6
    # -k for column
    # -r for largest value first (ascending)
}

mem_usage () {
    echo "memory usage in your system is"
    free -h
}

process () {
    echo "Top 5 CPU-consuming processes"
    ps aux | sort -k 3 -r | head -n 6
}

main () {
    info
    echo "========================================"
    systemup
    echo "========================================"
    disk_usage
    echo "========================================"
    mem_usage
    echo "========================================"
    process
}

main
```

> output

```bash
aishuser@aish-ubuntu-tws:~/Shellscript$ ./system_info.sh 
Hostname is: aish-ubuntu-tws
========================================
Here is the OS info
PRETTY_NAME="Ubuntu 24.04.4 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
VERSION="24.04.4 LTS (Noble Numbat)"
VERSION_CODENAME=noble
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=noble
LOGO=ubuntu-logo
========================================
Your system's uptime is
 07:05:02 up  1:04,  1 user,  load average: 0.00, 0.00, 0.00
========================================
This is top 5 disk usage by size
Filesystem      Size  Used Avail Use% Mounted on
/dev/root        29G   12G   17G  43% /
efivarfs        128K   38K   86K  31% /sys/firmware/efi/efivars
/dev/sda16      881M  223M  597M  28% /boot
/dev/sda15      105M  6.2M   99M   6% /boot/efi
tmpfs           387M   16K  387M   1% /run/user/1000
========================================
memory usage in your system is
               total        used        free      shared  buff/cache   available
Mem:           3.8Gi       820Mi       1.3Gi       4.0Mi       2.0Gi       3.0Gi
Swap:             0B          0B          0B
========================================
Top 5 CPU-consuming processes
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         698  0.2  4.3 1085444 173720 ?      Ssl  06:01   0:09 /opt/microsoft/mdatp/sbin/wdavdaemon
root        1320  0.2  2.5 895020 102516 ?       Sl   06:01   0:09 /opt/microsoft/mdatp/sbin/wdavdaemon edr 18 17 --log_level info
root        1094  0.1  1.0 424184 42208 ?        Sl   06:01   0:04 /usr/bin/python3 -u bin/WALinuxAgent-2.15.2.1-py3.12.egg -run-exthandlers
root        1073  0.0  2.3 1925460 92648 ?       Ssl  06:01   0:00 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
root        4258  0.0  1.5 544180 62608 ?        Ssl  06:15   0:01 /usr/libexec/fwupd/fwupd
```