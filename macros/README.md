# Klipper Macros Configuration

This directory (`~/klipper_config/macros/`) contains the organized and modularized G-code macros for this Klipper 3D printer setup. Instead of a single, monolithic macro file, common functions and related macros are grouped into separate `.cfg` files for improved readability, maintainability, and ease of management.

## Table of Contents

1.  [Purpose of this Directory](#1-purpose-of-this-directory)
2.  [How Macros are Loaded](#2-how-macros-are-loaded)
3.  [Macro File Breakdown](#3-macro-file-breakdown)
    * [macros/core_print.cfg](#macroscore_printcfg)
    * [macros/filament_handling.cfg](#macrosfilament_handlingcfg)
    * [macros/diagnostics_utilities.cfg](#macrosdiagnostics_utilitiescfg)
    * [macros/compatibility_overrides.cfg](#macroscompatibility_overridescfg)
    * [macros/helper_macros.cfg](#macroshelper_macroscfg)
4.  [Slicer Integration](#4-slicer-integration)
5.  [Adding New Macros](#5-adding-new-macros)
6.  [Benefits of this Setup](#6-benefits-of-this-setup)

---

## 1. Purpose of this Directory

The `macros/` directory centralizes all custom Klipper G-code macros. By organizing them into smaller, logically grouped files, it enhances the overall clarity and manageability of the printer's configuration.

## 2. How Macros are Loaded

The macro system is set up in a hierarchical manner:

* **`~/klipper_config/printer.cfg`**: This is your main Klipper configuration file. It includes `macros_includes.cfg`.
    ```ini
    # In printer.cfg
    [include macros_includes.cfg]
    ```
* **`~/klipper_config/macros_includes.cfg`**: This file acts as the primary orchestrator for all macros. It resides in the root Klipper config directory and includes all the individual macro files located within the `macros/` subdirectory.
    ```ini
    # In macros_includes.cfg
    [include macros/core_print.cfg]
    [include macros/filament_handling.cfg]
    [include macros/diagnostics_utilities.cfg]
    [include macros/compatibility_overrides.cfg]
    [include macros/helper_macros.cfg]
    # ... and any other macro group files you add
    ```
* **`~/klipper_config/macros/*.cfg`**: These are the individual `.cfg` files within this directory, each containing a specific set of related G-code macros.

This structure ensures that `printer.cfg` remains clean and high-level, while all macro details are neatly organized.

## 3. Macro File Breakdown

Below is an explanation of each `.cfg` file within this `macros/` directory and the types of macros they contain:

### `macros/core_print.cfg`

* **Purpose:** Contains the essential macros for initiating, pausing, resuming, and canceling prints, which are typically called directly by the slicer or the printer interface (Mainsail/Fluidd).
* **Key Macros:**
    * `PRINT_START`: The main entry point for your slicer's start G-code. It acts as a wrapper, calling `_PRINT_START_LOGIC` to execute the actual print startup sequence.
    * `PRINT_END`: The main entry point for your slicer's end G-code. It calls `_PRINT_END_LOGIC` for the print finishing sequence.
    * `PAUSE`: Pauses the current print. It uses `_TOOLHEAD_PARK_PAUSE_CANCEL` to move the toolhead to a safe park position.
    * `RESUME`: Resumes a paused print.
    * `CANCEL_PRINT`: Aborts the current print, turns off heaters, parks the toolhead, and resets the SD card.
    * `START_PRINT` (optional): An alias for `PRINT_START`, useful for slicers that output `START_PRINT` by default.

### `macros/filament_handling.cfg`

* **Purpose:** Houses macros related to loading, unloading, and changing filament.
* **Key Macros:**
    * `FILAMENT_CHANGE_M600`: Overrides the standard M600 G-code for filament changes, pausing the print and providing instructions.
    * `FILAMENT_LOAD`: Automates the process of loading new filament.
    * `FILAMENT_UNLOAD`: Automates the process of unloading filament.

### `macros/diagnostics_utilities.cfg`

* **Purpose:** Contains macros designed for testing, diagnostics, and general utility functions that don't directly fall into print control or filament handling.
* **Key Macros:**
    * `DIAGS_TEST_SPEED` (or `TEST_SPEED`): A comprehensive macro for testing maximum printer speeds and accelerations, including pattern movements and position checks for skipped steps.
    * `DIAGS_BED_HEATSOAK` (or `HEAT_BED_FOR_TIME`): Heats the print bed to a specified temperature and holds it for a set duration, useful for heat soaking the printer's enclosure.

### `macros/compatibility_overrides.cfg`

* **Purpose:** Used for macros that override standard G-code commands (like `G29` for bed leveling) or provide compatibility layers for specific features.
* **Key Macros:**
    * `G29`: Overrides the default `G29` command to perform an adaptive bed mesh calibration, often integrated with KAMP (Klipper Adaptive Meshing & Purging).

### `macros/helper_macros.cfg`

* **Purpose:** Stores internal "helper" macros, often prefixed with an underscore (`_`), that are not intended to be called directly by the user or slicer but are utilized by other primary macros (e.g., `PRINT_START` calls `_PRINT_START_LOGIC`).
* **Key Macros:**
    * `_PRINT_START_LOGIC`: The detailed G-code sequence that performs the actual print startup routine (homing, pre-heating, bed mesh, final heating, etc.). This is the comprehensive logic previously found in a monolithic `PRINT_START`.
    * `_PRINT_END_LOGIC`: The detailed G-code sequence for safely ending a print (retracting, parking, turning off heaters).
    * `_TOOLHEAD_PARK_PAUSE_CANCEL`: A reusable routine to safely park the toolhead, used by `PAUSE` and `CANCEL_PRINT`.
    * `_CG28`: A conditional homing macro that only executes `G28` if the printer is not already homed on all axes.

## 4. Slicer Integration

To leverage this macro setup, ensure your slicer's custom G-code settings are configured as follows:

* **Start G-code:**
    ```gcode
    PRINT_START BED_TEMP=[first_layer_bed_temperature] EXTRUDER_TEMP=[first_layer_temperature]
    ```
    *(Note: Parameter names might vary slightly depending on your slicer. Consult your slicer's documentation if `[first_layer_bed_temperature]` or `[first_layer_temperature]` don't work and use `{bed_temperature}` and `{hotend_temperature[0]}` if you want to be generic).*

* **End G-code:**
    ```gcode
    PRINT_END
    ```

## 5. Adding New Macros

To add new macros to your configuration:

1.  **Identify the Category:** Determine which logical category your new macro best fits into (e.g., calibration, maintenance, specific hardware features).
2.  **Create/Select File:** If an appropriate `.cfg` file already exists in `macros/`, add your new macro definition there. If not, create a new `.cfg` file (e.g., `macros/my_new_category.cfg`).
3.  **Add to `macros_includes.cfg`:** If you created a new `.cfg` file, remember to add an `[include macros/my_new_category.cfg]` line to your `macros_includes.cfg` file.
4.  **Restart Klipper:** Always restart the Klipper firmware after making changes to your configuration files.

## 6. Benefits of this Setup

* **Organization:** Keeps related macros together, preventing a single, unwieldy file.
* **Readability:** Easier to find, understand, and review specific macro functions.
* **Maintainability:** Changes are localized to specific files, reducing the risk of accidental breakage elsewhere.
* **Scalability:** Simple to add new macro categories and expand your configuration without clutter.
* **Collaboration:** (Even for solo users!) Easier to track changes with version control (e.g., Git).

By following this structure, your Klipper configuration will remain clean, efficient, and easy to manage as your printer setup evolves.
