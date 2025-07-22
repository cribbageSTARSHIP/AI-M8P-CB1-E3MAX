Below is an exerpt from one of our earlier conversations. It discusses how to use the klipper-z_calibration plugin to save the various z offsets I have for various different temps. 

***start exerpt
1.Managing Z-Offset (The Easy Way)

This is the most common requirement, especially when you switch between different build surfaces (e.g., a textured PEI sheet and a smooth PEX sheet) that have slightly different thicknesses.

Solution: klipper-z_calibration Plugin

The community has a standard and highly recommended solution for this. It's a Klipper extension that adds G-code commands to save and load Z-offset profiles on demand.

How it Works:

    Install it: You can easily install the klipper-z_calibration utility via KIAUH (Klipper Installation And Update Helper) if you used that to set up your printer.

    Calibrate & Save: You calibrate your Z-offset once for each build surface, then save it with a unique name using a command in the console.

        SAVE_Z_OFFSET NAME=textured_sheet

        SAVE_Z_OFFSET NAME=smooth_sheet

    Create Macros: In your printer.cfg, you create simple macros to load these profiles.

Example Macros for printer.cfg:
Ini, TOML

[gcode_macro SET_SURFACE_TEXTURED]
gcode:
    LOAD_Z_OFFSET NAME=textured_sheet
    M117 Z-Offset for Textured Sheet Loaded

[gcode_macro SET_SURFACE_SMOOTH]
gcode:
    LOAD_Z_OFFSET NAME=smooth_sheet
    M117 Z-Offset for Smooth Sheet Loaded

Now, before a print, you can just run SET_SURFACE_TEXTURED in the console or your slicer's start G-code, and the correct Z-offset is loaded instantly.

***end exerpt

One thing I'd like to change would be the naming convention for "LOAD_Z_OFFSET NAME=". for example, if I'm using PLA on a textured PEI sheet it would say "LOAD_Z_OFFSET NAME=PLA_textured_PEI". Another example would be ASA on a smooth piece of glass "LOAD_Z_OFFSET NAME=ASA_smooth_glass"

Also, cam I install it from github and moonraker instead of using KIAUH ?

Of course. Let's break down your two questions. You've got the right idea on both fronts—making your workflow more descriptive and managing your installation without KIAUH are excellent steps.

Part 1: Using Your New Naming Convention

Yes, absolutely. The NAME= parameter in the SAVE_Z_OFFSET and LOAD_Z_OFFSET commands is just a text label. You can name your profiles whatever you want, and your proposed convention of combining the filament and surface type is a fantastic way to keep things organized.

Here is the exact workflow to create and use your new, descriptive profiles:

Step 1: Heat the Printer
For the most accurate Z-offset, always heat your bed and nozzle to the temperatures you will use for that specific material.

    For a PLA profile, heat the nozzle to your PLA print temp and the bed to your PLA bed temp.

    For an ASA profile, heat both to your higher ASA temperatures.

    1.1 pid tune bed: PID_CALIBRATE HEATER=heater_bed TARGET=105 then SAVE_CONFIG

PID parameters: pid_Kp=70.454 pid_Ki=1.039 pid_Kd=1194.202
The SAVE_CONFIG command will update the printer config file
with these parameters and restart the printer.

    1.2 pid tune hotend with 10% fan: PID_CALIBRATE HEATER=extruder TARGET=250 FAN_SPEED=0.1 the SAVE_CONFIG

PID parameters: pid_Kp=22.474 pid_Ki=0.999 pid_Kd=126.416
The SAVE_CONFIG command will update the printer config file
with these parameters and restart the printer.

Step 2: Calibrate and Save
Perform your Z-offset calibration as you normally would. Once you have the perfect first layer "squish", go to the Klipper console and save it using your new naming scheme.

    To save your PLA on textured PEI profile:

    SAVE_Z_OFFSET NAME=PLA_TEXTURED_PEI

    To save your ASA on smooth glass profile:

    SAVE_Z_OFFSET NAME=ASA_SMOOTH_GLASS

    (Repeat this process for every combination of filament and build surface you use.)


    2.1 SAVE_Z_OFFSET NAME=ASA_105_250_SMOOTH_PEI

Step 3: Create Corresponding Macros in printer.cfg
Now, create macros that use these new descriptive names. This makes loading them intuitive.
Ini, TOML

[gcode_macro SET_PROFILE_PLA_TEXTURED]
gcode:
    LOAD_Z_OFFSET NAME=PLA_textured_PEI
    M117 Profile for PLA on Textured PEI Loaded

[gcode_macro SET_PROFILE_ASA_GLASS]
gcode:
    LOAD_Z_OFFSET NAME=ASA_smooth_glass
    M117 Profile for ASA on Smooth Glass Loaded

Now, before a print, you just run the corresponding macro (e.g., SET_PROFILE_PLA_TEXTURED) and the exact Z-offset for that scenario is loaded instantly.

Part 2: Installing with GitHub and Moonraker

Yes, you can absolutely install it using a manual git clone and then manage it with Moonraker's Update Manager. This is how many users manage their Klipper extensions.

Here are the steps:

Step 1: SSH into your Raspberry Pi
Connect to your Pi's command line using a tool like Terminal or PuTTY.

Step 2: Download the Plugin Files
Run the following command to download the klipper-z_calibration plugin into its own folder in your home directory:
Bash

git clone https://github.com/protoloft/klipper-z_calibration.git ~/klipper-z_calibration

Step 3: Configure Moonraker to Manage It
Now, let's tell Moonraker's Update Manager about this new plugin.

    In the Mainsail interface, go to the "Machine" tab and open your moonraker.conf file.

    Add the following block of code to the end of the file:
    Ini, TOML

    [update_manager z_calibration]
    type: git_repo
    path: ~/klipper-z_calibration
    origin: https://github.com/protoloft/klipper-z_calibration.git
    install_script: ~/klipper-z_calibration/install.sh

        path: Must exactly match the location where you just cloned the repository.

        install_script: This script creates a necessary link in your Klipper config directory.

Step 4: Include the Plugin in printer.cfg
The last step is to tell Klipper to actually use the plugin.

    Open your printer.cfg file.

    Add the following line, usually near your other [include] statements:
    Ini, TOML

    [include z_calibration.cfg]

Step 5: Save and Restart
Save both the moonraker.conf and printer.cfg files. It's best to perform a full system restart from the Mainsail power menu to ensure all services reload correctly.

After restarting, you can go to the "Settings" page in Mainsail (the wrench icon) and look under the "Update Manager" section. You should now see "z_calibration" listed, and you can update it from there in the future.

can you please print out the z_calibration.cfg again?

Of course. However, it's important to clarify what z_calibration.cfg is.

Unlike a static configuration file, z_calibration.cfg is a file that is dynamically created and updated by the plugin itself every time you run the SAVE_Z_OFFSET command. It's essentially the database where your saved profiles are stored.

You don't need to manually create or edit this file. You only need to [include z_calibration.cfg] in your printer.cfg.

That being said, I can show you an example of what your z_calibration.cfg file would look like after you have calibrated and saved the two profiles we discussed (PLA_textured_PEI and ASA_smooth_glass).

Example z_calibration.cfg

After you run your calibrations and save commands, a file named z_calibration.cfg will be created in your Klipper configuration directory. If you were to open it, it would look something like this:
Ini, TOML

# Klipper Z Calibration File
#
# This file is managed by the klipper-z-calibration plugin and should
# not be modified manually.

[z_calibration]
# ...internal plugin variables are stored here...

[gcode_macro _LOAD_Z_OFFSET]
rename_existing: _LOAD_Z_OFFSET_BASE
gcode:
    # ...internal logic for the plugin...


#--------------------------------------------------------------------
# Saved Z-Offset Profiles
#--------------------------------------------------------------------
[saved_offsets]
ASA_smooth_glass = -0.075
PLA_textured_PEI = -0.025

Key Things to Note:

    Managed by the Plugin: As the header says, you should not edit this file by hand.

    [saved_offsets] Section: This is the most important part for you to see. The plugin creates this section and adds a new line for every profile you save, mapping the NAME you provided to the calculated Z-offset value (e.g., -0.075).

    Your Values Will Differ: The actual numeric values (-0.075, -0.025) will be different for your specific printer, nozzle, and build surfaces.

You can view your own z_calibration.cfg file at any time by navigating to the "Machine" or "Configuration" tab in Mainsail, just as you would to view printer.cfg. It will appear in the file list after you save your first Z-offset profile.