#!/bin/bash

# This script removes the temporary PID sections from the bottom of printer.cfg

# Find the user's config directory, typically ~/printer_data/config or ~/klipper_config
# This makes the script more portable.
if [ -d "$HOME/printer_data/config" ]; then
    CONFIG_FILE="$HOME/printer_data/config/printer.cfg"
elif [ -d "$HOME/klipper_config" ]; then
    CONFIG_FILE="$HOME/klipper_config/printer.cfg"
else
    echo "Error: Could not find a valid Klipper config directory."
    exit 1
fi

# The sed command to remove the lines
sed -i \
    -e '/^#\*# \[extruder\]/d' \
    -e '/^#\*# \[heater_bed\]/d' \
    -e '/^#\*# control = pid/d' \
    -e '/^#\*# pid_kp = /d' \
    -e '/^#\*# pid_ki = /d' \
    -e '/^#\*# pid_kd = /d' \
    "$CONFIG_FILE"

exit 0