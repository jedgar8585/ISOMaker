# ISO Creator GUI - Developer Documentation

## Overview
The ISO Creator GUI is a PowerShell script (`Create-ISO.ps1`) that uses Windows Forms to create a graphical interface for generating ISO image files. This document provides a detailed source-level explanation of the application's structure and implementation.

## Source Code Structure

### Dependencies
- **System.Windows.Forms**: Provides GUI components
- **System.Drawing**: Handles form sizing and positioning
- Both loaded via `Add-Type` at script start

### Main Components

1. **Form Setup**
```powershell
$form = New-Object System.Windows.Forms.Form
$form.Text = "Create ISO Image"
$form.Size = New-Object System.Drawing.Size(500,300)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false
```
- Creates a fixed-size (500x300) window
- Centers on screen
- Disables maximize to maintain consistent layout

2. **UI Elements**
- **Labels** (3): Source Path, Destination, File Name
  - Created using `System.Windows.Forms.Label`
  - Positioned at (20,Y) with 80x20 size
- **Text Boxes** (3): Input fields for source, destination, filename
  - Created using `System.Windows.Forms.TextBox`
  - Positioned at (100,Y) with 300x20 size
- **Browse Buttons** (2): For source file and destination folder
  - Created using `System.Windows.Forms.Button`
  - Positioned at (410,Y) with 60x20 size
- **Create ISO Button**
  - Positioned at (140,150) with 100x30 size
- **Exit Button**
  - Positioned at (260,150) with 100x30 size
  - Closes the application when clicked

3. **Event Handlers**
- **Source Browse Button** (`$buttonBrowseSource.Add_Click`)
  - Uses `System.Windows.Forms.OpenFileDialog`
  - Sets selected file path to `$textBoxSource`
- **Destination Browse Button** (`$buttonBrowseDestination.Add_Click`)
  - Uses `System.Windows.Forms.FolderBrowserDialog`
  - Sets selected folder path to `$textBoxDestination`
- **Create ISO Button** (`$buttonCreate.Add_Click`)
  - Validates inputs
  - Ensures .iso extension
  - Creates ISO using binary file operations
  - Displays success/error messages
- **Exit Button** (`$buttonExit.Add_Click`)
  - Calls `$form.Close()` to exit the application

4. **ISO Creation Logic**
```powershell
$isoStream = New-Object -TypeName System.IO.FileStream -ArgumentList $isoPath, ([System.IO.FileMode]::Create), ([System.IO.FileAccess]::Write)
$isoWriter = New-Object -TypeName System.IO.BinaryWriter -ArgumentList $isoStream
$fileBytes = [System.IO.File]::ReadAllBytes($sourceFile.FullName)
$isoWriter.Write($fileBytes)
```
- Creates a new file stream for the ISO
- Reads source file bytes
- Writes bytes to ISO file
- Closes streams

## Implementation Notes
- **Simplified ISO Creation**: Current implementation performs basic binary copying to an ISO container. Real-world use may require integration with tools like `oscdimg` for proper ISO9660/UDF formatting.
- **Error Handling**: Uses try-catch block with message box outputs for user feedback.
- **Input Validation**: Checks for empty fields before processing.
- **UI Constraints**: Fixed form size and disabled maximize to ensure consistent user experience.
- **Exit Button**: Added to provide a user-friendly way to close the application, complementing the window's close button.

## Extensibility
- Add support for multiple source files
- Integrate with proper ISO creation libraries
- Add progress bar for large files
- Implement volume label customization
- Add compression options

## Contribution Guidelines
1. Fork the repository
2. Create feature branches
3. Submit pull requests with clear descriptions
4. Follow PowerShell coding standards
5. Include tests for new functionality

## Known Limitations
- Basic ISO structure (no advanced filesystem features)
- Single file input only
- No progress feedback for large files
- Limited ISO format customization
