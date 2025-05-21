# ISO Creator GUI Developer Guide

This document provides detailed technical information about the `CreateISO.ps1` PowerShell script for developers who want to understand, modify, or extend the application.

## Overview

The ISO Creator GUI is a PowerShell script that uses Windows Forms to create a graphical interface for generating ISO files from one or more selected files. It stages the selected files in a temporary directory and uses the `New-IsoFile` function to create ISO images compatible with Windows 11 using the IMAPI2FS COM object.

## Script Structure

### Key Components

1. **Logging Function**:
   - `Write-Log`: Writes timestamped messages to `H:\Personal\Code\Logs\guiPS.log`.
   - Usage: `Write-Log "Message"`
   - File path: Defined using `Join-Path $LogDir "guiPS.log"`, where `$LogDir = "H:\Personal\Code\Logs"`.
   - The log directory is created if it does not exist using `New-Item`.

2. **New-IsoFile Function**:
   - Uses `AddTree` to add a directory (typically the temporary directory containing selected files) to the ISO.
   - Key parameters:
     - `$Source`: Path to a directory or file(s) to include in the ISO.
     - `$Path`: Output path for the ISO file.
     - `$Media`: Media type (set to `DVDPLUSRW_DUALLAYER` for compatibility).
     - `$Force`: Overwrites existing files if specified.
   - Uses `System.CodeDom.Compiler` to compile a C# class (`ISOFile`) for low-level ISO creation.
   - Validates item existence and logs each addition attempt.
   - Includes error handling for empty ISO images and COM object cleanup in a `finally` block.

3. **GUI Components**:
   - Built using `System.Windows.Forms` and `System.Drawing` assemblies.
   - Form properties:
     - Title: "ISO Creator"
     - Size: 600x400 pixels
     - Fixed dialog border, centered on screen
   - Controls:
     - **Labels and TextBoxes**:
       - Source: Displays selected file paths (semicolon-separated for multiple files)
       - Destination: Folder path input
       - File Name: ISO file name (defaults to `output.iso`)
     - **Browse Buttons**:
       - Source: Opens `OpenFileDialog` with `Multiselect=$true`
       - Destination: Opens `FolderBrowserDialog`
     - **Action Buttons**:
       - Create ISO: Validates inputs, stages files in a temporary directory, and calls `New-IsoFile`
       - Exit: Closes the form

### Event Handlers

- **Source Browse Button**:
  - Opens `OpenFileDialog` with `Multiselect=$true` to allow selecting multiple files.
  - Joins selected file paths with semicolons for display in the Source field.
  - Logs the action and selected file paths.
- **Destination Browse Button**:
  - Opens `FolderBrowserDialog` to select a folder.
  - Logs the action and selected folder path.
- **Create ISO Button**:
  - Validates that all fields (Source, Destination, File Name) are non-empty.
  - Checks if each source file exists using `Test-Path`.
  - Creates a temporary directory in `$env:TEMP` and copies selected files to it.
  - Calls `New-IsoFile` with the temporary directory as the source.
  - Verifies the resulting ISO is not empty.
  - Cleans up the temporary directory in a `finally` block.
  - Displays success or error messages via `MessageBox`.
  - Logs all actions, including file copying and ISO creation outcomes.
- **Exit Button**:
  - Closes the form and logs the action.

## Dependencies

- **PowerShell**: Version 5.1 or later (for Windows Forms and COM object support).
- **.NET Framework**: Required for Windows Forms and COM interop.
- **IMAPI2FS**: Windows COM object for ISO creation (included in Windows 10/11).
- **System.Windows.Forms**: For GUI components.
- **System.Drawing**: For GUI layout and sizing.

## Logging

- All actions are logged to `H:\Personal\Code\Logs\guiPS.log`.
- The log directory is created automatically if it does not exist.
- Log entries include:
  - Application start and close
  - Button clicks
  - File and folder selections
  - File copying to the temporary directory
  - ISO creation attempts (success or failure)
  - Temporary directory cleanup
  - Error messages

## Extending the Script

### Adding New Features

1. **Additional Input Validation**:
   - Add checks for file size or specific file types in the `Create ISO` button's click event.
   - Example: Check file size limit:
     ```powershell
     $sourceFiles = $txtSource.Text -split ";"
     foreach ($file in $sourceFiles) {
         $fileInfo = Get-Item -LiteralPath $file
         if ($fileInfo.Length -gt 1GB) {
             [System.Windows.Forms.MessageBox]::Show("File too large: $file", "Error", "OK", "Error")
             Write-Log "Error: File too large: $file"
             return
         }
     }
     ```

2. **Custom Media Types**:
   - Modify the `New-IsoFile` call to allow users to select different media types via a dropdown (`ComboBox`).
   - Example:
     ```powershell
     $cmbMedia = New-Object System.Windows.Forms.ComboBox
     $cmbMedia.Items.AddRange(@('DVDPLUSR', 'DVDPLUSRW', 'DVDRAM'))
     ```

3. **Progress Feedback**:
   - Add a progress bar or status label to show file copying and ISO creation progress.
   - Example: Add a status label:
     ```powershell
     $lblStatus = New-Object System.Windows.Forms.Label
     $lblStatus.Location = New-Object System.Drawing.Point(20,200)
     $lblStatus.Size = New-Object System.Drawing.Size(540,20)
     $form.Controls.Add($lblStatus)
     ```

### Modifying the GUI

- **Resize or Reposition Controls**:
  - Adjust the `Location` and `Size` properties of controls in the script.
  - Example: To make the form larger, change `$form.Size = New-Object System.Drawing.Size(800,500)`.
- **Add New Controls**:
  - Add labels, textboxes, or buttons using `System.Windows.Forms` classes.

### Error Handling

- The script includes enhanced error handling:
  - Validates source file existence and temporary directory creation.
  - Checks for empty ISO files after creation.
  - Logs errors during file copying, ISO creation, and cleanup.
  - Ensures the log directory exists before logging.
- Enhance error handling further by checking for disk space:
  ```powershell
  $freeSpace = (Get-PSDrive -Name ($txtDestination.Text.Substring(0,1))).Free
  if ($freeSpace -lt 1GB) {
      [System.Windows.Forms.MessageBox]::Show("Insufficient disk space in destination.", "Error", "OK", "Error")
      Write-Log "Error: Insufficient disk space in destination: $($txtDestination.Text)"
      return
  }
  ```

## Known Limitations

- **Directory Support**: The script uses a temporary directory to stage files. Direct directory selection is supported only via clipboard or manual input, which includes the entire directory tree.
- **No Progress Feedback**: The `New-IsoFile` function does not provide progress updates, which may make the GUI appear unresponsive for large ISOs.
- **Windows-Only**: The script relies on Windows Forms and IMAPI2FS, making it incompatible with non-Windows systems.
- **Log Directory**: Requires write permissions in `H:\Personal\Code\Logs`.
- **Temporary Directory**: Requires write permissions in `$env:TEMP`.

## Debugging

- Check the `H:\Personal\Code\Logs\guiPS.log` file for detailed logs of actions, file copying, ISO creation, and errors.
- Use PowerShell's debugging tools (e.g., `Set-PSBreakpoint`) to step through the script.
- Test the `New-IsoFile` function independently with a directory:
  ```powershell
  New-IsoFile -Source "C:\path\to\temp\dir" -Path "C:\path\to\output.iso" -Force
  ```

## Deployment

- **Distribution**: Package the `CreateISO.ps1` script with the documentation files (`README.md`, `user_guide.md`, `developers.md`).
- **Execution Policy**: Ensure users have the appropriate PowerShell execution policy:
  ```powershell
  Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
  ```
- **Dependencies**: No external dependencies beyond Windows and PowerShell are required.
- **Log Directory**: Ensure `H:\Personal\Code\Logs` is writable on the target system.

## Contributing

- Fork the repository and submit pull requests for improvements.
- Suggested improvements:
  - Add support for selecting both files and folders in the source dialog.
  - Implement a progress bar for file copying and ISO creation.
  - Add configuration options for media types or volume names.
