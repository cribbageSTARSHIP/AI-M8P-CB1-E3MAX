Here is one document with steps 1-6 for setting up your Klipper configuration backup cleaner. You can copy and paste this content.
Markdown

# Klipper Configuration Backup Cleaner Setup

This document provides a consolidated guide for setting up the `move_backups.sh` script to automatically manage your Mainsail `printer-*.cfg` backups.

## Steps for Setup and Configuration:

Follow these instructions directly in your Klipper host's terminal (e.g., Raspberry Pi via SSH).

### 1. Create the Scripts Directory

Ensure a dedicated directory for your custom scripts exists within your `printer_data` folder:

```bash
mkdir -p ~/printer_data/scripts
```

### 2. Create the Script File (move_backups.sh)

Create a new file named move_backups.sh inside the ~/printer_data/scripts/ directory.

```Bash
nano ~/printer_data/scripts/move_backups.sh
```

Paste the following script content into the nano editor, then save and exit (press Ctrl+X, then Y, then Enter):

```Bash
#!/bin/bash

# --- Configuration ---
# This is the path to your Klipper configuration directory.
# Make sure this matches your setup (e.g., '~/printer_data/config').
CONFIG_DIR=~/printer_data/config

# This is the name of the subdirectory where backups will be stored.
BACKUP_DIR="$CONFIG_DIR/printer_cfg-old" 

# The number of recent backup files you want to keep in the main directory.
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

# List all printer.cfg backups, sort by time (newest first), skip the newest ones,
# and then move the rest to the backup directory.
echo "Keeping the $KEEP_COUNT newest backups and moving the rest..."
ls -t "$CONFIG_DIR"/printer-*.cfg 2>/dev/null | tail -n +$(($KEEP_COUNT + 1)) | xargs -I {} mv {} "$BACKUP_DIR"

echo "Backup move complete."
```

3. Make the Script Executable

Give the script executable permissions:

```Bash
chmod +x ~/printer_data/scripts/move_backups.sh
```

4. Configure Cron for Automated Execution

Schedule the script to run automatically each time your Raspberry Pi (or Klipper host machine) boots up.

Open your crontab for editing:

```Bash
crontab -e
```

At the end of the file, add the following line. This tells cron to execute your script after every reboot, redirecting its output (including any echo statements from the script) to /dev/null.

```
@reboot /bin/bash /home/pi/printer_data/scripts/move_backups.sh > /dev/null 2>&1
```

(Important Note: Double-check that /home/pi/ is the correct home directory for the user running Klipper on your system. If your username is different (e.g., prizm), you should adjust the path accordingly, e.g., /home/prizm/printer_data/scripts/move_backups.sh.)

Save and exit the crontab editor.

5. (Optional) Create Backup Directory Manually

While the script will automatically create the printer_cfg-old directory if it doesn't exist, you can create it manually once if you prefer:

```Bash
mkdir -p ~/printer_data/config/printer_cfg-old/
```

6. Script Configuration (Variables within move_backups.sh)

You can customize the script's behavior by editing the variables at the top of the move_backups.sh file:

    CONFIG_DIR: The absolute path to your main Klipper configuration directory where printer.cfg and its backups are located.

        Default: ~/printer_data/config

        Adjust if needed: If your Klipper config files are located elsewhere, update this path.

    BACKUP_DIR: The full path to the directory where older backups will be moved.

        Default: "$CONFIG_DIR/printer_cfg-old" (This creates a subdirectory within your CONFIG_DIR).

    KEEP_COUNT: The number of most recent printer-*.cfg backup files to keep in the main CONFIG_DIR. All older files will be moved.

        Default: 3
