## Configuration Structure

This Klipper configuration is split into multiple files to improve organization and readability. The main `printer.cfg` file is used to include the necessary configuration files from the `hardware` and `macros` directories.

### Main Configuration File

-   **`printer.cfg`**: The main Klipper configuration file. It loads the hardware and macro configurations.

### Hardware Configuration (`/hardware`)

All hardware-related configurations are located in the `hardware` directory, sorted into functional subdirectories. The `hardware_includes.cfg` file serves as the master list for this section.

-   **`hardware/`**
    -   `hardware_includes.cfg`
    -   **/fans/**: Contains fan definitions.
    -   **/general/**: Contains general-purpose configurations like board pin aliases and bed screw locations.
    -   **/heaters/**: Contains the configuration for the extruder and heated bed.
    -   **/mcu/**: Contains the MCU definitions for the mainboard and toolhead.
    -   **/sensors/**: Contains sensor configurations, including the probe, temperature sensors, and ADXL345.
    -   **/steppers/**: Contains the motor configurations for all axes.

### Macro Configuration (`/macros`)

All G-code macros are located in the `macros` directory, organized by function. The `macros_includes.cfg` file serves as the master list for this section.

-   **`macros/`**
    -   `macros_includes.cfg`
    -   **/actions/**: Macros for specific printer actions like filament handling.
    -   **/calibration/**: Macros related to calibration, diagnostics, and PID tuning.
    -   **/overrides/**: Macros for overriding default G-code behavior for slicer compatibility.
    -   **/printing/**: Core macros that define the start, end, pause, and resume print sequence.

### Custom Scripts

This repository also includes several custom scripts to enhance functionality:

-   **`/PID_loader`**: A dynamic PID management system.
-   **`/OFFSET_loader`**: A Z-offset management system for different build surfaces.
-   **`/printer-date_cleanup`**: A script for automated backup management.
