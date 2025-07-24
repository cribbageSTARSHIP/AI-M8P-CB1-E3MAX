# Definitive Guide to the Klipper Dynamic PID Profile System

This guide provides a comprehensive walkthrough for setting up and using a powerful, automated PID profile management system for your Klipper-based 3D printer. This system allows you to create, store, and dynamically load different PID tuning profiles based on filament type and specific printing temperatures, ensuring optimal print quality and consistency without manual intervention.

## Table of Contents

1. [Why Use This System?](#why-use-this-system)
2. [The Core Concept](#the-core-concept)
3. [Step 1: The Helper Scripts](#step-1-the-helper-scripts)
4. [Step 2: Initial Configuration & File Structure](#step-2-initial-configuration--file-structure)
5. [Step 3: The Automation Macros Explained](#step-3-the-automation-macros-explained)
6. [Step 4: The Complete Workflow for Creating a New Profile](#step-4-the-complete-workflow-for-creating-a-new-profile)
7. [Step 5: Loading Profiles - Manual & Automatic](#step-5-loading-profiles---manual--automatic)
8. [Step 6: Final File Structure](#step-6-final-file-structure)

---

## Why Use This System?

Different filament materials (like PLA, ASA, PETG, ABS) require unique PID tuning values for stable hotend and bed temperatures. Manually running `PID_CALIBRATE` and saving the configuration for every switch is tedious and error-prone.

This system solves that by:

- **Maximizing Quality:** Ensures your heaters are perfectly tuned for the specific conditions of every print.
- **Saving Time:** Eliminates the need to re-run PID calibrations.
- **Automating Workflow:** Integrates directly with your slicer to load the correct profile automatically at the start of a print.
- **Improving Reliability:** Uses dedicated shell scripts for all file operations to avoid complex G-Code macro parsing errors.

---

## The Core Concept

The system works by externalizing the PID settings from your main `printer.cfg`. The core principle is **"macros call scripts"** for maximum stability.

1. Create a dedicated directory (`printer_data/config/pid_tunes/`) to store an unlimited number of PID profiles.
2. Two helper scripts (`save_pid_profile.sh` and `clean_printer_cfg.sh`) handle all file writing and editing.
3. Your `printer.cfg` is modified to include a generic, temporary file: `pid_current.cfg`.
4. A set of powerful macros automates the creation, loading, and cleanup of these profiles by calling the helper scripts.

---

## Step 1: The Helper Scripts

First, we create two small shell scripts to handle the file operations. This is far more stable than putting complex commands inside Klipper macros.

1. **Create the Scripts Directory:**  
   From your main project directory (e.g., `AI-M8P-CB1-E3MAX-main`), run the following command in your printer's SSH terminal:
   ```bash
   mkdir -p printer_data/scripts
   ```

2. **Create the `save_pid_profile.sh` Script:**  
   ```bash
   nano printer_data/scripts/save_pid_profile.sh
   ```
   Paste the following code into the editor:
   ```bash
   #!/bin/bash
   # Script to save PID profiles for Klipper
   OUTPUT_FILE="$1"; PROFILE_NAME="$2"; EXTRUDER_KP="$3"; EXTRUDER_KI="$4"; EXTRUDER_KD="$5"; BED_KP="$6"; BED_KI="$7"; BED_KD="$8"
   eval OUTPUT_FILE_EXPANDED="${OUTPUT_FILE}"
   {
     echo "# ${PROFILE_NAME} PID Profile"; echo "[extruder]"; echo "control: pid"; echo "pid_kp: ${EXTRUDER_KP}"; echo "pid_ki: ${EXTRUDER_KI}"; echo "pid_kd: ${EXTRUDER_KD}";
     echo ""; echo "[heater_bed]"; echo "control: pid"; echo "pid_kp: ${BED_KP}"; echo "pid_ki: ${BED_KI}"; echo "pid_kd: ${BED_KD}";
   } > "${OUTPUT_FILE_EXPANDED}"
   exit 0
   ```
   Save and exit (`Ctrl+X`, `Y`, `Enter`).

3. **Create the `clean_printer_cfg.sh` Script:**  
   ```bash
   nano printer_data/scripts/clean_printer_cfg.sh
   ```
   Paste this code into the editor:
   ```bash
   #!/bin/bash
   # This script removes the temporary PID sections from the bottom of printer.cfg
   if [ -d "$HOME/printer_data/config" ]; then CONFIG_FILE="$HOME/printer_data/config/printer.cfg"; elif [ -d "$HOME/klipper_config" ]; then CONFIG_FILE="$HOME/klipper_config/printer.cfg"; else echo "Error: Klipper config not found." && exit 1; fi
   sed -i -e '/^#\*# \[extruder\]/d' -e '/^#\*# \[heater_bed\]/d' -e '/^#\*# control = pid/d' -e '/^#\*# pid_kp = /d' -e '/^#\*# pid_ki = /d' -e '/^#\*# pid_kd = /d' "$CONFIG_FILE"
   exit 0
   ```
   Save and exit (`Ctrl+X`, `Y`, `Enter`).

4. **Make Both Scripts Executable:**  
   ```bash
   chmod +x printer_data/scripts/save_pid_profile.sh
   chmod +x printer_data/scripts/clean_printer_cfg.sh
   ```

---

## Step 2: Initial Configuration & File Structure

Now, we prepare the Klipper configuration directories.

1. **Create the PID Tunes Directory:**  
   ```bash
   mkdir -p printer_data/config/pid_tunes
   ```

2. **Create the Current PID File:**  
   ```bash
   touch printer_data/config/pid_current.cfg
   ```

3. **Modify `printer.cfg`:**  
   Open your `printer_data/config/printer.cfg` file.
   - Find the `[extruder]` and `[heater_bed]` sections.
   - **Delete or comment out** the existing `control`, `pid_kp`, `pid_ki`, and `pid_kd` lines from both sections.
   - Near the top of `printer.cfg` (with other includes), add this line:
     ```ini
     [include pid_current.cfg]
     ```

4. **Create and Include the Macro File:**  
   Create a new file at `printer_data/config/macros/calibration/pid_loader.cfg`.  
   Then, add the following line to your `printer_data/config/macros/macros_includes.cfg` to ensure Klipper loads it:
   ```ini
   [include pid_loader.cfg]
   ```
   After these changes, **Save & Restart** Klipper.

---

## Step 3: The Automation Macros Explained

Copy and paste the entire code block below into your new `printer_data/config/macros/calibration/pid_loader.cfg` file. This version uses dynamic paths (`~/`) which Klipper will automatically resolve to the correct home directory for the scripts.

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
        command="bash ~/printer_data/scripts/clean_printer_cfg.sh"
    )}
    {action_respond_info("PID sections have been cleaned from printer.cfg. Other saved values are preserved.")}
```

---

## Step 4: The Complete Workflow for Creating a New Profile

1. **Run PID Calibrations:**  
   In the console, run PID_CALIBRATE for both the extruder and the bed at your desired target temperatures.  
   Example for ASA at 260°C extruder and 105°C bed:
   ```gcode
   PID_CALIBRATE HEATER=extruder TARGET=260
   PID_CALIBRATE HEATER=heater_bed TARGET=105
   ```

2. **Save to Klipper's Configuration:**  
   After each successful calibration, you must run:
   ```gcode
   SAVE_CONFIG
   ```

3. **Create the Permanent Profile & Auto-Clean:**  
   Once the printer is back online, run a single command. This will create your permanent file and automatically clean printer.cfg.
   ```gcode
   SAVE_PID_TO_PROFILE FILAMENT=asa BED_TEMP=105 EXTRUDER_TEMP=260
   ```

---

## Step 5: Loading Profiles - Manual & Automatic

### 5.1 Manual Loading via Command Line

You can always load a profile manually by typing the `LOAD_PID_PROFILE` command directly into the console:

```gcode
LOAD_PID_PROFILE FILAMENT=asa BED_TEMP=105 EXTRUDER_TEMP=260
```

### 5.2 Manual Loading via UI Buttons

For your most frequently used profiles, creating a dashboard button is convenient.

- **Edit `pid_loader.cfg`:** Open your `printer_data/config/macros/calibration/pid_loader.cfg` file.
- **Add a Button Macro:** Add a new `[gcode_macro]` for each button you want.  
  Example for a new TPU profile:
  ```ini
  [gcode_macro LOAD_TPU_060_230]
  description: Load the PID profile for TPU @ 60C Bed, 230C Extruder
  gcode:
      LOAD_PID_PROFILE FILAMENT=tpu BED_TEMP=60 EXTRUDER_TEMP=230
  ```
- **Save and Restart:** Your new buttons will appear on the dashboard.

### 5.3 Automatic Slicer Integration (Recommended)

This is the most powerful method. Add the `LOAD_PID_PROFILE` command to your slicer's "Start G-code" section.

**Example for PrusaSlicer / SuperSlicer / OrcaSlicer:**  
Place this line in your "Start G-code", ideally before any heating commands:

```gcode
LOAD_PID_PROFILE FILAMENT={filament_type} BED_TEMP={first_layer_bed_temperature} EXTRUDER_TEMP={first_layer_temperature}
```

Now, the slicer will automatically tell Klipper to load the correct PID profile for every print.

---

## Step 6: Final File Structure

After setup, your Klipper config directory should have this clean, modular, and robust structure:

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
    ├── save_pid_profile.sh     # The script that writes new profiles
    └── clean_printer_cfg.sh    # The script that cleans printer.cfg
```