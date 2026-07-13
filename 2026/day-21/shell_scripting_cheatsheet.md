# Day 21 – Shell Scripting Cheat Sheet: Build Your Own Reference Guide

## Task 1: Basics
Document the following with short descriptions and examples:
1. Shebang (`#!/bin/bash`) — what it does and why it matters
> To explicitely tell the Linux which shell should be used, else the default shell will be used for the script execution.
2. Running a script — `chmod +x`, `./script.sh`, `bash script.sh`
> When we create a script, it only has read and write permission and can't be executed. So , we need to provide the execute permission to the user before we execute it.
3. Comments — single line (`#`) and inline
> For single line and inline commment we use #
> Script ignores the complete sentence after #

Example-
```bash
Single line
# This is a single-line comment

Inline
echo "System updating..."   # This is inline comment, keep space after the command

Multi-line comment:

<<Comment
Some text
1
2
Comment

```

4. Variables — declaring, using, and quoting (`$VAR`, `"$VAR"`, `'$VAR'`)

**Declare** -> declaring them without spaces around the equals sign
Var="string"
Var=10

- Strict Rule: never put spaces around the equals (=)

```bash
# INCORRECT (Will cause syntax errors)
greeting = "Hello World" 
```

- Naming Rule: Variable names must begin with a letter or an underscore, and can only contain alphanumeric characters and underscores (_)
> _filepath="/var/log/nginx"

- Local vs. Environment: (Local) Standard variables are only available in the current shell session. (Environment) To make them available to child processes and scripts, use the export command

Making a variable an environment variable
> export greeting

**Using** -> referencing them using the dollar sign ($) \
$Var

- Curly Braces {}: Use curly braces around the variable name to protect it when it is immediately followed by other characters or letters, avoiding naming ambiguity

Example

```bash
name="John"

# Basic usage
echo $name

# Using curly braces to append text seamlessly
echo "This is ${name}ny's laptop"   # Outputs: This is Johnny's laptop
echo "This is $nameny's laptop"     # Fails: Looks for a variable named $nameny
```

**Use with quotes** -> quoting them with double quotes to prevent the shell from splitting words or expanding wildcards \
"$Var"

- If a variable contains spaces, unquoted references cause the Linux shell to break the value apart into multiple distinct arguments (Word Splitting). It will also accidentally run wildcard patterns like * if they exist inside the string (Globbing).

- Double Quote: \
Weak Quoting: Preserves literal characters but allows variable expansion ($) and command substitution. \
Best Used For: General variable references.

- Single Quote:  \
Strong Quoting: Treats every single character inside entirely as a literal string. Blocks all variable  expansion. \
Best Used For: Defining hard strings; ignoring special meanings

Example 
```bash
# Example showing the difference
phrase="New Folder"

# Create a directory without quotes
mkdir $phrase     # Creates TWO folders: "New" and "Folder"

# Create a directory with double quotes
mkdir "$phrase"   # Creates ONE folder: "New Folder"

# Single vs Double quote expansion
echo "Hello $phrase"  # Outputs: Hello New Folder
echo 'Hello $phrase'  # Outputs: Hello $phrase
```

5. Reading user input — `read`

When we need a user input during the script execution, we use 'read' command

Usage:
> read [options] variable_name

Flag: \
-p "Prompt": Displays a text prompt before waiting for user input, eliminating the need for a separate echo command. \
-s (Silent mode): Hides the user's input as they type. This is ideal for sensitive data like passwords or API keys. \
-t seconds (Timeout): Specifies a maximum wait time. If the user does not type anything within this window, the command terminates. \
-n count: Limits the number of characters to read. \
-r (Raw mode): Prevents backslashes from acting as escape characters and read it literally

Splitting Input by Custom Delimiter (IFS)
IFS - interbnal field separator
The default behavior of read is to split the line into words using spaces, tabs, and newlines as delimiters. To use a different character, assign it to the IFS variable

Example
```bash
echo "Linux:is:awesome." | (IFS=":" read -r var1 var2 var3; echo -e "$var1 \n$var2 \n$var3")

Output:
Linux
is
awesome.
```
6. Command-line arguments — `$0`, `$1`, `$#`, `$@`, `$?`

Example: \
./script.sh apple banana orange

`$0` - Name of the scriptt = script.sh \
`$1` - First argument in the command = apple \
`$#` - Total number of arguments = 3 \
`$@` - List of all the arguments = apple banana orange \
`$?` - Exit status of last command

**Note:**  \
- For arguments ten and above, you must use curly braces, like ${10} 
- Exit status: 0 means success. Any number from 1 to 255 indicates an error or specific failure.

---

## Task 2: Operators and Conditionals
Document with examples:
1. String comparisons — `=`, `!=`, `-z`, `-n`
`=` -  Two strings are identical. 
`!=` - Two strings are not equal.
`-z` - String is null (length of zero/empty).
`-n` - String is not null (length is greater than zero)

```bash
str1="hello"
str2="world"

[ "$str1" = "$str2" ]     # Equal
[ "$str1" != "$str2" ]    # Not equal
[ -z "$str1" ]            # Empty string
[ -n "$str1" ]            # Non-empty string
```

2. Integer comparisons — `-eq`, `-ne`, `-lt`, `-gt`, `-le`, `-ge`

```bash
a=10
b=20

[ "$a" -eq "$b" ]   # Equal
[ "$a" -ne "$b" ]   # Not equal
[ "$a" -lt "$b" ]   # Less than
[ "$a" -gt "$b" ]   # Greater than
[ "$a" -le "$b" ]   # Less than or equal
[ "$a" -ge "$b" ]   # Greater than or equal
```

3. File test operators — `-f`, `-d`, `-e`, `-r`, `-w`, `-x`, `-s`

```bash
[ -f file.txt ]     # File exists and is regular file
[ -d mydir ]        # Directory exists
[ -e path ]         # File/dir exists
[ -r file.txt ]     # Readable
[ -w file.txt ]     # Writable
[ -x script.sh ]    # Executable
[ -s file.txt ]     # Exists and not empty
```

4. `if`, `elif`, `else` syntax

```bash
if [ "$a" -gt 10 ]; then
    echo "Greater"
elif [ "$a" -eq 10 ]; then
    echo "Equal"
else
    echo "Smaller"
fi
```

5. Logical operators — `&&`, `||`, `!`

```bash
[ "$a" -gt 0 ] && echo "Positive"       # And operator

[ "$a" -lt 0 ] || echo "Not Negative"   # Or operator

if ! [ -f file.txt ]; then              # NOT operator
    echo "File missing"
fi
```

6. Case statements — `case ... esac`

A case statement is used when you want to compare one variable against multiple possible values. It is often cleaner than using many if/elif conditions.

Syntax:

```bash
case "$variable" in
    pattern1)
        commands
        ;;
    pattern2)
        commands
        ;;
    *)
        default_commands
        ;;
esac
``
```
```bash
fruit="apple"

case "$fruit" in
    apple)
        echo "Red fruit"
        ;;
    banana)
        echo "Yellow fruit"
        ;;
    orange)
        echo "Orange fruit"
        ;;
    *)
        echo "Unknown fruit"
        ;;
esac
```

---

## Task 3: Loops
Document with examples:
1. `for` loop — list-based and C-style
- Iterate over a known list/range

**List-Based**
```bash
Syntax:
for item in list
do
    commands
done

Example:
for fruit in apple banana mango
do
    echo "$fruit"
done
```

**C-Style**
```bash
Syntax:
for ((initialization; condition; increment))
do
    commands
done

Example:
for ((i=1; i<=5; i++))
do
    echo "$i"
done
```

2. `while` loop
- Run as long as the condition is true. Useful when the number of iterations is unknown.

```bash
count=1

while [ "$count" -le 5 ]
do
    echo "$count"
    ((count++))
done
```

3. `until` loop
- Run until condition becomes true

```bash
count=1

until [ "$count" -gt 5 ]
do
    echo "$count"
    ((count++))
done
```

4. Loop control — `break`, `continue`
- Loop control: Used to change the normal flow of a loop.
- break: Exit Loop 

```bash
for i in {1..5}
do
    [ "$i" -eq 3 ] && break
    echo "$i"
done
```

- continue: Skip current iteration and move to the next one

```bash
for i in {1..5}
do
    [ "$i" -eq 3 ] && continue
    echo "$i"
done
```

5. Looping over files — `for file in *.log`
- Useful for processing multiple files matching a pattern.

```bash
for file in *.log
do
    echo "$file"
done
```

6. Looping over command output — `while read line`
- Read input line by line

```bash
ps -ef | while read line
do
    echo "$line"
done

```

---
