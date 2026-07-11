# Day 20 – Bash Scripting Challenge: Log Analyzer and Report Generator

## Task 1: Input and Validation
Your script should:
1. Accept the path to a log file as a command-line argument
2. Exit with a clear error message if no argument is provided
3. Exit with a clear error message if the file doesn't exist

```bash
#!/bin/bash

set -e

#Take log file as command argument
log_file=$1

#checn if the argument was passed else fail the script
if [ $# -ne 1 ]; then
    echo "Please provide the log_file path in the command."
    echo "Usage: ./input.sh <Log file path>"
    exit 1
fi

#check if the file name passed, exists else fail the script
if [ ! -f "$log_file" ]; then 
    echo "Error: $log_file does not exist"
    exit 1
fi

echo "Log file found: $log_file"

```

> output
```bash
aishuser@aish-ubuntu-tws:~/loganalyzer$ ./validation.sh 
Please provide the log_file path in the command.
Usage: ./input.sh <Log file path>
aishuser@aish-ubuntu-tws:~/loganalyzer$ vim validation.sh 
aishuser@aish-ubuntu-tws:~/loganalyzer$ ./validation.sh ./sample_log.log
Log file found: ./sample_log.log
aishuser@aish-ubuntu-tws:~/loganalyzer$ ./validation.sh ./sample_log2.log
Error: ./sample_log2.log does not exist
aishuser@aish-ubuntu-tws:~/loganalyzer$
```

---

## Task 2: Error Count
1. Count the total number of lines containing the keyword `ERROR` or `Failed`
2. Print the total error count to the console


```bash
#!/bin/bash
set -e

function error_count () {
    #error_count=$(awk '/ERROR|Failed/' logfile.log | wc -l)
    error_count=$(grep -ciE 'Error|Failed' "$log_file")
    echo "Total error count: $error_count"
}

```

> output

```bash
aishuser@aish-ubuntu-tws:~/loganalyzer$ ./validation.sh sample_log.log 
Log file found: sample_log.log
Total error count: 101
```

***Note:***
In grep -cE:

-c = count
Instead of printing matching lines, grep prints the number of matching lines.

-E = Extended Regular Expression (ERE)
Lets you use regex operators like |, +, ?, () without escaping them.
---

## Task 3: Critical Events
1. Search for lines containing the keyword `CRITICAL`
2. Print those lines along with their line number

Example output:
```
--- Critical Events ---
Line 84: 2025-07-29 10:15:23 CRITICAL Disk space below threshold
Line 217: 2025-07-29 14:32:01 CRITICAL Database connection lost
```

```bash

#!/bin/bash
set -e
function crit_event () {
    critical_events=$(grep -ni CRITICAL "$log_file")
    echo "Lines with critical events: $critical_events"
}

```
> output

```bash
aishuser@aish-ubuntu-tws:~/loganalyzer$ ./validation.sh sample_log.log 
Log file found: sample_log.log
Total error count: 101
Lines with critical events: 9:2026-07-11 15:39:49 [CRITICAL]  - 28310
15:2026-07-11 15:39:49 [CRITICAL]  - 3145
16:2026-07-11 15:39:49 [CRITICAL]  - 17412
17:2026-07-11 15:39:49 [CRITICAL]  - 14067
23:2026-07-11 15:39:49 [CRITICAL]  - 10670
31:2026-07-11 15:39:49 [CRITICAL]  - 18142
33:2026-07-11 15:39:49 [CRITICAL]  - 27128
38:2026-07-11 15:39:49 [CRITICAL]  - 30937
40:2026-07-11 15:39:49 [CRITICAL]  - 10202
42:2026-07-11 15:39:49 [CRITICAL]  - 5980
```

***Note:***
In grep -ni
-n = display the line number
-i = case insensitive

---

## Task 4: Top Error Messages
1. Extract all lines containing `ERROR`
2. Identify the **top 5 most common** error messages
3. Display them with their occurrence count, sorted in descending order

Example output:
```
--- Top 5 Error Messages ---
45 Connection timed out
32 File not found
28 Permission denied
15 Disk I/O error
9  Out of memory
```

```bash
function top_error() {
    echo "Getting lines with ERROR message"
    grep -i ERROR "$log_file" |
    #echo "Removing first 3 columns to get only error messages"
    awk '{$1=$2=$3=""; print}' |
    #echo "removing the random numbers column as well by splitting after - and pinting $1"
    awk -F' - ' '{print $1}' |
    sort | uniq -c | sort -rn | head -5

}
```
> output

```bash
aishuser@aish-ubuntu-tws:~/loganalyzer$ ./toperror.sh sample_log.log 
Log file found: sample_log.log
Getting lines with ERROR message
     24    Out of memory
     23    Failed to connect
     20    Invalid input
     19    Segmentation fault
     15    Disk full
```
***Note:***
grep → Find ERROR lines
awk → Remove timestamp and ERROR tag
sort → Group identical messages together
uniq -c → Count occurrences of identical messages
sort -rn → Highest count first
head -5 → Show top 5

**awk:**
$1=$2=$3="" -> Set fields 1, 2, and 3 to empty strings.
-F' - ' -> Field separator, You can tell awk to split fields using a different character or string. 
Example - 
awk -F' - # split on (space-hyphen-space)
awk -F: # split on :
awk -F, # split on ,
---

## Task 5: Summary Report
Generate a summary report to a text file named `log_report_<date>.txt` (e.g., `log_report_2026-02-11.txt`). The report should include:
1. Date of analysis
2. Log file name
3. Total lines processed
4. Total error count
5. Top 5 error messages with their occurrence count
6. List of critical events with line numbers

```bash
#!/bin/bash
set -e
log_file=$1
#checn if the argument was passed else fail the script
if [ $# -ne 1 ]; then
    echo "Please provide the log_file path in the command."
    echo "Usage: ./input.sh <Log file path>"
    exit 1
fi

#check if the file name passed, exists else fail the script
if [ ! -f "$log_file" ]; then
    echo "Error: $log_file does not exist"
    exit 1
fi

echo "Log file found: $log_file"

TIMESTAMP=$(date +"%Y-%m-%d")
summary_file="log_report_$TIMESTAMP.txt"

touch "$summary_file"

function report() {

echo "1.Date of analysis is: $(date)"
echo "2.Log file: $log_file"
echo "3.Total lines processed"
wc -l "$log_file"

echo "5.Top 5 error messages with their occurrence count"
/home/aishuser/loganalyzer/toperror.sh "sample_log.log" 
echo "4.total error count" 
echo "6.List of critical events with line numbers"
/home/aishuser/loganalyzer/validation.sh "sample_log.log"
}

report >> $summary_file
```

> output
```bash
aishuser@aish-ubuntu-tws:~/loganalyzer$ cat log_report_2026-07-11.txt
1.Date of analysis is: Sat Jul 11 20:00:09 UTC 2026
2.Log file: sample_log.log
3.Total lines processed
500 sample_log.log
5.Top 5 error messages with their occurrence count
Log file found: sample_log.log
Getting lines with ERROR message
     24    Out of memory
     23    Failed to connect
     20    Invalid input
     19    Segmentation fault
     15    Disk full
4.total error count
6.List of critical events with line numbers
Log file found: sample_log.log
Total error count: 101
Lines with critical events: 9:2026-07-11 15:39:49 [CRITICAL]  - 28310
15:2026-07-11 15:39:49 [CRITICAL]  - 3145
16:2026-07-11 15:39:49 [CRITICAL]  - 17412
17:2026-07-11 15:39:49 [CRITICAL]  - 14067
23:2026-07-11 15:39:49 [CRITICAL]  - 10670
31:2026-07-11 15:39:49 [CRITICAL]  - 18142
```

---

## Task 6 (Optional): Archive Processed Logs
Add a feature to:
1. Create an `archive/` directory if it doesn't exist
2. Move the processed log file into `archive/` after analysis
3. Print a confirmation message

```bash
aishuser@aish-ubuntu-tws:~/loganalyzer$ cat archive.sh 
#!/bin/bash

set -e

log_dir="/home/aishuser/loganalyzer"
if [ ! -d "archive" ]; then
        sudo mkdir archive
fi
sudo find "$log_dir" -type f -name "log_report_*.txt" -mmin +10 -exec mv {} /home/aishuser/loganalyzer/archive/ \;
echo "moved files successfully"
```
> output

```bash
aishuser@aish-ubuntu-tws:~/loganalyzer$ ./archive.sh 
moved files successfully

aishuser@aish-ubuntu-tws:~/loganalyzer$ ls archive
log_report_2026-07-11.txt           log_report_2026-07-11_19-42-01.txt  log_report_2026-07-11_19-54-47.txt
log_report_2026-07-11_19-25-51.txt  log_report_2026-07-11_19-43-34.txt
```
---

### Sample Log File

A sample log file is available in this directory: `sample_log.log`

You can also pick real-world log datasets from the [LogHub repository](https://github.com/logpai/loghub) to test your script against production-like logs (e.g., ZooKeeper, HDFS, Apache, Linux syslogs).

---

## Hints
- Count errors: `grep -c "ERROR" logfile.log`
- Print with line numbers: `grep -n "CRITICAL" logfile.log`
- Top occurrences: `grep "ERROR" logfile.log | awk '{$1=$2=$3=""; print}' | sort | uniq -c | sort -rn | head -5`
- Associative arrays: `declare -A error_map`
- Date for filename: `date +%Y-%m-%d`