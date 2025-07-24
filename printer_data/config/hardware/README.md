# Klipper Hardware Configuration

This directory (`~/config/hardware/`) is dedicated to organizing all the hardware-specific configurations for this Klipper 3D printer setup. Breaking down the hardware definitions into logical, smaller files greatly improves clarity, simplifies management, and enhances maintainability compared to a single, monolithic configuration file.

## Table of Contents

1.  [Purpose of this Directory](#1-purpose-of-this-directory)
2.  [How Hardware Configurations are Loaded](#2-how-hardware-configurations-are-loaded)
3.  [Hardware File Breakdown](#3-hardware-file-breakdown)
    * [hardware/mcu/ (Directory)](#hardwaresmcu-directory)
    * [hardware/general/ (Directory)](#hardwaregeneral-directory)
    * [hardware/steppers/ (Directory)](#hardwaresteppers-directory)
    * [hardware/heaters/ (Directory)](#hardwareheaters-directory)
    * [hardware/fans/ (Directory)](#hardwarefans-directory)
    * [hardware/sensors/ (Directory)](#hardwaresensors-directory)
4.  [Adding or Modifying Hardware](#4-adding-or-modifying-hardware)
5.  [Benefits of this Setup](#5-benefits-of-this-setup)

---

## 1. Purpose of this Directory

The `hardware/` directory centralizes all configurations directly related to the physical components of the 3D printer, such as microcontrollers (MCUs), stepper motors, heaters, fans, and sensors. This organization makes it straightforward to identify and modify settings for specific hardware parts.

## 2. How Hardware Configurations are Loaded

The hardware configuration system is structured as follows:

* **`~/config/printer.cfg`**: Your main Klipper configuration file. It includes a single entry point for all hardware definitions:
    ```ini
    # In printer.cfg
    [include hardware/hardware_includes.cfg]
    ```
* **`~/config/hardware/hardware_includes.cfg`**: This file acts as the primary orchestrator for all hardware configurations. It includes all the individual `.cfg` files from their respective subdirectories.
    ```ini
    # In hardware/hardware_includes.cfg
    [include mcu/main_mcu.cfg]
    [include mcu/toolhead_mcu.cfg]

    [include general/board_aliases.cfg]
    [include general/screws.cfg]

    [include steppers/stepper_x.cfg]
    [include steppers/stepper_y.cfg]
    [include steppers/stepper_z.cfg]

    [include heaters/extruder.cfg]
    [include heaters/heater_bed.cfg]

    [include fans/fans.cfg]

    [include sensors/temperature_sensors.cfg]
    [include sensors/probe.cfg]
    ```
* **`~/config/hardware/*/*.cfg`**: These are the specific `.cfg` files containing the definitions for individual hardware components or logical groups.

This layered approach keeps your main `printer.cfg` concise and provides a clear, organized view of all hardware definitions.

## 3. Hardware File Breakdown

Below is an explanation of each subdirectory and its contents within the `hardware/` directory.

### `hardware/mcu/` (Directory)

* **Purpose:** Contains the core definitions for the printer's microcontrollers.
* **Files:**
    * `main_mcu.cfg`: Defines the main BTT Manta M8P control board.
    * `toolhead_mcu.cfg`: Defines the secondary EBB36 CAN bus toolhead board.

### `hardware/general/` (Directory)

* **Purpose:** Stores general-purpose configurations that apply to the overall machine construction and setup.
* **Files:**
    * `board_aliases.cfg`: Creates readable aliases for board pins, simplifying the configuration.
    * `screws.cfg`: Defines the coordinates for `SCREWS_TILT_CALCULATE` to assist with manual bed leveling.

### `hardware/steppers/` (Directory)

* **Purpose:** This subdirectory is dedicated to the configuration of all stepper motors and their associated Trinamic drivers.
* **Files:**
    * `stepper_x.cfg`: Contains the `[stepper_x]` and `[tmc2209 stepper_x]` sections.
    * `stepper_y.cfg`: Contains the `[stepper_y]` and `[tmc2209 stepper_y]` sections.
    * `stepper_z.cfg`: Combines `[stepper_z]` and `[stepper_z1]` for the dual Z-axis system.

### `hardware/heaters/` (Directory)

* **Purpose:** This subdirectory contains the configurations for all heating elements.
* **Files:**
    * `extruder.cfg`: Defines the hotend heater, temperature sensor, and extruder motor settings.
    * `heater_bed.cfg`: Defines the heated bed heater and temperature sensor.

### `hardware/fans/` (Directory)

* **Purpose:** Defines all cooling fans on the printer.
* **Files:**
    * `fans.cfg`: Contains `[fan]` (for part cooling) and `[heater_fan hotend_fan]` sections.

### `hardware/sensors/` (Directory)

* **Purpose:** Defines all measurement sensors on the printer.
* **Files:**
    * `probe.cfg`: Defines the CR Touch for Automatic Bed Leveling.
    * `temperature_sensors.cfg`: Defines additional thermistors, like the one on the main control board.
    * `adxl.cfg`: Contains the configuration for the ADXL345 accelerometer for input shaper tuning.

## 4. Adding or Modifying Hardware

To add new hardware or modify existing configurations:

1.  **Identify the Category:** Determine which subdirectory the hardware component belongs to.
2.  **Create/Select File:** Add or modify the relevant section in an existing file. If needed, create a new `.cfg` file within the appropriate subdirectory.
3.  **Add to `hardware_includes.cfg`:** If you created a new `.cfg` file, remember to add an `[include ...]` line for it in `hardware_includes.cfg`.
4.  **Restart Klipper:** Always restart the Klipper firmware after making configuration changes.

## 5. Benefits of this Setup

* **Modularity:** Each hardware component group has its own dedicated directory.
* **Clarity:** It's immediately evident where to find settings for a specific component (e.g., "Where is my probe config? -> `hardware/sensors/probe.cfg`").
* **Ease of Maintenance:** Debugging or upgrading is easier as changes are confined to smaller, relevant files.
* **Readability:** No more scrolling through hundreds of lines in a single file.
* **Scalability:** Effortlessly add new hardware without making the configuration cumbersome.

By maintaining this structured `hardware/` directory, your Klipper configuration will be robust, organized, and much simpler to manage over time.