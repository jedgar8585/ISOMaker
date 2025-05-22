# ISO Creator GUI Developer Guide

This document provides detailed technical information about the `CreateISO.ps1` PowerShell script for developers who want to understand, modify, or extend the application.

## Overview

The ISO Creator GUI is a PowerShell script that uses Windows Forms to create a graphical interface for generating ISO files from one or more selected files. It stages the selected files in a temporary directory and uses the `New-IsoFile` function to create ISO images compatible with Windows 11 using the IMAPI2FS COM object. A progress bar and status label display the stages of the ISO creation process, and a "View Log" button allows users to access the log file directly.

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
       - Create ISO: Validates inputs, stages files in a temporary directory, updates the progress bar and status label, and calls `New-IsoFile`
       - View Log: Opens the log file (`H:\Personal\Code\Logs\guiPS.log`) in the default text editor
       - Exit: Closes the form
     - **Progress Bar**:
       - Displays progress during ISO creation, updated at each stage (validation, temp directory creation, file copying, ISO creation, verification/cleanup).
     - **Status Label**:
       - Displays the current stage (e.g., "Copying files...") below the progress bar, updated with each progress stage.

### Event Handlers

- **Source Browse Button**:
  - Opens `OpenFileDialog` with `Multiselect=$true` to allow selecting multiple files.
  - Joins selected file paths with semicolons for display in the Source field.
  - Logs the action and selected file paths.
- **Destination Browse Button**:
  - Opens `FolderBrowserDialog` to select a folder.
  - Logs the action and selected folder path.
- **Create ISO Button**:
  - Initializes the progress bar (`$progressBar.Visible = $true`, `$progressBar.Value = 0`) and status label (`$lblStatus.Visible = $true`, `$lblStatus.Text = "Initializing..."`).
  - Defines five progress stages (validation, create temp dir, copy files, create ISO, verify/cleanup), with each stage incrementing the progress by 20% (100/5).
  - Updates the status label at each stage with descriptive text (e.g., "Validating inputs...", "Generating ISO...").
  - Validates that all fields (Source, Destination, File Name) are non-empty and source files exist using `Test-Path`.
  - Creates a temporary directory in `$env:TEMP` and copies selected files to it.
  - Calls `New-IsoFile` with the temporary directory as the source.
  - Verifies the resulting ISO is not empty.
  - Updates the progress bar and status label after each stage, calling `$form.Refresh()` to ensure UI updates.
  - Cleans up the temporary directory and hides the progress bar and status label in a `finally` block.
  - Displays success or error messages via `MessageBox`.
  - Logs all actions, including progress updates, status changes, and outcomes.
- **View Log Button**:
  - Checks if the log file (`H:\Personal\Code\Logs\guiPS.log`) exists using `Test-Path`.
  - If it exists, opens the file using `Start-Process`, which launches the default text editor (e.g., Notepad).
  - If it does not exist, displays an error message via `MessageBox`.
  - Logs the button click and the outcome (success or error).
- **Exit Button**:
  - Closes the form and logs the action.

## Dependencies

- **PowerShell**: Version 5.1 or later (for Windows Forms and COM object support).
- **.NET Framework**: Required for Windows Forms and COM interop.
- **IMAPI2FS**: Windows COM object for ISO creation (included in Windows 10/11).
- **System.Windows.Forms**: For GUI components, including the progress bar, status label, and buttons.
- **System.Drawing**: For GUI layout and sizing.

## Logging

- All actions are logged to `H:\Personal\Code\Logs\guiPS.log`.
- The log directory is created automatically if it does not exist.
- Log entries include:
  - Application start and close
  - Button clicks (including "View Log")
  - File and folder selections
  - File copying to the temporary directory
  - ISO creation attempts (success or failure)
  - Progress bar updates (percentage complete for each stage)
  - Status label updates (current stage text)
  - Temporary directory cleanup
  - Errors (e.g., log file not found, failed to open log file)

## Extending the Script

### Adding New Features

1. **Granular Progress for File Copying**:
   - Update the file copying loop to increment the progress bar and update the status label per file, especially for large numbers of files:
     ```powershell
     $fileCount = $sourceFiles.Count
     $fileIncrement = $stageIncrement / $fileCount
     foreach ($file in $sourceFiles) {
         $fileName = [System.IO.Path]::GetFileName($file)
         $destFile = Join-Path $tempDir $fileName
         $lblStatus.Text = "Copying $fileName..."
         $form.Refresh()
         Copy-Item -LiteralPath $file -Destination $destFile -Force
         $progressBar.Value = [math]::Min($progressBar.Value + $fileIncrement, 100)
         $form.Refresh()
     }
     ```

2. **Custom Media Types**:
   - Add a `ComboBox` to select different media types for `New-IsoFile`:
     ```powershell
     $cmbMedia = New-Object System.Windows.Forms.ComboBox
     $cmbMedia.Items.AddRange(@('DVDPLUSR', 'DVDPLUSRW', 'DVDRAM'))
     $cmbMedia.Location = New-Object System.Drawing.Point(100,130)
     $cmbMedia.Size = New-Object System.Drawing.Size(350,20)
     $form.Controls.Add($cmbMedia)
     ```

3. **Enhanced Log Viewing**:
   - Add a preview window to display the log file contents within the GUI:
     ```powershell
     $txtLogPreview = New-Object System.Windows.Forms.TextBox
     $txtLogPreview.Multiline = $true
     $txtLogPreview.Location = New-Object System.Drawing.Point(100,240)
     $txtLogPreview.Size = New-Object System.Drawing.Size(350,100)
     $txtLogPreview.ScrollBars = "Vertical"
     $form.Controls.Add($txtLogPreview)
     $btnViewLog.Add_Click({
         if (Test-Path -LiteralPath $LogFile) {
             $txtLogPreview.Text = Get-Content -Path $LogFile -Raw
         }
     })
     ```

### Modifying the GUI

- **Resize or Reposition Controls**:
  - Adjust the `Location` and `Size` properties of controls. For example, to move the "View Log" button, change `$btnViewLog.Location = New-Object System.Drawing.Point(200,150)`.
- **Customize Buttons, Progress Bar, or Status Label**:
  - Change the style or colors of the buttons, progress bar, or status label:
     ```powershell
     $btnViewLog.BackColor = [System.Drawing.Color]::LightGray
     $progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
     $progressBar.ForeColor = [System.Drawing.Color]::Blue
     $lblStatus.ForeColor = [System.Drawing.Color]::DarkGreen
     ```

### Error Handling

- The script includes enhanced error handling:
  - Validates source file existence and temporary directory creation.
  - Checks for empty ISO files after creation.
  - Logs errors during file copying, ISO creation, and cleanup.
  - Ensures the log directory exists before logging.
  - Hides the progress bar and status label on error or completion.
  - Checks for log file existence before attempting to open it.
- Enhance error handling by checking for disk space:
  ```powershell
  $freeSpace = (Get-PSDrive -Name ($txtDestination.Text.Substring(0,1))).Free
  if ($freeSpace -lt 1GB) {
      [System.Windows.Forms.MessageBox]::Show("Insufficient disk space in destination.", "Error", "OK", "Error")
      Write-Log "Error: Insufficient disk space in destination: $($txtDestination.Text)"
      $progressBar.Visible = $false
      $lblStatus.Visible = $false
      return
  }
  ```

## Known Limitations

- **Progress Bar Granularity**: The progress bar updates at five discrete stages, as `New-IsoFile` does not provide callbacks for the ISO creation process. For large files, the "Generating ISO..." stage may appear to stall.
- **Status Label**: The status label provides stage-level feedback but does not include per-file details unless extended.
- **Directory Support**: The script uses a temporary directory to stage files. Direct directory selection is supported only via clipboard or manual input, which includes the entire directory tree.
- **No Progress Feedback in New-IsoFile**: The `New-IsoFile` function does not provide progress updates, limiting granularity.
- **Windows-Only**: The script relies on Windows Forms and IMAPI2FS, making it incompatible with non-Windows systems.
- **Log Directory**: Requires write permissions in `H:\Personal\Code\Logs`.
- **Temporary Directory**: Requires write permissions in `$env:TEMP`.

## Debugging

- Check the `H:\Personal\Code\Logs\guiPS.log` file for detailed logs of actions, file copying, ISO creation, progress updates, status changes, "View Log" button clicks, and errors.
- Use PowerShell's debugging tools (e.g., `Set-PSBreakpoint`) to step through the script.
- Test the `New-IsoFile` function independently with a directory:
  ```powershell
  New-IsoFile -Source "C:\path\to\temp\dir" -Path "C:\path\to\output.iso" -Force
  ```
- Verify the "View Log" button by clicking it before and after creating an ISO, checking the log for the button click entry and ensuring the file opens in the default text editor.

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
  - Enhance the progress bar and status label with per-file copying updates.
  - Add configuration options for media types or volume names.
  - Implement a log preview window within the GUI.
