# Definitive Guide to the Klipper Dynamic PID Profile System

This guide provides a comprehensive walkthrough for setting up and using a powerful, automated PID profile management system for your Klipper-based 3D printer. This system allows you to create, store, and dynamically load different PID tuning profiles based on filament type and specific printing temperatures, ensuring optimal print quality and consistency without manual intervention.

## Table of Contents

1.  [Why Use a PID Profile System?](https://www.google.com/search?q=%23why-use-a-pid-profile-system "null")
    
2.  [The Core Concept](https://www.google.com/search?q=%23the-core-concept "null")
    
3.  [Step 1: Initial Configuration & File Structure](https://www.google.com/search?q=%23step-1-initial-configuration--file-structure "null")
    
4.  [Step 2: The Automation Macros Explained](https://www.google.com/search?q=%23step-2-the-automation-macros-explained "null")
    
5.  [The "Why": Understanding the Cleanup Logic](https://www.google.com/search?q=%23the-why-understanding-the-cleanup-logic "null")
    
6.  [Step 3: The Complete Workflow for Creating a New Profile](https://www.google.com/search?q=%23step-3-the-complete-workflow-for-creating-a-new-profile "null")
    
7.  [Step 4: Loading Profiles - Manual & Automatic](https://www.google.com/search?q=%23step-4-loading-profiles---manual--automatic "null")
    
8.  [Step 5: Final File Structure](https://www.google.com/search?q=%23step-5-final-file-structure "null")
    

## Why Use a PID Profile System?

Different filament materials (like PLA, ASA, PETG, ABS) require unique PID tuning values for stable hotend and bed temperatures. Manually running `PID_CALIBRATE` and saving the configuration for every switch is tedious and error-prone.

This system solves that by:

*   **Maximizing Quality:** Ensures your heaters are perfectly tuned for the specific conditions of every print.
    
*   **Saving Time:** Eliminates the need to re-run PID calibrations.
    
*   **Automating Workflow:** Integrates directly with your slicer to load the correct profile automatically at the start of a print.
    

## The Core Concept

The system works by externalizing the PID settings from your main `printer.cfg`.

1.  We create a dedicated directory (`~/printer_data/config/pid_tunes/`) to store an unlimited number of PID profiles.
    
2.  Each profile is a simple `.cfg` file named with a clear convention: `pid_FILAMENT_BEDTEMP_HETEMP.cfg`.
    
3.  Your `printer.cfg` is modified to include a generic, temporary file: `pid_current.cfg`.
    
4.  A set of powerful macros automates the creation, loading, and cleanup of these profiles.
    

## Step 1: Initial Configuration & File Structure

First, we prepare the directory structure and modify the main `printer.cfg`.

1.  **Create the PID Tunes Directory:** Connect to your printer via SSH and run:
    
        mkdir -p ~/printer_data/config/pid_tunes
        
    
2.  **Create the Current PID File:** Now, create the empty placeholder file that Klipper will load:
    
        touch ~/printer_data/config/pid_current.cfg
        
    
3.  **Modify `printer.cfg`:** Open your `printer.cfg` file.
    
    *   Find the `[extruder]` and `[heater_bed]` sections.
        
    *   **Delete or comment out** the existing `control`, `pid_kp`, `pid_ki`, and `pid_kd` lines from both sections.
        
    *   Near the top of `printer.cfg` (with other includes), add this line:
        
    
        [include pid_current.cfg]
        
    
4.  **Create the Macro File:** Create a new, dedicated file for our macros at `~/printer_data/config/macros/pid_loader.cfg`.
    
5.  **Update `macros_includes.cfg`:** Add the following line to `~/printer_data/config/macros_includes.cfg` to ensure Klipper loads our new macro file on startup.
    
        [include macros/pid_loader.cfg]
        
    
    After these changes, **Save & Restart** Klipper.
    

## Step 2: The Automation Macros Explained

Copy and paste the entire code block below into your new `macros/pid_loader.cfg` file. This single file contains the core logic macros and the section for your manual dashboard buttons.

```bash

    # Klipper Dynamic PID Profile System Macros
    # This file contains the core logic for saving, loading, and cleaning PID profiles,
    # as well as the button definitions for the Mainsail UI.
    
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
        FIRMWARE_RESTART
    
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
        {% set extruder_pid = printer.configfile.settings.extruder %}
        {% set bed_pid = printer.configfile.settings.heater_bed %}
        {action_respond_info("Saving PID values to " + filename)}
        {action_call_remote_method(
            "run_shell_command",
            command=">" + " ~/printer_data/config/pid_tunes/" + filename + " && " +
                    "echo '# " + profile_name + " PID Profile' >> ~/printer_data/config/pid_tunes/" + filename + " && " +
                    "echo '[extruder]' >> ~/printer_data/config/pid_tunes/" + filename + " && " +
                    "echo 'control: pid' >> ~/printer_data/config/pid_tunes/" + filename + " && " +
                    "echo 'pid_kp: " ~ extruder_pid.pid_kp ~ "' >> ~/printer_data/config/pid_tunes/" + filename + " && " +
                    "echo 'pid_ki: " ~ extruder_pid.pid_ki ~ "' >> ~/printer_data/config/pid_tunes/" + filename + " && " +
                    "echo 'pid_kd: " ~ extruder_pid.pid_kd ~ "' >> ~/printer_data/config/pid_tunes/" + filename + " && " +
                    "echo '' >> ~/printer_data/config/pid_tunes/" + filename + " && " +
                    "echo '[heater_bed]' >> ~/printer_data/config/pid_tunes/" + filename + " && " +
                    "echo 'control: pid' >> ~/printer_data/config/pid_tunes/" + filename + " && " +
                    "echo 'pid_kp: " ~ bed_pid.pid_kp ~ "' >> ~/printer_data/config/pid_tunes/" + filename + " && " +
                    "echo 'pid_ki: " ~ bed_pid.pid_ki ~ "' >> ~/printer_data/config/pid_tunes/" + filename + " && " +
                    "echo 'pid_kd: " ~ bed_pid.pid_kd ~ "' >> ~/printer_data/config/pid_tunes/" + filename
        )}
        {action_respond_info("Profile " + filename + " has been saved.")}
        {action_respond_info("Automatically cleaning temporary PID values from printer.cfg.")}
        CLEAN_PRINTER_CFG
    
    [gcode_macro CLEAN_PRINTER_CFG]
    description: Removes ONLY the PID settings from the SAVE_CONFIG block in printer.cfg.
    gcode:
        {action_respond_info("Cleaning PID-specific lines from the SAVE_CONFIG block...")}
        {action_call_remote_method(
            "run_shell_command",
            command="sed -i -e '/^#\\*# \\[extruder\\]/d' -e '/^#\\*# \\[heater_bed\\]/d' -e '/^#\\*# control = pid/d' -e '/^#\\*# pid_kp = /d' -e '/^#\\*# pid_ki = /d' -e '/^#\\*# pid_kd = /d' ~/printer_data/config/printer.cfg"
        )}
        {action_respond_info("PID sections have been cleaned from printer.cfg. Other saved values are preserved.")}
    
    #####################################################################
    # Mainsail UI Buttons
    #####################################################################
    
    [gcode_macro LOAD_ASA_105_260]
    description: Load the PID profile for ASA @ 105C Bed, 260C Extruder
    gcode:
        LOAD_PID_PROFILE FILAMENT=asa BED_TEMP=105 EXTRUDER_TEMP=260
    
    [gcode_macro LOAD_PLA+_060_220]
    description: Load the PID profile for PLA+ @ 60C Bed, 220C Extruder
    gcode:
        LOAD_PID_PROFILE FILAMENT=pla+ BED_TEMP=60 EXTRUDER_TEMP=220
    
    [gcode_macro LOAD_PETG_085_240]
    description: Load the PID profile for PETG @ 85C Bed, 240C Extruder
    gcode:
        LOAD_PID_PROFILE FILAMENT=petg BED_TEMP=85 EXTRUDER_TEMP=240
```    

## The "Why": Understanding the Cleanup Logic

It is crucial to understand why the cleanup process is handled this way.

1.  **The Mess:** When you run `PID_CALIBRATE` and then `SAVE_CONFIG`, Klipper appends the new PID values to the bottom of your `printer.cfg`. These values are temporary; we only need them for a moment to capture them for our permanent profile.
    
2.  **The Task:** The job of `CLEAN_PRINTER_CFG` is to remove this temporary block.
    
3.  **The Wrong Way:** If we added `CLEAN_PRINTER_CFG` to the `LOAD_PID_PROFILE` macro, it would run at the start of **every single print**. This is inefficient and incorrect, as the `printer.cfg` is already clean 99% of the time.
    
4.  **The Right Way:** The mess is only created when you save a _new_ calibration. Therefore, the most logical place to clean up is immediately after you've finished saving that new calibration. By having `SAVE_PID_TO_PROFILE` automatically call `CLEAN_PRINTER_CFG`, we create a perfect, self-contained workflow: **Create the profile, then immediately clean up after yourself.**
    

## Step 3: The Complete Workflow for Creating a New Profile

1.  **Run PID Calibrations:** In the console, run `PID_CALIBRATE` for both the extruder and the bed at your desired target temperatures. _Example for ASA at 260°C extruder and 105°C bed:_

```bash    
        PID_CALIBRATE HEATER=extruder TARGET=260
        PID_CALIBRATE HEATER=heater_bed TARGET=105
```        
    
2.  **Save to Klipper's Configuration:** After each successful calibration, you **must** run `SAVE_CONFIG`. This saves the temporary values to `printer.cfg` and restarts Klipper.
```bash    
        SAVE_CONFIG
```        
    
3.  **Create the Permanent Profile & Auto-Clean:** Once the printer is back online, run a single command. This will create your permanent file and automatically clean `printer.cfg`.
```bash    
        SAVE_PID_TO_PROFILE FILAMENT=asa BED_TEMP=105 EXTRUDER_TEMP=260
```                    
    

## Step 4: Loading Profiles - Manual & Automatic

Once you have created one or more PID profiles, you can load them in three different ways.

### 4.1 Manual Loading via Command Line

You can always load a profile manually by typing the `LOAD_PID_PROFILE` command directly into the Mainsail console. This is useful for testing or for profiles you don't use often enough to create a button for.
```bash
    LOAD_PID_PROFILE FILAMENT=asa BED_TEMP=105 EXTRUDER_TEMP=260
```    

### 4.2 Manual Loading via Mainsail Buttons

For your most frequently used profiles, creating a dashboard button is the most convenient manual method.

1.  **Edit `pid_loader.cfg`:** Open your `~/printer_data/config/macros/pid_loader.cfg` file.
    
2.  **Add a Button Macro:** Scroll to the bottom, below the `### Mainsail UI Buttons ###` section. For each new profile, add a new `[gcode_macro]` that calls our main `LOAD_PID_PROFILE` command with the correct parameters. The name of the macro (e.g., `LOAD_ASA_105_260`) will become the name of the button.
    
    **To add a new button for a TPU profile tuned at 60°C bed and 230°C extruder, you would add:**
```bash    
        [gcode_macro LOAD_TPU_060_230]
        description: Load the PID profile for TPU @ 60C Bed, 230C Extruder
        gcode:
            LOAD_PID_PROFILE FILAMENT=tpu BED_TEMP=60 EXTRUDER_TEMP=230
```        
    
3.  **Save and Restart:** After adding your new button macro(s), **Save & Restart** Klipper. Your new buttons will appear on the Mainsail dashboard under the "Macros" section.
    

### 4.3 Automatic Slicer Integration (Recommended)

This is the most powerful and "set it and forget it" way to use the system. Add the `LOAD_PID_PROFILE` command to your slicer's "Start G-code" section.

**Example for PrusaSlicer / SuperSlicer / OrcaSlicer:** Place this line in your "Start G-code", ideally _before_ any heating commands.
```bash
    LOAD_PID_PROFILE FILAMENT={filament_type} BED_TEMP={first_layer_bed_temperature} EXTRUDER_TEMP={first_layer_temperature}
```    

Now, the slicer will automatically tell Klipper to load the correct PID profile for every print, even if you haven't made a specific button for it.

## Step 5: Final File Structure

After setup, your `~/printer_data/` directory should have this clean, modular structure:
```bash
    ~/printer_data/
    └── config/
        ├── printer.cfg
        ├── moonraker.conf
        ├── mainsail.cfg
        ├── macros_includes.cfg
        ├── pid_current.cfg         # The temporary file Klipper loads
        ├── macros/
        │   ├── core_print.cfg
        │   ├── filament_handling.cfg
        │   └── pid_loader.cfg      # Contains ALL PID system macros and buttons
        └── pid_tunes/              # Your permanent profile library
            ├── pid_asa_105_260.cfg
            ├── pid_pla+_060_220.cfg
            └── pid_petg_085_240.cfg
```            
