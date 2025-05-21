# ISO Creator

## Overview
ISO Creator GUI is a PowerShell-based application that provides a graphical user interface for creating ISO image files from a specified source file. The application allows users to select a source file, specify a destination folder, and provide a filename for the resulting ISO file.

## Features
- Simple Windows Forms GUI
- Input fields for source file, destination folder, and output filename
- Browse buttons for easy file and folder selection
- Create ISO button to generate the ISO file
- Exit button to close the application
- Basic input validation
- Error handling with user-friendly message boxes

## Prerequisites
- Windows operating system
- PowerShell 5.1 or later
- .NET Framework (included with Windows)

## Installation
1. Save the `Create-ISO.ps1` script to a desired location
2. Ensure PowerShell execution policy allows running scripts (`Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned`)

## Usage
Run the script in PowerShell:
```powershell
.\Create-ISO.ps1
```
See USERS_GUIDE.md for detailed usage instructions.

## Contributing
See DEVELOPERS.md for technical details and contribution guidelines.

## License
MIT License
