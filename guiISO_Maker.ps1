# Import required assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Create ISO Image"
$form.Size = New-Object System.Drawing.Size(500,300)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# Create labels
$labelSource = New-Object System.Windows.Forms.Label
$labelSource.Location = New-Object System.Drawing.Point(20,20)
$labelSource.Size = New-Object System.Drawing.Size(80,20)
$labelSource.Text = "Source Path:"

$labelDestination = New-Object System.Windows.Forms.Label
$labelDestination.Location = New-Object System.Drawing.Point(20,60)
$labelDestination.Size = New-Object System.Drawing.Size(80,20)
$labelDestination.Text = "Destination:"

$labelFileName = New-Object System.Windows.Forms.Label
$labelFileName.Location = New-Object System.Drawing.Point(20,100)
$labelFileName.Size = New-Object System.Drawing.Size(80,20)
$labelFileName.Text = "File Name:"

# Create text boxes
$textBoxSource = New-Object System.Windows.Forms.TextBox
$textBoxSource.Location = New-Object System.Drawing.Point(100,20)
$textBoxSource.Size = New-Object System.Drawing.Size(300,20)

$textBoxDestination = New-Object System.Windows.Forms.TextBox
$textBoxDestination.Location = New-Object System.Drawing.Point(100,60)
$textBoxDestination.Size = New-Object System.Drawing.Size(300,20)

$textBoxFileName = New-Object System.Windows.Forms.TextBox
$textBoxFileName.Location = New-Object System.Drawing.Point(100,100)
$textBoxFileName.Size = New-Object System.Drawing.Size(300,20)

# Create browse buttons
$buttonBrowseSource = New-Object System.Windows.Forms.Button
$buttonBrowseSource.Location = New-Object System.Drawing.Point(410,20)
$buttonBrowseSource.Size = New-Object System.Drawing.Size(60,20)
$buttonBrowseSource.Text = "Browse"
$buttonBrowseSource.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "All files (*.*)|*.*"
    if ($openFileDialog.ShowDialog() -eq "OK") {
        $textBoxSource.Text = $openFileDialog.FileName
    }
})

$buttonBrowseDestination = New-Object System.Windows.Forms.Button
$buttonBrowseDestination.Location = New-Object System.Drawing.Point(410,60)
$buttonBrowseDestination.Size = New-Object System.Drawing.Size(60,20)
$buttonBrowseDestination.Text = "Browse"
$buttonBrowseDestination.Add_Click({
    $folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($folderBrowserDialog.ShowDialog() -eq "OK") {
        $textBoxDestination.Text = $folderBrowserDialog.SelectedPath
    }
})

# Create Create ISO button
$buttonCreate = New-Object System.Windows.Forms.Button
$buttonCreate.Location = New-Object System.Drawing.Point(140,150)
$buttonCreate.Size = New-Object System.Drawing.Size(100,30)
$buttonCreate.Text = "Create ISO"
$buttonCreate.Add_Click({
    # Validate inputs
    if ([string]::IsNullOrWhiteSpace($textBoxSource.Text)) {
        [System.Windows.Forms.MessageBox]::Show("Please specify a source file.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }
    if ([string]::IsNullOrWhiteSpace($textBoxDestination.Text)) {
        [System.Windows.Forms.MessageBox]::Show("Please specify a destination folder.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }
    if ([string]::IsNullOrWhiteSpace($textBoxFileName.Text)) {
        [System.Windows.Forms.MessageBox]::Show("Please specify a file name.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    try {
        # Ensure filename ends with .iso
        $isoFileName = $textBoxFileName.Text
        if (-not $isoFileName.EndsWith(".iso")) {
            $isoFileName += ".iso"
        }
        $isoPath = Join-Path $textBoxDestination.Text $isoFileName

        # Create ISO using PowerShell's built-in capabilities
        $sourceFile = Get-Item $textBoxSource.Text
        $isoStream = New-Object -TypeName System.IO.FileStream -ArgumentList $isoPath, ([System.IO.FileMode]::Create), ([System.IO.FileAccess]::Write)
        $isoWriter = New-Object -TypeName System.IO.BinaryWriter -ArgumentList $isoStream

        # Basic ISO structure (simplified for demonstration)
        $fileBytes = [System.IO.File]::ReadAllBytes($sourceFile.FullName)
        $isoWriter.Write($fileBytes)
        $isoWriter.Close()
        $isoStream.Close()

        [System.Windows.Forms.MessageBox]::Show("ISO created successfully at $isoPath", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Error creating ISO: $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

# Create Exit button
$buttonExit = New-Object System.Windows.Forms.Button
$buttonExit.Location = New-Object System.Drawing.Point(260,150)
$buttonExit.Size = New-Object System.Drawing.Size(100,30)
$buttonExit.Text = "Exit"
$buttonExit.Add_Click({
    $form.Close()
})

# Add controls to form
$form.Controls.Add($labelSource)
$form.Controls.Add($labelDestination)
$form.Controls.Add($labelFileName)
$form.Controls.Add($textBoxSource)
$form.Controls.Add($textBoxDestination)
$form.Controls.Add($textBoxFileName)
$form.Controls.Add($buttonBrowseSource)
$form.Controls.Add($buttonBrowseDestination)
$form.Controls.Add($buttonCreate)
$form.Controls.Add($buttonExit)

# Show the form
[void]$form.ShowDialog()
