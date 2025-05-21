# ISO Creator GUI - User Guide

## Introduction
ISO Creator GUI is a simple PowerShell application that allows users to create ISO image files from a source file using a graphical interface.

## Prerequisites
- Windows operating system
- PowerShell 5.1 or later
- .NET Framework (included with Windows)

## Installation
1. Download the `Create-ISO.ps1` script
2. Save it to a desired location (e.g., `C:\Scripts\Create-ISO.ps1`)
3. Open PowerShell as Administrator
4. Set execution policy if needed:
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
   ```

## Running the Application
1. Open PowerShell
2. Navigate to the script directory:
   ```powershell
   cd C:\Scripts
   ```
3. Run the script:
   ```powershell
   .\Create-ISO.ps1
   ```

## Using the Application

### Interface Overview
The application window contains:
- **Source Path**: Input field for the source file
- **Destination**: Input field for the output folder
- **File Name**: Input field for the ISO filename
- **Browse Buttons**: Next to Source and Destination fields
- **Create ISO Button**: Initiates ISO creation
- **Exit Button**: Closes the application

### Creating an ISO File
1. **Select Source File**
   - Click the "Browse" button next to "Source Path"
   - Navigate to and select the source file
   - The file path appears in the Source Path field
2. **Select Destination Folder**
   - Click the "Browse" button next to "Destination"
   - Choose the folder where the ISO will be saved
   - The folder path appears in the Destination field
3. **Enter File Name**
   - Type the desired ISO filename in the "File Name" field
   - Extension (.iso) is optional; it will be added automatically
4. **Create the ISO**
   - Click the "Create ISO" button
   - Wait for the process to complete
   - A success message will confirm the ISO creation
   - If errors occur, an error message will display
5. **Exiting the Application**
   - Click the "Exit" button to close the application
   - Alternatively, use the window's close button

### Example
To create an ISO from `C:\Files\data.zip`:
1. Browse to select `C:\Files\data.zip` in Source Path
2. Browse to select `C:\Output` in Destination
3. Enter `myimage` in File Name
4. Click Create ISO
5. Result: `C:\Output\myimage.iso` is created
6. Click Exit to close the application

## Troubleshooting
- **"Please specify a source file"**: Ensure a source file is selected
- **"Please specify a destination folder"**: Ensure a destination folder is selected
- **"Please specify a file name"**: Ensure the File Name field is not empty
- **Permission errors**: Run PowerShell as Administrator
- **Execution policy errors**: Set execution policy as described in Installation

## Notes
- The application creates a basic ISO containing the source file
- Large files may take time to process without progress feedback
- Ensure sufficient disk space in the destination folder
- The Exit button provides a convenient way to close the application
