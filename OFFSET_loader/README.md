# Guide: Managing Z-Offsets with the klipper-z_calibration Plugin

This guide provides a comprehensive walkthrough for installing, configuring, and using the `klipper-z_calibration` plugin. This powerful tool allows you to save and load different Z-offset profiles, which is essential when printing with various materials and build surfaces that require unique first-layer heights.

---

## 1. Purpose of This System

Different filaments and build surfaces often require slightly different Z-offsets for a perfect first layer. For example, the ideal offset for PLA on a textured PEI sheet will be different from ASA on a smooth glass plate. This plugin allows you to calibrate the offset for each combination once, save it with a descriptive name, and load it instantly before a print.

**Naming convention:**  
`MATERIAL_SURFACE_TEMP` (e.g., `ASA_GLASS_250`)

---

## 2. Manual Installation (GitHub & Moonraker)

This method allows you to install the plugin without KIAUH and manage it directly through Moonraker's Update Manager.

### Step 2.1: SSH into your Host Device

Connect to your BTT CB1 (or Raspberry Pi) via an SSH terminal (e.g., PuTTY or Terminal).

### Step 2.2: Download the Plugin

Run the following commands to ensure you are in your home directory and then download the plugin's files from GitHub into a new folder:

```sh
cd ~
git clone https://github.com/protoloft/klipper_z_calibration.git ~/klipper-z_calibration
```

### Step 2.3: Configure Moonraker's Update Manager

Next, we need to tell Moonraker that this new plugin exists so it can be updated.

1. In the Mainsail interface, go to the **Machine** tab.
2. Open your `moonraker.conf` file.
3. Add the following block of code to the end of the file:

    ```ini
    [update_manager z_calibration]
    type: git_repo
    path: ~/klipper-z_calibration
    origin: https://github.com/protoloft/klipper_z_calibration.git
    install_script: ~/klipper-z_calibration/install.sh
    ```

    > **Important:** The path must exactly match the location where you just cloned the repository.

### Step 2.4: Configure Klipper

Tell Klipper to load the plugin:

1. Open your `printer.cfg` file.
2. Add the following line, typically near your other `[include]` statements:

    ```
    [include z_calibration.cfg]
    ```

### Step 2.5: Save and Restart

Save both `moonraker.conf` and `printer.cfg`. It is recommended to perform a full Firmware Restart from the Mainsail power menu to ensure all services reload correctly. After restarting, you should see "z_calibration" in the Update Manager section of the Mainsail settings page.

---

## 3. Workflow: Calibrating and Saving a New Profile

This is the process you will follow for each new combination of filament and build surface.

### Step 3.1: Pre-heat and PID Tune (Best Practice)

For the most accurate Z-offset, your printer should be at its target printing temperature.

- Heat your nozzle and bed to the temperatures you will use for the specific material (e.g., Nozzle: 250°C, Bed: 105°C for ASA).
- Run a PID tune for both the extruder and bed at these temperatures to ensure thermal stability.

    ```sh
    PID_CALIBRATE HEATER=extruder TARGET=250
    PID_CALIBRATE HEATER=heater_bed TARGET=105
    ```

- Run `SAVE_CONFIG` after each successful PID tune.

### Step 3.2: Calibrate the Z-Offset

- Run your `CALIBRATE_Z_OFFSET` macro to begin the interactive calibration process.
- Use the "paper test" and the `TESTZ` commands in the console to find the perfect nozzle height:

    ```
    TESTZ Z=-0.025   # Move down
    TESTZ Z=+0.025   # Move up
    ```

- Once satisfied, run the `ACCEPT` command (or click your macro button).

### Step 3.3: Save the Profile

Now, save this newly calibrated offset using your descriptive naming convention:

```
SAVE_Z_OFFSET NAME=ASA_GLASS_250
```

Repeat this process for all your material/surface combinations:

```
SAVE_Z_OFFSET NAME=PLA_TEXTURED_PEI_215
SAVE_Z_OFFSET NAME=PETG_SMOOTH_PEI_240
```

---

## 4. Creating Loader Macros

To make loading these profiles easy, create a dedicated macro for each one in your `macros/calibration/calibration.cfg` file.

```ini
[gcode_macro SET_PROFILE_ASA_GLASS]
description: Loads the Z-Offset profile for ASA on Smooth Glass.
gcode:
    LOAD_Z_OFFSET NAME=ASA_GLASS_250
    M117 Profile for ASA on Smooth Glass Loaded

[gcode_macro SET_PROFILE_PLA_TEXTURED]
description: Loads the Z-Offset profile for PLA on Textured PEI.
gcode:
    LOAD_Z_OFFSET NAME=PLA_TEXTURED_PEI_215
    M117 Profile for PLA on Textured PEI Loaded
```

After restarting, you will have buttons in Mainsail to instantly load the correct Z-offset before starting a print.

---

## 5. The `z_calibration.cfg` File

It is critical to understand that `z_calibration.cfg` is not a file you create or edit manually.

- **Automatically Generated:** The file is created by the plugin the first time you run `SAVE_Z_OFFSET`.
- **A Database:** It acts as a database where the plugin stores your saved profiles.
- **Do Not Modify:** Any manual edits to this file will be overwritten by the plugin.

If you view the file, it will look something like this:

```ini
# Klipper Z Calibration File
# This file is managed by the klipper-z-calibration plugin and should
# not be modified manually.

[z_calibration]
# ...internal plugin data...

#--------------------------------------------------------------------
# Saved Z-Offset Profiles
#--------------------------------------------------------------------
[saved_offsets]
ASA_GLASS_250 = -0.085
PLA_TEXTURED_PEI_215 = -0.030
PETG_SMOOTH_PEI_240 =