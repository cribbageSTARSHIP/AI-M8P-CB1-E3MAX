# Z-Offset Management System (`klipper-z_calibration`)

This documentation describes how to use the Z-Offset Profile Management system powered by the `klipper-z_calibration` Klipper plugin. This system lets you save and load different Z-offset values, which is essential for printing with various materials and build surfaces.

---

## 1. Purpose

The ideal Z-offset for a perfect first layer can change based on:

- **Filament type** (thermal expansion)
- **Build surface** (e.g., textured PEI vs. smooth glass)

This system allows you to calibrate the offset for each combination, save it with a descriptive name, and load it instantly before a print—ensuring consistent, high-quality first layers.

**Recommended naming convention:**  
`MATERIAL_SURFACE_TEMP` (e.g., `ASA_GLASS_250`)

---

## 2. Manual Installation (GitHub & Moonraker)

### 2.1. SSH into Your Host Device

Connect to your BTT CB1 (or Raspberry Pi) via SSH.

### 2.2. Download the Plugin

```sh
cd ~
git clone https://github.com/protoloft/klipper_z_calibration.git ~/klipper-z_calibration
```

### 2.3. Configure Moonraker's Update Manager

1. In Mainsail, go to the **Machine** tab and open `moonraker.conf`.
2. Add the following block to the end of the file:

    ```
    [update_manager z_calibration]
    type: git_repo
    path: ~/klipper-z_calibration
    origin: https://github.com/protoloft/klipper_z_calibration.git
    install_script: ~/klipper-z_calibration/install.sh
    ```

### 2.4. Configure Klipper

1. Open your `printer.cfg` file.
2. Add this line near your other `[include]` statements:

    ```
    [include z_calibration.cfg]
    ```

### 2.5. Save and Restart

- Save both `moonraker.conf` and `printer.cfg`.
- Perform a full **Firmware Restart**.
- You should now see `z_calibration` in the Update Manager section of Mainsail settings.

---

## 3. Calibration Workflow & Macros

This is the complete button-driven workflow for calibrating and saving a new Z-offset profile.

### 3.1. Pre-heat and PID Tune (Best Practice)

- Heat your nozzle and bed to the target printing temperature for your material.
- Run a PID tune for both extruder and bed at these temperatures.
- Run `SAVE_CONFIG` after each successful PID tune.

### 3.2. Start the Calibration

- **Macro:** `CALIBRATE_Z_OFFSET`  
- **Location:** `macros/calibration/offset-loader.cfg`  
- **Action:** Click this button in the Mainsail UI. It runs the `CALIBRATE_Z` command, which homes the printer and starts interactive calibration mode.

### 3.3. Fine-Tune the Offset

- **Commands:** `TESTZ Z=-...` and `TESTZ Z=+...`
- **Action:** Use the "paper test" method. Enter `TESTZ` commands in the console to move the nozzle up or down in small increments until you feel the correct drag on the paper.

### 3.4. Accept the Value

- **Macro:** `ACCEPT`  
- **Location:** `macros/calibration/calibration.cfg`  
- **Action:** Once the height is perfect, click the `ACCEPT` button to finish the `TESTZ` adjustments.

### 3.5. Save the Profile

- **Macro:** `SAVE_Z_OFFSET_PROFILE`  
- **Location:** `macros/calibration/offset-loader.cfg`  
- **Action:**
    1. Find the `SAVE_Z_OFFSET_PROFILE` button in the UI.
    2. In the `NAME` text box, type your descriptive profile name (e.g., `ASA_GLASS_250`).
    3. Click the button. This runs the `SAVE_Z_OFFSET` command, saving your calibrated offset to `z_calibration.cfg` under the name you provided.

### 3.6. Save to Printer Memory

- **Macro:** `SAVE_CONF`  
- **Location:** `macros/calibration/calibration.cfg`  
- **Action:** Click the `SAVE_CONF` button to permanently save the `z_calibration.cfg` file and restart Klipper.

---

## 4. Loading a Saved Profile

To make loading profiles easy, dedicated macros are stored in `macros/calibration/offset-loader.cfg`.

- **Macro:** `SET_PROFILE_[NAME]` (e.g., `SET_PROFILE_ASA_GLASS`)
- **Action:** Before starting a print, click the button for your material and build surface. This instantly loads the correct Z-offset.

---

## 5. Troubleshooting

- Ensure all configuration files are saved before restarting.
- If macros do not appear, check for typos in macro names or `[include]` statements.
- For more help, visit the [klipper_z_calibration GitHub](https://github.com/protoloft/klipper_z_calibration).

---