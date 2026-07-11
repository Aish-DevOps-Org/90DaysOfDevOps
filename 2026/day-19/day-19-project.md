# Day 19 – Shell Scripting Project: Log Rotation, Backup & Crontab

## Task 1: Log Rotation Script
Create `log_rotate.sh` that:
1. Takes a log directory as an argument (e.g., `/var/log/myapp`)
2. Compresses `.log` files older than 7 days using `gzip`
3. Deletes `.gz` files older than 30 days
4. Prints how many files were compressed and deleted
5. Exits with an error if the directory doesn't exist

```bash
#!/bin/bash
<<usage
usage: ./log_rotate.sh <source log dir> 
usage

log_dir=$1

# Check log_dir argument
function display_usage() {
   echo "usage: ./log_rotate.sh <source log dir>"
   exit 1
}
if [ "$#" -ne 1 ]; then
   display_usage
fi

# Check directory exists
if [ ! -d "$log_dir" ]; then
   echo "Error: '$log_dir' does not exist"
   exit 1
fi

function compress_log() {
   compress_count=($(find "$log_dir" -type f -name "*.log" -mtime +7))
   echo "7d Older logs: ${#compress_count[@]}"

   if [ ${#compress_count[@]} -gt 0 ]; then
      gzip "${compress_count[@]}"
   fi
}

function delete_logs() {
   delete_log=($(find "$log_dir" -type f -name "*.gz" -mtime +30))
   echo "30d old logs: ${#delete_log[@]}"

   if [ ${#delete_log[@]} -gt 0 ]; then
      rm -f "${delete_log[@]}"
      echo "deleted 30d old logs"
   fi
}
compress_log
delete_logs
```

---

## Task 2: Server Backup Script
Create `backup.sh` that:
1. Takes a source directory and backup destination as arguments
2. Creates a timestamped `.tar.gz` archive (e.g., `backup-2026-02-08.tar.gz`)
3. Verifies the archive was created successfully
4. Prints archive name and size
5. Deletes backups older than 14 days from the destination
6. Handles errors — exit if source doesn't exist

```bash
#!/bin/bash

# Define the source and backup directories
source_directory="$1"
backup_directory="$2"

# Define a function to display usage information
function display_usage() {
    echo "Usage: $0 <source_directory> <backup_directory>"
}

# check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    display_usage
    exit 1
fi

# Check if the source directory exists
if [ ! -d "$source_directory" ]; then
    echo "Source folder does not exist"
    exit 1
fi

function create_archive() {
   TIMESTAMP=$(date +"%Y-%m-%d")
   BACKUP_NAME="backup-$TIMESTAMP.tar.gz"

   #create backup archive
   tar -czf "$backup_directory/$BACKUP_NAME" -C "$source_directory" . > /dev/null

   if [ $? -ne 0 ]
      then
         echo "Backup failed"
         exit 1
   fi

   if [ ! -f "$backup_directory/$BACKUP_NAME" ]; then

      echo "Archive not found"
      exit 1

   fi

   SIZE=$(stat -c %s "$backup_directory/$BACKUP_NAME")
   echo "Backup created successfully: $BACKUP_NAME and size is $SIZE"
}


function delete_backup() {
   to_delete=$(find "$backup_directory" -type f -name "*.tar.gz" -mtime +14 | wc -l) 
   if [ "$to_delete" -gt 0 ]; then
         find "$backup_directory" -type f -name "*.tar.gz" -mtime +14 -delete
         echo "14 days older backups deleted successfully"
      else
         echo "no backups older than 14days"
   fi
}

create_archive
delete_backup
```
> output

```bash
aishuser@aish-ubuntu-tws:~$ ./backup.sh 
Usage: ./backup.sh <source_directory> <backup_directory>
aishuser@aish-ubuntu-tws:~$ ./backup.sh Shellscript/ Backup_dir/
Backup created successfully: backup-2026-07-11.tar.gz and size is 2411
no backups older than 5 days
aishuser@aish-ubuntu-tws:~$ ls Backup_dir/
backup-2026-07-10.tar.gz  backup-2026-07-11.tar.gz
```

---

## Task 3: Crontab
1. Read: `crontab -l` — what's currently scheduled?
2. Understand cron syntax:
   ```
   * * * * *  command
   │ │ │ │ │
   │ │ │ │ └── Day of week (0-7)
   │ │ │ └──── Month (1-12)
   │ │ └────── Day of month (1-31)
   │ └──────── Hour (0-23)
   └────────── Minute (0-59)
   ```
3. Write cron entries (in your markdown, don't apply if unsure) for:
   - Run `log_rotate.sh` every day at 2 AM
   0 2 * * *
   - Run `backup.sh` every Sunday at 3 AM
   0 3 * * 0
   - Run a health check script every 5 minutes

```bash
0 2 * * * /home/aishuser/log_rotate.sh /var/log/myapp
0 3 * * 0 /home/aishuser/backup.sh /home/aishuser/Shellscript/ /home/aishuser/Backup_dir
5 * * * * /home/aishuser/Shellscript/system_info.sh >> /home/aishuser/health_check.log 2>&1
```

---

## Task 4: Combine — Scheduled Maintenance Script
Create `maintenance.sh` that:
1. Calls your log rotation function
2. Calls your backup function
3. Logs all output to `/var/log/maintenance.log` with timestamps
4. Write the cron entry to run it daily at 1 AM
0 1 * * *

```bash
#/bin/bash
LOG_FILE="/var/log/maintenance.log"

log () { 
   echo "===========start=========="
   echo "$(date +'%Y-%m-%d %H:%M:%S')-$1" >> "$LOG_FILE"
   echo "===========end=========="
}

log "Maintenance started"

# Run log rotation
log "Running Backup"
./log_rotate.sh /var/log/myapp >> "$LOG_FILE" 2>&1

# Run backup
log "Running backup"

./backup.sh /home/aishuser/Shellscript /home/aishuser/Backup_dir >> "$LOG_FILE" 2>&1

log "Maintenance completed"
echo "========end========"
```
> output

```bash
no backups older than 5 days
2026-07-10 20:12:01 - Maintenance completed
2026-07-11 17:23:53 - Maintenance started
2026-07-11 17:23:53 - Running Backup
./maintenance.sh: line 11: ./log_rotate.sh: No such file or directory
2026-07-11 17:23:53 - Running backup
Backup created successfully: backup-2026-07-11.tar.gz and size is 2411
no backups older than 5 days
2026-07-11 17:23:53 - Maintenance completed
```
---