# Definitive Guide to the Klipper Dynamic PID Profile System

This guide provides a comprehensive walkthrough for setting up and using a powerful, automated PID profile management system for your Klipper-based 3D printer. This system allows you to create, store, and dynamically load different PID tuning profiles based on filament type and specific printing temperatures, ensuring optimal print quality and consistency without manual intervention.

---

## Table of Contents

1. [Why Use a PID Profile System?](#why-use-a-pid-profile-system)
2. [The Core Concept](#the-core-concept)
3. [Step 1: The Helper Script](#step-1-the-helper-script)
4. [Step 2: Initial Configuration & File Structure](#step-2-initial-configuration--file-structure)
5. [Step 3: The Automation Macros Explained](#step-3-the-automation-macros-explained)
6. [Step 4: The Complete Workflow for Creating a New Profile](#step-4-the-complete-workflow-for-creating-a-new-profile)
7. [Step 5: Loading Profiles - Manual & Automatic](#step-5-loading-profiles---manual--automatic)
8. [Step 6: Final File Structure](#step-6-final-file-structure)

---

## Why Use a PID Profile System?

Different filament materials (like PLA, ASA, PETG, ABS) require unique PID tuning values for stable hotend and bed temperatures. Manually running `PID_CALIBRATE` and saving the configuration for every switch is tedious and error-prone.

**This system solves that by:**

- **Maximizing Quality:** Ensures your heaters are perfectly tuned for the specific conditions of every print.
- **Saving Time:** Eliminates the need to re-run PID calibrations.
- **Automating Workflow:** Integrates directly with your slicer to load the correct profile automatically at the start of a print.
- **Improving Reliability:** Uses a dedicated shell script to avoid complex G-Code macro parsing errors.

---

## The Core Concept

The system works by externalizing the PID settings from your main `printer.cfg`.

1. Create a dedicated directory (`printer_data/config/pid_tunes/`) to store an unlimited number of PID profiles.
2. A helper script (`save_pid_profile.sh`) handles the file writing, which is more robust than using macros alone.
3. Your `printer.cfg` is modified to include a generic, temporary file: `pid_current.cfg`.
4. A set of powerful macros automates the creation, loading, and cleanup of these profiles by calling the helper script and managing files.

---

## Step 1: The Helper Script

First, create a small shell script to handle the logic of writing the PID profiles. This is more stable than putting complex commands inside a Klipper macro.

1. **Create the Scripts Directory:**  
   From your main project directory (e.g., `AI-M8P-CB1-E3MAX-main`), run:
   ```bash
   mkdir -p printer_data/scripts
   ```

2. **Create the Script File:**  
   ```bash
   nano printer_data/scripts/save_pid_profile.sh
   ```

3. **Paste the Script Code:**  
   Copy and paste the following:
   ```bash
   #!/bin/bash

   # Script to save PID profiles for Klipper
   # Arguments:
   # $1: Full path to the output file
   # $2: Profile Name
   # $3: Extruder Kp
   # $4: Extruder Ki
   # $5: Extruder Kd
   # $6: Bed Kp
   # $7: Bed Ki
   # $8: Bed Kd

   OUTPUT_FILE="$1"
   PROFILE_NAME="$2"
   EXTRUDER_KP="$3"
   EXTRUDER_KI="$4"
   EXTRUDER_KD="$5"
   BED_KP="$6"
   BED_KI="$7"
   BED_KD="$8"

   eval OUTPUT_FILE_EXPANDED="${OUTPUT_FILE}"

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
   } > "${OUTPUT_FILE_EXPANDED}"

   exit 0
   ```
   Save and exit (`Ctrl+X`, then `Y`, then `Enter`).

4. **Make the Script Executable:**  
   ```bash
   chmod +x printer_data/scripts/save_pid_profile.sh
   ```

---

## Step 2: Initial Configuration & File Structure

Prepare the Klipper configuration directories.

1. **Create the PID Tunes Directory:**  
   ```bash
   mkdir -p printer_data/config/pid_tunes
   ```

2. **Create the Current PID File:**  
   ```bash
   touch printer_data/config/pid_current.cfg
   ```

3. **Modify `printer.cfg`:**  
   - Open `printer_data/config/printer.cfg`.
   - Find the `[extruder]` and `[heater_bed]` sections.
   - **Delete or comment out** the existing `control`, `pid_kp`, `pid_ki`, and `pid_kd` lines from both sections.
   - Near the top of `printer.cfg`, add:
     ```ini
     [include pid_current.cfg]
     ```

4. **Create the Macro File:**  
   Create `printer_data/config/macros/pid_loader.cfg`.

5. **Update `macros_includes.cfg`:**  
   Add to `printer_data/config/macros/macros_includes.cfg`:
   ```ini
   [include pid_loader.cfg]
   ```
   After these changes, **Save & Restart** Klipper.

---

## Step 3: The Automation Macros Explained

Copy and paste the following into `printer_data/config/macros/pid_loader.cfg`:

```ini
# Klipper Dynamic PID Profile System Macros

[gcode_macro SAVE_PID_TO_PROFILE]
description: Saves current PID values to a profile and cleans the printer.cfg.
gcode:
    {% set filament = params.FILAMENT|default("pla")|string|lower %}
    {% set bed_temp = params.BED_TEMP|default(60)|int %}
    {% set extruder_temp = params.EXTRUDER_TEMP|default(210)|int %}
    
    {% set bed_temp_str = "%03d"|format(bed_temp) %}
    {% set extruder_temp_str = "%03d"|format(extruder_temp) %}

    {% set profile_name = "pid_" + filament + "_" + bed_temp_str + "_" + extruder_temp_str %}
    {% set filename = profile_name + ".cfg" %}
    
    {% set script_path = "~/printer_data/scripts/save_pid_profile.sh" %}
    {% set full_path = "~/printer_data/config/pid_tunes/" + filename %}
    
    {% set extruder_pid = printer.configfile.settings.extruder %}
    {% set bed_pid = printer.configfile.settings.heater_bed %}

    {action_respond_info("Saving PID values to " + filename)}

    {action_call_remote_method(
        "run_shell_command",
        command=script_path ~ " " ~ full_path ~ " " ~ profile_name ~ " " ~ extruder_pid.pid_kp ~ " " ~ extruder_pid.pid_ki ~ " " ~ extruder_pid.pid_kd ~ " " ~ bed_pid.pid_kp ~ " " ~ bed_pid.pid_ki ~ " " ~ bed_pid.pid_kd
    )}

    {action_respond_info("Profile " + filename + " has been saved.")}
    
    {action_respond_info("Automatically cleaning temporary PID values from printer.cfg.")}
    CLEAN_PRINTER_CFG

[gcode_macro LOAD_PID_PROFILE]
description: Loads a PID profile based on filament, bed, and extruder temps.
gcode:
    {% set filament = params.FILAMENT|default("pla")|string|lower %}
    {% set bed_temp = params.BED_TEMP|default(60)|int %}
    {% set extruder_temp = params.EXTRUDER_TEMP|default(210)|int %}

    {% set bed_temp_str = "%03d"|format(bed_temp) %}
    {% set extruder_temp_str = "%03d"|format(extruder_temp) %}
    
    {% set filename = "pid_" + filament + "_" + bed_temp_str + "_" + extruder_temp_str + ".cfg" %}

    {action_respond_info("Attempting to load PID profile: " + filename)}
    
    {action_call_remote_method("run_shell_command",
                               command="cp ~/printer_data/config/pid_tunes/" + filename + " ~/printer_data/config/pid_current.cfg")}
    
    M117 {filename} loaded. Restarting...
    RESTART

[gcode_macro CLEAN_PRINTER_CFG]
description: Removes ONLY the PID settings from the SAVE_CONFIG block in printer.cfg.
gcode:
    {action_respond_info("Cleaning PID-specific lines from the SAVE_CONFIG block...")}
    {action_call_remote_method(
        "run_shell_command",
        command="sed -i -e '/^#\\*# \\[extruder\\]/d' -e '/^#\\*# \\[heater_bed\\]/d' -e '/^#\\*# control = pid/d' -e '/^#\\*# pid_kp = /d' -e '/^#\\*# pid_ki = /d' -e '/^#\\*# pid_kd = /d' ~/printer_data/config/printer.cfg"
    )}
    {action_respond_info("PID sections have been cleaned from printer.cfg. Other saved values are preserved.")}
```

---

## Step 4: The Complete Workflow for Creating a New Profile

1. **Run PID Calibrations:**  
   In the console, run PID_CALIBRATE for both the extruder and the bed at your desired target temperatures.  
   Example for ASA at 260°C extruder and 105°C bed:
   ```
   PID_CALIBRATE HEATER=extruder TARGET=260
   PID_CALIBRATE HEATER=heater_bed TARGET=105
   ```

2. **Save to Klipper's Configuration:**  
   After each calibration, run:
   ```
   SAVE_CONFIG
   ```

3. **Create the Permanent Profile & Auto-Clean:**  
   Once the printer is back online, run:
   ```
   SAVE_PID_TO_PROFILE FILAMENT=asa BED_TEMP=105 EXTRUDER_TEMP=260
   ```

---

## Step 5: Loading Profiles - Manual & Automatic

### 5.1 Manual Loading via Command Line

You can always load a profile manually:
```
LOAD_PID_PROFILE FILAMENT=asa BED_TEMP=105 EXTRUDER_TEMP=260
```

### 5.2 Manual Loading via UI Buttons

For frequently used profiles, create dashboard buttons.

- Edit `pid_loader.cfg` and add a macro for each button:
  ```ini
  [gcode_macro LOAD_TPU_060_230]
  description: Load the PID profile for TPU @ 60C Bed, 230C Extruder
  gcode:
      LOAD_PID_PROFILE FILAMENT=tpu BED_TEMP=60 EXTRUDER_TEMP=230
  ```
- Save and restart Klipper.

### 5.3 Automatic Slicer Integration (Recommended)

Add the `LOAD_PID_PROFILE` command to your slicer's "Start G-code" section.

**Example for PrusaSlicer / SuperSlicer / OrcaSlicer:**  
Place this line in your "Start G-code", ideally before any heating commands:
```
LOAD_PID_PROFILE FILAMENT={filament_type} BED_TEMP={first_layer_bed_temperature} EXTRUDER_TEMP={first_layer_temperature}
```
Now, the slicer will automatically tell Klipper to load the correct PID profile for every print.

---

## Step 6: Final File Structure

After setup, your Klipper config directory should look like this:

```
printer_data/
├── config/
│   ├── printer.cfg
│   ├── moonraker.conf
│   ├── mainsail.cfg
│   ├── pid_current.cfg         # The temporary file Klipper loads
│   ├── hardware/
│   │   └── ...
│   ├── macros/
│   │   ├── macros_includes.cfg
│   │   └── pid_loader.cfg      # Contains ALL PID system macros
│   └── pid_tunes/              # Your permanent profile library
│       ├── pid_asa_105_260.cfg
│       └── pid_pla_060_210.cfg
└── scripts/
    └── save_pid_profile.sh     # The essential helper script
```