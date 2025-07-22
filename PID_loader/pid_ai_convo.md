Earlier we spoke about automating the switching of various PID tunes. below is the exerpt:
 
START exerpt
 
2. Managing PID Tuning (The Advanced Way)
 
This is more complex because PID values are loaded when Klipper starts. You can't change them on-the-fly like a Z-offset. However, you can automate switching between them.
 
The "Good Enough" Method: For many users, a single PID tune performed at a medium temperature (e.g., 230°C for the hotend) provides stable enough performance across a range of materials like PLA and PETG. Unless you see significant temperature instability when switching materials, you may not need to go further.
 
The "Profile" Method: For maximum precision (e.g., switching between PLA at 210°C and ASA at 260°C), you can create separate configuration files and use a macro to select one and restart Klipper.
 
Step 1: Create Separate PID Config Files
In your Klipper config directory, create files like pid_pla.cfg and pid_asa.cfg.
 
    pid_pla.cfg contents:
    Ini, TOML
 
# PID Values for PLA
[extruder]
control: pid
pid_kp: 21.8
pid_ki: 1.05
pid_kd: 79.4
 
pid_asa.cfg contents:
Ini, TOML
 
    # PID Values for ASA
    [extruder]
    control: pid
    pid_kp: 24.1
    pid_ki: 1.25
    pid_kd: 86.2
 
Step 2: Modify printer.cfg
In your main printer.cfg, remove your existing [extruder] PID lines and add an [include] for a generic file that we will overwrite.
Ini, TOML
 
# In printer.cfg
# ... your other extruder settings ...
# control: pid  <-- Comment out or delete old PID lines
# pid_kp: ...
# pid_ki: ...
# pid_kd: ...
 
[include pid_current.cfg]
 
Step 3: Create the Profile-Switching Macros
These macros copy the desired profile over pid_current.cfg and then restart the firmware to apply the change. The restart takes about 20-30 seconds.
Ini, TOML
 
[gcode_macro SET_PID_PROFILE_ASA]
gcode:
    {action_call_remote_method("run_shell_command",
                               command="cp ~/printer_data/config/pid_asa.cfg ~/printer_data/config/pid_current.cfg")}
    M117 Switched to ASA PID profile. Restarting...
    FIRMWARE_RESTART
 
[gcode_macro SET_PID_PROFILE_PLA]
gcode:
    {action_call_remote_method("run_shell_command",
                               command="cp ~/printer_data/config/pid_pla.cfg ~/printer_data/config/pid_current.cfg")}
    M117 Switched to PLA PID profile. Restarting...
    FIRMWARE_RESTART
 
Note: Your path ~/printer_data/config/ may be different (e.g., ~/klipper_config/). Adjust the commands accordingly.
 
Summary Workflow
 
By combining these methods, you create a powerful, semi-automated system:
 
    Switching to ASA? Run SET_PID_PROFILE_ASA in the console. Wait 30 seconds for the restart.
 
    Starting your print? Your slicer's start G-code should contain SET_SURFACE_TEXTURED (or whichever surface you use for ASA) to load the correct Z-offset.
 
This setup requires a one-time configuration but completely eliminates the need for manual recalibration for your different printing scenarios.
 
END exerpt
 
It sounds like a good idea, but I want to store all of the various pid tunes (e.g. pid_pla.cfg) in ~/printer_data/config/pid_tunes. can we do that? explain the process from install to endstate.
 
Of course. Using a subdirectory for your PID tune profiles is an excellent organizational strategy. It keeps your main Klipper configuration directory clean and easy to navigate.
 
Here is the complete, end-to-end process to set this up, adapting the previous method to use your desired ~/printer_data/config/pid_tunes/ folder.
 
Prerequisites: Get Your PID Values
 
Before you begin, you need to have the actual PID values for each filament type. If you haven't done this yet, run the PID_CALIBRATE command for each scenario.
 
    For ASA: Heat your bed to its printing temp, then run:
    G-Code
 
PID_CALIBRATE HEATER=extruder TARGET=250
 
Note down the final pid_kp, pid_ki, and pid_kd values.
 
For PLA: Heat your bed to its printing temp, then run:
G-Code
 
    PID_CALIBRATE HEATER=extruder TARGET=210
 
    Note down these values as well.
 
You should perform this for both your extruder and heater_bed.
 
Step 1: Create the Subdirectory
 
First, we need to create the folder where your profiles will live.
 
    SSH into your Raspberry Pi using Terminal or PuTTY.
 
    Run the following command. This creates a new directory named pid_tunes inside your Klipper config folder.
    Bash
 
    mkdir ~/printer_data/config/pid_tunes
 
    Note: If your config folder is located at ~/klipper_config, use that path instead.
 
Step 2: Create the PID Profile Files
 
Now, using the Mainsail or Fluidd editor, you will create the new configuration files inside the pid_tunes folder.
 
    In the Mainsail "Configuration" file browser, navigate into your new pid_tunes directory.
 
    Create a new file named pid_asa.cfg.
 
    Paste the PID values you calibrated for ASA into this file. It should look like this:
    Ini, TOML
 
    # /pid_tunes/pid_asa.cfg
 
    [extruder]
    control: pid
    pid_kp: 24.1  # <-- Your calibrated value
    pid_ki: 1.25  # <-- Your calibrated value
    pid_kd: 86.2  # <-- Your calibrated value
 
    [heater_bed]
    control: pid
    pid_kp: 68.4  # <-- Your calibrated value
    pid_ki: 1.1   # <-- Your calibrated value
    pid_kd: 275.9 # <-- Your calibrated value
 
    Create another new file in the same directory named pid_pla.cfg and paste your PLA values into it.
 
Step 3: Modify printer.cfg
 
Now we'll tell Klipper to stop using its built-in PID values and instead use a temporary file that our macros will manage.
 
    Open your main printer.cfg file.
 
    Find the [extruder] and [heater_bed] sections.
 
    Comment out or delete the control: pid, pid_kp, pid_ki, and pid_kd lines from both sections.
 
    Add the following line to your printer.cfg. A good place is near your other [include] statements.
    Ini, TOML
 
    # In printer.cfg
 
    [include pid_current.cfg]
 
Step 4: Create the Profile-Switching Macros
 
This is the final step. These macros will copy the correct profile from your pid_tunes folder and make it the "current" one, then restart Klipper to apply it.
 
Add the following macros to your printer.cfg (or a macros.cfg file if you use one).
G-Code
 
[gcode_macro SET_PID_PROFILE_ASA]
gcode:
    {action_call_remote_method("run_shell_command",
                               command="cp ~/printer_data/config/pid_tunes/pid_asa.cfg ~/printer_data/config/pid_current.cfg")}
    M117 Switched to ASA PID profile. Restarting...
    FIRMWARE_RESTART
 
[gcode_macro SET_PID_PROFILE_PLA]
gcode:
    {action_call_remote_method("run_shell_command",
                               command="cp ~/printer_data/config/pid_tunes/pid_pla.cfg ~/printer_data/config/pid_current.cfg")}
    M117 Switched to PLA PID profile. Restarting...
    FIRMWARE_RESTART
 
Important: Notice the path in the command now includes your pid_tunes/ subdirectory. Remember to adjust ~/printer_data/config/ if your path is different.
 
After adding these macros, click Save & Restart.
 
End-State and Final Workflow
 
Your setup is now complete. Your configuration directory is neatly organized, and switching between PID profiles is a single command.
 
Your workflow is now:
 
    Changing filament from PLA to ASA? Go to the Klipper console and run:
 
    SET_PID_PROFILE_ASA
 
    Wait 20-30 seconds for Klipper to restart.
 
    Load your filament and start your print. The printer is now perfectly tuned for ASA's temperatures.
 
Repeat the process with SET_PID_PROFILE_PLA when you switch back to PLA. You have successfully automated your PID management.
 