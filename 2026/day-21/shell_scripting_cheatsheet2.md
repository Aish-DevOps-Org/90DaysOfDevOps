# Day 21 – Shell Scripting Cheat Sheet: Build Your Own Reference Guide

## Task 4: Functions

> Functions let you group reusable code into a named block. Instead of writing the same code multiple times, define it once and call it whenever needed.

Document with examples:
1. Defining a function — `function_name() { ... }`
```bash
function_name() {
    commands
}
```
2. Calling a function - Simply use the function name.
```bash
function_name
```
3. Passing arguments to functions — `$1`, `$2` inside functions
```bash
function_name arg1 arg2
```
4. Return values — `return` vs `echo`
- return: returns an exit status (0-255), so use for success/failure status
- echo: Returns actual data/output.

```bash
check_file() {
    [ -f "$1" ]
    return $?
}

check_file test.txt
echo $?
```

5. Local variables — `local`

local variable is a special type of variable which has its scope only within a specific function or block of code. Local variables can override the same variable name in the larger scope. 

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

Output:
aishuser@aish-ubuntu-tws:~/Shellscript$ ./local_demo.sh 
200 - outside function
100 - Inside function
200 - After function call
```
**When we used local variable then the value of NUM was 100 only inside function and the value did not leak**

```bash
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

output:
aishuser@aish-ubuntu-tws:~/Shellscript$ ./local_demo.sh 
200 - outside function
100 - Inside function
100 - After function call
```
**When we did not use local variable inside funtion then after calling the function the variable value changed as per the value defined inside the function. So, value was leaked.**

---

## Task 5: Text Processing Commands

> Text processing commands are heavily used in Linux for searching, filtering, extracting, modifying, and analyzing text data.

Document the most useful flags/patterns for each:
1. `grep` — search patterns, `-i`, `-r`, `-c`, `-n`, `-v`, `-E`

```bash
grep "ERROR" logfile.log      # Search text
grep -i "error" logfile.log   # Ignore case
grep -r "ERROR" /var/log      # Recursive search
grep -c "ERROR" logfile.log   # Count matches
grep -n "ERROR" logfile.log   # Show line numbers
grep -v "INFO" logfile.log    # Exclude matches
grep -E "ERROR|WARN" file     # Extended regex (OR)
```

2. `awk` — print columns, field separator, patterns, `BEGIN/END`

```bash
Common usage: awk '{print $1}' file
# Prints first column
-----
Field Separator: awk -F: '{print $1}' /etc/passwd
# Use : as delimiter.
-----
Pattern Matching: awk '/ERROR/' logfile.log
# Print lines containing ERROR.
-----
BEGIN / END
awk '
BEGIN { commands }
{ commands for each line }
END { commands }
' file

BEGIN runs once
↓
Line 1 processed
↓
Line 2 processed
↓
Line 3 processed
↓
END runs once
```

3. `sed` — substitution, delete lines, in-place edit

**Substitution:** \
Replace nth occurrence -
> sed 's/OldWord/NewWord/n' file

Example - This command replaces the first occurrence of “Linux” with “Unix” in each line.
> sed 's/Linux/Unix/' file1.txt

Replace all occurrences -> /g (global replacement)
> sed 's/OldWord/NewWord/g' file

Example - This command replaces all occurrences of “Linux” with “Unix” in each line.
> sed 's/Linux/Unix/g' file1.txt

**In-place Editing:** \
The `-i enables in-place editing of the file. In simple words it overwrites the file.
> sed -i 's/Linux/Unix/' file1.txt 

This command edits the file in place, replacing “Linux” with “Unix” directly in file1.txt. Without -i, the insertion occurs only in the output and doesn’t modify the file content. To make the change persistent, you need to use the -i option.

**Delete lines:** \
This command will delete the second line from file1.txt
> sed '2d' file1.txt

The /pattern/ matches lines containing the pattern and the d flag deletes matched lines.
> sed '/kernel/d' file1.txt

4. `cut` — extract columns by delimiter \
Show usernames
> cut -d: -f1 /etc/passwd

Example:
> echo "John,25,IT" | cut -d, -f2

Output: 25

Flags: \
-d   Delimiter \
-f   Field number

5. `sort` — alphabetical, numerical, reverse, unique \
-n = Numerical \
-r = reverse \
-u = unique

Example:
```bash
# Alphabetical
sort names.txt
# Numerical
sort -n numbers.txt
# Reverse Order
sort -r names.txt
# Unique - Remove duplicates while sorting.
sort -u names.txt
```

6. `uniq` — deduplicate, count \
Works on adjacent duplicate lines (usually after sort)

Example:

```bash
# Remove duplicates
sort names.txt | uniq

# Count occurrences
sort names.txt | uniq -c
```
Flags: \
uniq -c     # Count \
uniq -d     # Show duplicates only

7. `tr` — translate/delete characters

Example:

```bash
# Convert Lowercase to Uppercase
echo "hello" | tr 'a-z' 'A-Z'
Output: HELLO

# Delete Characters
echo "a,b,c" | tr -d ','
Output: abc

# Replace Characters
echo "a,b,c" | tr ',' ':'
Output: a:b:c
```

8. `wc` — line/word/char count

wc -l file.txt   # Lines \
wc -w file.txt   # Words \
wc -c file.txt   # Characters/bytes \
wc file.txt      # All counts

9. `head` / `tail` — first/last N lines, follow mode

```bash
# Show first 5 lines
head -n 5 file.txt

# Show last 5 lines
tail -n 5 file.txt

# Follow Mode (Live Logs)
tail -f application.log

# Continuously monitor new lines appended to a file.
# Useful for troubleshooting running applications.
```
---

## Task 6: Useful Patterns and One-Liners
Include at least 5 real-world one-liners you find useful. Examples:
- Find and delete files older than N days
> find "folderpath" -type f -name "filesName" -mtime +N -delete \
find /var/log -type f -name "*.log" -mtime +30 -delete

- Count lines in all `.log` files
> find . -name "*.log" -exec wc -l {} +

- Replace a string across multiple files
> find . -name "*.conf" -exec sed -i 's/localhost/server01/g' {} +

"{}"  Placeholder for found files \
"+"  Pass multiple files at once (more efficient)

- Check if a service is running
> systemctl is-active nginx

- Monitor disk usage with alerts
> df -h | awk '$5+0 > 80 {print "ALERT:", $6, $5}'

```bash
Filesystem Size Used Avail Use% Mounted
/dev/sda1   50G  45G   5G  90% /

$5 = 90%
$5 + 0 = 90
90 > 80
print $6, $5 = ALERT: / 90%
```

**Note:**
In awk, % is the modulus operator and not part of numeric literal. So the % needs to be converted to numbers before comparison. 
Adding +0 forces numeric conversion: "90%" → 90.

- Parse CSV or JSON from command line
```bash
# Parse CSV:
name,age,dept
John,25,IT
Mike,30,HR

cut -d, -f1 users.csv
Output:
name
john
Mike

awk -F, '{print $3}' users.csv
Output:
dept
IT
HR

# Parse JSON:
{
  "name": "John",
  "age": 25
}

jq '.name' user.json
Output:
"John"

jq '.name, .age' user.json
Output:
"John"
25
```
**Note:**
JSON is structured data. jq works for JSON just like awk works for columns.

- Tail a log and filter for errors in real time
> tail -f application.log | grep --line-buffered "ERROR"

---

## Task 7: Error Handling and Debugging
Document with examples:
1. Exit codes — `$?`, `exit 0`, `exit 1`
> $? - exit status of previous command \
exit 0 - Success \
exit 1 - Failure

```bash
ls file.txt
echo $?

Output: 0
-----------
if [ ! -f file.txt ]; then
    echo "File not found"
    exit 1
fi

echo "Success"
exit 0
```

2. `set -e` — exit on error \
Prevents scripts from continuing after failures.

```bash
#!/bin/bash
set -e

echo "start"
ls /does/not/exist
echo "end"
```
Here, echo "end" will not run as the script failed at ls

3. `set -u` — treat unset variables as error

```bash
#!/bin/bash
set -u

echo "$name"

Output: name: unbound variable

Without set -u, the output will be blank.
```

4. `set -o pipefail` — catch errors in pipes \
Normally, a pipeline succeeds if the last command succeeds.

```bash
grep "hello" missing.txt | wc -l

Output:
grep: missing.txt: No such file
0

Pipeline exit code: 0

# With pipelfail, pipeline fails if any command fails.

set -o pipefail
grep "hello" missing.txt | wc -l
echo $?

Output: 
grep: missing.txt: No such file
2
```
Prevents hidden failures in pipelines.

5. `set -x` — debug mode (trace execution) \
Prints each command before execution. \
set -x -> Enable \
set +x -> Disable

```bash
#!/bin/bash
set -x

name="Aishwarya"
echo "$name"

Output:
+ name=Aishwarya
+ echo Aishwarya
Aishwarya
```

6. Trap — `trap 'cleanup' EXIT` \
Run cleanup on script exit

```bash
cleanup() {
    echo "Cleaning up..."
    rm -f /tmp/tempfile
}

trap cleanup EXIT

# When script ends (success or error)
Cleaning up...
```
---

## Task 8: Bonus — Quick Reference Table
Create a summary table like this at the top of your cheat sheet:

| Topic | Key Syntax | Example |
|-------|-----------|---------|
| Variable | `VAR="value"` | `NAME="DevOps"` |
| Argument | `$1`, `$2` | `./script.sh arg1` |
| If | `if [ condition ]; then` | `if [ -f file ]; then` |
| For loop | `for i in list; do` | `for i in 1 2 3; do` |
| Function | `name() { ... }` | `greet() { echo "Hi"; }` |
| Grep | `grep pattern file` | `grep -i "error" log.txt` |
| Awk | `awk '{print $1}' file` | `awk -F: '{print $1}' /etc/passwd` |
| Sed | `sed 's/old/new/g' file` | `sed -i 's/foo/bar/g' config.txt` |