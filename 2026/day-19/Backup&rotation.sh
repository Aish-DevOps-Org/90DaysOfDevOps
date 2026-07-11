#/bin/bash

<<Readme
This is a script for backup with 5 day rotation
Usage: ./backup.sh <Path to your source> <path to your backup folder>
Readme

# Define a function to display usage information
function display_usage() {
    echo "Usage: $0 <source_directory> <backup_directory>"
}

# check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    display_usage
    exit 1
fi

# Define the source and backup directories
source_directory="$1"
backup_directory="$2"

# Check if the backup directory exists, if not create it
if [ ! -d "$backup_directory" ]; then
    echo "Backup folder does not exist. Creating it..."
    mkdir -p "$backup_directory"
fi

# Define a function to create a backup and rotate old backups
function create_backup() {
    # Create a timestamp for the backup
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    BACKUP_NAME="backup_$TIMESTAMP.tar.gz"

    # Create the backup
    tar -czf "$backup_directory/$BACKUP_NAME" -C "$source_directory" . > /dev/null

    echo "Backup created: $BACKUP_NAME"
}

create_backup

function rotate_backups() {
    # Rotate backups (keep only the recent 5 backups)
    BACKUPS=($(ls -t "$backup_directory"/backup_*.tar.gz 2>/dev/null))
    # echo "Current backups: ${BACKUPS[@]}"

    if [ ${#BACKUPS[@]} -gt 5 ]; then           # To Check the length of the BACKUPS array we use #BACKUPS
    echo "Rotating backups..."
    backups_to_delete=(${BACKUPS[@]:5})  # Get the backups to delete (all except the recent 5 which is already sorted by time in BACKUPS array)
        for backup in "${backups_to_delete[@]}"; do
            rm -f "$backup"
            echo "Deleted old backup: $backup"
        done
    fi
  #      for ((i=5; i<${#BACKUPS[@]}; i++)); do
  #          rm "${BACKUPS[$i]}"
  #          echo "Deleted old backup: ${BACKUPS[$i]}"
  #      done
  #  fi
}