#!/bin/bash

# Script to save PID profiles for Klipper
# Arguments:
# $1: Full path to the output file (e.g., /home/biqu/printer_data/config/pid_tunes/pid_asa_105_260.cfg)
# $2: Profile Name (e.g., pid_asa_105_260)
# $3: Extruder Kp
# $4: Extruder Ki
# $5: Extruder Kd
# $6: Bed Kp
# $7: Bed Ki
# $8: Bed Kd

# Assign arguments to variables for clarity
OUTPUT_FILE="$1"
PROFILE_NAME="$2"
EXTRUDER_KP="$3"
EXTRUDER_KI="$4"
EXTRUDER_KD="$5"
BED_KP="$6"
BED_KI="$7"
BED_KD="$8"

# Write the PID profile file
{
  echo "# ${PROFILE_NAME} PID Profile"
  echo "[extruder]"
  echo "control: pid"
  echo "pid_kp: ${EXTRUDER_KP}"
  echo "pid_ki: ${EXTRUDER_KI}"
  echo "pid_kd: ${EXTRUDER_KD}"
  echo ""
  echo "[heater_bed]"
  echo "control: pid"
  echo "pid_kp: ${BED_KP}"
  echo "pid_ki: ${BED_KI}"
  echo "pid_kd: ${BED_KD}"
} > "${OUTPUT_FILE}"

# Exit successfully
exit 0