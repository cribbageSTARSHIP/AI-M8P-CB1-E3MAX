# Klipper Macros Configuration

This directory (`~/printer_data/config/macros/`) contains the organized and modularized G-code macros for this Klipper 3D printer setup. Instead of a single, monolithic macro file, common functions and related macros are grouped into separate `.cfg` files within functional subdirectories for improved readability, maintainability, and ease of management.

## Table of Contents

1.  [Purpose of this Directory](#1-purpose-of-this-directory)
2.  [How Macros are Loaded](#2-how-macros-are-loaded)
3.  [Macro File Breakdown](#3-macro-file-breakdown)
    * [macros/printing/ (Directory)](#macrosprinting-directory)
    * [macros/actions/ (Directory)](#macrosactions-directory)
    * [macros/calibration/ (Directory)](#macroscalibration-directory)
    * [macros/overrides/ (Directory)](#macrosoverrides-directory)
4.  [Slicer Integration](#4-slicer-integration)
5.  [Adding New Macros](#5-adding-new-macros)
6.  [Benefits of this Setup](#6-benefits-of-this-setup)

---

## 1. Purpose of this Directory

The `macros/` directory centralizes all custom Klipper G-code macros. By organizing them into smaller, logically grouped files, it enhances the overall clarity and manageability of the printer's configuration.

## 2. How Macros are Loaded

The macro system is set up in a hierarchical manner:

* **`~/printer_data/config/printer.cfg`**: This is your main Klipper configuration file. It includes `macros/macros_includes.cfg`.
    ```ini
    # In printer.cfg
    [include macros/macros_includes.cfg]
    ```
* **`~/printer_data/config/macros/macros_includes.cfg`**: This file acts as the primary orchestrator for all macros. It resides in the root `macros` directory and includes all the individual macro files from their respective subdirectories.
    ```ini
    # In macros/macros_includes.cfg
    [include printing/core_print.cfg]
    [include printing/helper_macros.cfg]
    [include actions/filament_handling.cfg]
    [include calibration/pid_loader.cfg]
    # Add more includes here as you create new macro group files
    ```
* **`~/printer_data/config/macros/*/*.cfg`**: These are the individual `.cfg` files within the subdirectories, each containing a specific set of related G-code macros.

This structure ensures that `printer.cfg` remains clean and high-level, while all macro details are neatly organized.

## 3. Macro File Breakdown

Below is an explanation of each subdirectory and its contents within the `macros/` directory.

### `macros/printing/` (Directory)

* **Purpose:** Contains the essential macros for initiating, pausing, resuming, and canceling prints.

* **Files:**
    * **`core_print.cfg`**
        * **Purpose:** Defines the primary macros called by the slicer or UI to manage a print job.
        * **Key Macros:** `PRINT_START`, `PRINT_END`, `PAUSE`, `RESUME`, `CANCEL_PRINT`.
    * **`helper_macros.cfg`**
        * **Purpose:** Stores internal "helper" macros, prefixed with an underscore (`_`), that are not intended to be called directly.
        * **Key Macros:** `_PRINT_START_LOGIC`, `_PRINT_END_LOGIC`, `_TOOLHEAD_PARK_PAUSE_CANCEL`, `_CG28`.

### `macros/actions/` (Directory)

* **Purpose:** Houses macros related to specific physical printer actions.

* **Files:**
    * **`filament_handling.cfg`**
        * **Purpose:** Contains macros for loading, unloading, and changing filament.
        * **Key Macros:** `FILAMENT_CHANGE_M600`, `FILAMENT_LOAD`, `FILAMENT_UNLOAD`.
    * **`status_leds.cfg`**
        * **Purpose:** (If used) Controls status LEDs (e.g., Neopixels) to provide visual feedback on the printer's state.
    * **`tool_changes.cfg`**
        * **Purpose:** (If used) Defines G-code for tool-changing or nozzle-swapping systems.

### `macros/calibration/` (Directory)

* **Purpose:** Contains macros designed for testing, diagnostics, and printer calibration routines.

* **Files:**
    * **`pid_loader.cfg`**
        * **Purpose:** Defines macros for the dynamic PID profile saving and loading system.
        * **Key Macros:** `SAVE_PID_TO_PROFILE`, `LOAD_PID_PROFILE`.
    * **`diagnostics_utilities.cfg`**
        * **Purpose:** Contains utility macros for running diagnostic tests.
        * **Key Macros:** `DIAGS_TEST_SPEED`, `DIAGS_BED_HEATSOAK`.
    * **`calibration.cfg`**
        * **Purpose:** (If used) A central place for various calibration macros.

### `macros/overrides/` (Directory)

* **Purpose:** Used for macros that override standard G-code commands to provide custom functionality or slicer compatibility.

* **Files:**
    * **`compatibility_overrides.cfg`**
        * **Purpose:** Provides a compatibility layer for common slicer G-codes.
        * **Key Macros:** `G29` (maps to Klipper's `BED_MESH_CALIBRATE`).

## 4. Slicer Integration

To leverage this macro setup, ensure your slicer's custom G-code settings are configured as follows:

* **Start G-code:**
    ```gcode
    PRINT_START BED_TEMP=[first_layer_bed_temperature] EXTRUDER_TEMP=[first_layer_temperature]
    ```
* **End G-code:**
    ```gcode
    PRINT_END
    ```

## 5. Adding New Macros

1.  **Identify the Category:** Determine which subdirectory your new macro best fits into.
2.  **Create/Select File:** Add your new macro definition to the appropriate file. If not, create a new `.cfg` file within that subdirectory.
3.  **Add to `macros_includes.cfg`:** If you created a new `.cfg` file, add an `[include ...]` line for it in `macros/macros_includes.cfg`.
4.  **Restart Klipper:** Always restart the Klipper firmware after making changes.

## 6. Benefits of this Setup

* **Organization:** Keeps related macros together in functional groups.
* **Readability:** Easier to find, understand, and review specific macro functions.
* **Maintainability:** Changes are localized, reducing the risk of accidental breakage.
* **Scalability:** Simple to add new macro categories without clutter.

By following this structure, your Klipper configuration will remain clean, efficient, and easy to manage as your printer setup evolves.