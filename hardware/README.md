# Klipper Hardware Configuration

This directory (`~/klipper_config/hardware/`) is dedicated to organizing all the hardware-specific configurations for this Klipper 3D printer setup. Breaking down the hardware definitions into logical, smaller files greatly improves clarity, simplifies management, and enhances maintainability compared to a single, monolithic configuration file.

## Table of Contents

1.  [Purpose of this Directory](#1-purpose-of-this-directory)
2.  [How Hardware Configurations are Loaded](#2-how-hardware-configurations-are-loaded)
3.  [Hardware File Breakdown](#3-hardware-file-breakdown)
    * [hardware/main_mcu.cfg](#hardwaremain_mcucfg)
    * [hardware/toolhead_mcu.cfg](#hardwaretoolhead_mcucfg)
    * [hardware/board_aliases.cfg](#hardwareboard_aliasescfg)
    * [hardware/steppers/ (Directory)](#hardwaresteppers-directory)
        * [hardware/steppers/stepper_x.cfg](#hardwaresteppersstepper_xcfg)
        * [hardware/steppers/stepper_y.cfg](#hardwaresteppersstepper_ycfg)
        * [hardware/steppers/stepper_z.cfg](#hardwaresteppersstepper_zcfg)
    * [hardware/heaters/ (Directory)](#hardwareheaters-directory)
        * [hardware/heaters/extruder.cfg](#hardwareheatersextrudercfg)
        * [hardware/heaters/heater_bed.cfg](#hardwareheatersheater_bedcfg)
    * [hardware/fans.cfg](#hardwarefanscfg)
    * [hardware/temperature_sensors.cfg](#hardwaretemperature_sensorscfg)
4.  [Adding or Modifying Hardware](#4-adding-or-modifying-hardware)
5.  [Benefits of this Setup](#5-benefits-of-this-setup)

---

## 1. Purpose of this Directory

The `hardware/` directory centralizes all configurations directly related to the physical components of the 3D printer, such as microcontrollers (MCUs), stepper motors, heaters, fans, and sensors. This organization makes it straightforward to identify and modify settings for specific hardware parts.

## 2. How Hardware Configurations are Loaded

The hardware configuration system is structured as follows:

* **`~/klipper_config/printer.cfg`**: Your main Klipper configuration file. It includes a single entry point for all hardware definitions:
    ```ini
    # In printer.cfg
    [include hardware_includes.cfg]
    ```
* **`~/klipper_config/hardware_includes.cfg`**: This file acts as the primary orchestrator for all hardware configurations. It resides in the root Klipper config directory (alongside `printer.cfg`) and includes all the individual hardware `.cfg` files and subdirectories within the `hardware/` folder.
    ```ini
    # In hardware_includes.cfg
    [include hardware/main_mcu.cfg]
    [include hardware/toolhead_mcu.cfg]
    [include hardware/board_aliases.cfg]

    [include hardware/steppers/stepper_x.cfg]
    [include hardware/steppers/stepper_y.cfg]
    [include hardware/steppers/stepper_z.cfg] # Includes both Z and Z1

    [include hardware/heaters/extruder.cfg]
    [include hardware/heaters/heater_bed.cfg]

    [include hardware/fans.cfg]
    [include hardware/temperature_sensors.cfg]
    ```
* **`~/klipper_config/hardware/*.cfg` and `~/klipper_config/hardware/*/*.cfg`**: These are the specific `.cfg` files containing the definitions for individual hardware components or logical groups.

This layered approach keeps your main `printer.cfg` concise and provides a clear, organized view of all hardware definitions.

## 3. Hardware File Breakdown

Below is an explanation of each `.cfg` file and subdirectory within this `hardware/` directory:

### `hardware/main_mcu.cfg`

* **Purpose:** Defines the main Klipper microcontroller unit (MCU) board, including its CAN bus UUID or serial path.
* **Contents:** Contains the `[mcu]` section for your primary controller (e.g., BigTreeTech M8P).

### `hardware/toolhead_mcu.cfg`

* **Purpose:** Defines the secondary microcontroller unit (MCU) typically located on the toolhead, often connected via CAN bus.
* **Contents:** Contains the `[mcu ebb36]` section for your toolhead board (e.g., BigTreeTech EBB36).

### `hardware/board_aliases.cfg`

* **Purpose:** Stores aliases for specific board pins. This makes pin definitions more readable and less prone to errors by giving them descriptive names rather than raw pin identifiers.
* **Contents:** Includes the `[board_pins]` section with `aliases` for headers like EXP1 and EXP2.

### `hardware/steppers/` (Directory)

* **Purpose:** This subdirectory is dedicated to the configuration of all stepper motors and their associated TMC (Trinamic) stepper drivers. Each motor often has its own dedicated file.

#### `hardware/steppers/stepper_x.cfg`

* **Purpose:** Defines the X-axis stepper motor and its TMC2209 driver settings.
* **Contents:** Contains `[stepper_x]` and `[tmc2209 stepper_x]` sections.

#### `hardware/steppers/stepper_y.cfg`

* **Purpose:** Defines the Y-axis stepper motor and its TMC2209 driver settings.
* **Contents:** Contains `[stepper_y]` and `[tmc2209 stepper_y]` sections.

#### `hardware/steppers/stepper_z.cfg`

* **Purpose:** Defines all Z-axis stepper motors and their TMC2209 driver settings. This file combines `stepper_z` and `stepper_z1` for a multi-motor Z-axis system.
* **Contents:** Contains `[stepper_z]`, `[tmc2209 stepper_z]`, `[stepper_z1]`, and `[tmc2209 stepper_z1]` sections.

### `hardware/heaters/` (Directory)

* **Purpose:** This subdirectory contains the configurations for all heating elements in the printer, including the extruder hotend and the heated bed.

#### `hardware/heaters/extruder.cfg`

* **Purpose:** Defines the hotend extruder settings, including its step/direction pins, rotation distance, nozzle/filament diameter, heater pin, temperature sensor, and TMC2209 driver settings.
* **Contents:** Contains `[extr
