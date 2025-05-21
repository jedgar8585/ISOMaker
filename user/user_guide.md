# ISO Creator GUI User Guide

This guide provides step-by-step instructions for using the ISO Creator GUI application to create ISO files on Windows 11.

## Introduction

The ISO Creator GUI is a PowerShell-based application that allows users to create ISO files from one or more selected files. The application stages the selected files in a temporary directory to ensure reliable inclusion in the ISO, which is mountable on Windows 11 systems.

## Prerequisites

- Windows 10 or Windows 11
- PowerShell 5.1 or later
- Write permissions for the destination folder, `H:\Personal\Code\Logs`, and temporary directory (`$env:TEMP`)
- Sufficient disk space for the ISO file and temporary storage

## Getting Started

1. **Download the Script**:
   - Obtain the `CreateISO.ps1` script from the repository or distribution source.
   - Place it in a directory where you have write permissions.

2. **Run the Application**:
   - Open PowerShell (run as administrator if necessary).
   - Navigate to the directory containing `CreateISO.ps1`:
     ```powershell
     cd path\to\script\directory
     ```
   - Execute the script:
     ```powershell
     .\CreateISO.ps1
     ```
   - The GUI window will appear.

## Using the Application

### Interface Overview

The GUI consists of:
- **Source Field**: Displays the path(s) of the selected file(s) to include in the ISO.
- **Destination Field**: Specifies the folder where the ISO file will be saved.
- **File Name Field**: Specifies the name of the output ISO file (e.g., `myimage.iso`).
- **Browse Buttons**: Allow selection of source files and destination folder.
- **Create ISO Button**: Initiates the ISO creation process.
- **Exit Button**: Closes the application.

### Steps to Create an ISO

1. **Select Source Files**:
   - Click the "Browse" button next to the Source field.
   - In the file dialog, navigate to the desired files.
   - Hold Ctrl to select multiple files, or select a single file.
   - Click "Open" to set the source file(s).
   - The selected file paths will appear in the Source field, separated by semicolons.

2. **Select Destination**:
   - Click the "Browse" button next to the Destination field.
   - In the folder dialog, select the folder where you want to save the ISO file.
   - Click "OK" to set the destination path.
   - The selected path will appear in the Destination field.

3. **Specify File Name**:
   - Enter the desired name for the ISO file in the File Name field.
   - If you omit the `.iso` extension, it will be added automatically.
   - Example: Enter `myimage` to create `myimage.iso`.

4. **Create the ISO**:
   - Click the "Create ISO" button.
   - The application will validate the inputs:
     - If no source files are selected, an error message will appear.
     - If any source file does not exist, an error message will specify the missing file.
     - If the destination folder or file name is empty, an error message will appear.
     - Ensure all fields are filled correctly and all source files exist.
   - The selected files are copied to a temporary directory before being added to the ISO.
   - The ISO will include only the selected files.
   - If successful, a message will confirm the ISO was created at the specified location.
   - If an error occurs (e.g., empty ISO), an error message will display the issue.

5. **Exit the Application**:
   - Click the "Exit" button to close the GUI.

## Checking the Log

- The application logs all actions to `H:\Personal\Code\Logs\guiPS.log`.
- The log directory is automatically created if it does not exist.
- Open the log file in a text editor to review actions, such as button clicks, file selections, file copying, ISO creation, and any errors.

## Troubleshooting

- **Error: "Source file does not exist..."**:
  - Verify that the selected files exist and are accessible.
  - Reselect the files using the "Browse" button.
- **Error: "Created ISO file is empty..."**:
  - Check the `H:\Personal\Code\Logs\guiPS.log` file for details on file copying or ISO creation errors.
  - Ensure the selected files are not locked by another process.
  - Try selecting different files or a different destination path.
- **Error: "Cannot create file..."**:
  - Ensure the destination folder is writable.
  - Check that the file name does not contain invalid characters.
- **GUI Does Not Open**:
  - Ensure PowerShell execution policy allows running scripts:
    ```powershell
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
    ```
  - Run PowerShell as administrator if issues persist.
- **Logging Issues**:
  - Ensure write permissions in `H:\Personal\Code\Logs`.
  - Check the log for errors related to file copying or ISO creation.

## Support

For issues or feature requests, check the GitHub repository or contact the developer.
