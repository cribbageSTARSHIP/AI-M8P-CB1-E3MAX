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

    # These are placeholders for future macro categories.
    # Uncomment and create the corresponding .cfg files when ready to add macros in these areas.
    #[include macros/calibration.cfg]
    #[include macros/tool_changes.cfg]
    #[include macros/status_leds.cfg]

    # Add more includes here as you create new macro group files
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

### `macros/
