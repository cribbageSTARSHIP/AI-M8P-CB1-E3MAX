#!/bin/bash

# --- Configuration ---
# This is the path to your Klipper configuration directory.
# Make sure this matches your setup (e.g., '~/printer_data/config').
CONFIG_DIR=~/printer_data/config

# This is the name of the subdirectory where backups will be stored.
# --- MODIFIED LINE ---
BACKUP_DIR="$CONFIG_DIR/printer_cfg-old" 

# The number of recent backup files you want to keep in the main directory.
# --- NEW ---
KEEP_COUNT=3
# --- End of Configuration ---


# Exit if the config directory doesn't exist
if [ ! -d "$CONFIG_DIR" ]; then
  echo "Error: Config directory not found at $CONFIG_DIR"
  exit 1
fi

# Create the backup directory if it doesn't already exist
echo "Checking for backup directory at $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"
echo "Directory check complete."

# --- MODIFIED LOGIC ---
# List all printer.cfg backups, sort by time (newest first), skip the newest ones,
# and then move the rest to the backup directory.
echo "Keeping the $KEEP_COUNT newest backups and moving the rest..."
ls -t "$CONFIG_DIR"/printer-*.cfg 2>/dev/null | tail -n +$(($KEEP_COUNT + 1)) | xargs -I {} mv {} "$BACKUP_DIR"

echo "Backup move complete."
