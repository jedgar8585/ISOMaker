# ISO Creator GUI

A PowerShell-based GUI application for creating ISO files that are mountable on Windows 11 systems.

## Overview

This application provides a user-friendly graphical interface to create ISO files from one or more selected files. Users can select source files, choose a destination folder, and specify an output ISO file name. The application stages selected files in a temporary directory and uses the `New-IsoFile` function to generate ISO images compatible with Windows 11, ensuring only the selected files are included.

## Features

- **Graphical Interface**: Simple and intuitive GUI built with Windows Forms.
- **Multiple File Selection**: Select one or more files to include in the ISO using the "Browse" button.
- **Folder Selection**: Browse button for selecting the destination folder.
- **ISO Creation**: Generates ISO files using the IMAPI2FS COM object, including only the selected files.
- **Input Validation**: Ensures all required fields are filled, source files exist, and the ISO is not empty.
- **Progress Bar**: Displays progress during ISO creation, including validation, file copying, ISO generation, and cleanup.
- **Status Label**: Shows the current stage (e.g., "Copying files...") below the progress bar during ISO creation.
- **View Log Button**: Allows users to open the log file (`H:\Personal\Code\Logs\guiPS.log`) in the default text editor.
- **Logging**: All actions, including file copying, ISO creation, progress updates, and button clicks, are logged to `H:\Personal\Code\Logs\guiPS.log`.
- **Temporary Directory**: Uses a temporary directory to stage files, ensuring reliable inclusion in the ISO.

## Prerequisites

- Windows 10 or Windows 11
- PowerShell 5.1 or later
- .NET Framework (included with Windows)
- Write permissions in `H:\Personal\Code\Logs` and the temporary directory (`$env:TEMP`)

## Installation

1. Clone or download this repository.
2. Ensure PowerShell is installed on your system.
3. Place the `CreateISO.ps1` script in a directory of your choice.
4. Ensure the `H:\Personal\Code\Logs` directory is accessible and writable.

## Usage

1. Run the `CreateISO.ps1` script in PowerShell:
   ```powershell
   .\CreateISO.ps1
   ```
2. Use the GUI to:
   - Select one or more source files using the "Browse" button (hold Ctrl to select multiple files).
   - Choose a destination folder using the "Browse" button.
   - Enter a file name for the ISO (defaults to `output.iso`).
   - Click "Create ISO" to generate the ISO file; the progress bar and status label will show the creation stages.
   - Click "View Log" to open the log file in the default text editor.
   - Click "Exit" to close the application.

## Documentation

- **User Guide**: See `user_guide.md` for detailed instructions on using the application.
- **Developer Guide**: See `developers.md` for technical details about the script.

## Logging

All actions (e.g., button clicks, file selections, file copying, ISO creation, progress updates, and errors) are logged to `H:\Personal\Code\Logs\guiPS.log`.

