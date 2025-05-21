# CreateISO.ps1
# PowerShell script to create a GUI for generating ISO files from selected files

# Initialize logging
$LogFile = Join-Path $PSScriptRoot "guiPS.log"
function Write-Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp - $Message" | Out-File -FilePath $LogFile -Append
}

Write-Log "Application started"

# Load required assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# New-IsoFile function (modified to use temporary directory for file staging)
function New-IsoFile {
    [CmdletBinding(DefaultParameterSetName='Source')]Param(
        [parameter(Position=1,Mandatory=$true,ValueFromPipeline=$true, ParameterSetName='Source')]$Source,
        [parameter(Position=2)][string]$Path = "$env:temp\$((Get-Date).ToString('yyyyMMdd-HHmmss.ffff')).iso",
        [ValidateScript({Test-Path -LiteralPath $_ -PathType Leaf})][string]$BootFile = $null,
        [ValidateSet('CDR','CDRW','DVDRAM','DVDPLUSR','DVDPLUSRW','DVDPLUSR_DUALLAYER','DVDDASHR','DVDDASHRW','DVDDASHR_DUALLAYER','DISK','DVDPLUSRW_DUALLAYER','BDR','BDRE')][string] $Media = 'DVDPLUSRW_DUALLAYER',
        [string]$Title = (Get-Date).ToString("yyyyMMdd-HHmmss.ffff"),
        [switch]$Force,
        [parameter(ParameterSetName='Clipboard')][switch]$FromClipboard
    )

    Begin {
        ($cp = new-object System.CodeDom.Compiler.CompilerParameters).CompilerOptions = '/unsafe'
        if (!('ISOFile' -as [type])) {
            Add-Type -CompilerParameters $cp -TypeDefinition @'
public class ISOFile
{
    public unsafe static void Create(string Path, object Stream, int BlockSize, int TotalBlocks)
    {
        int bytes = 0;
        byte[] buf = new byte[BlockSize];
        var ptr = (System.IntPtr)(&bytes);
        var o = System.IO.File.OpenWrite(Path);
        var i = Stream as System.Runtime.InteropServices.ComTypes.IStream;

        if (o != null) {
            while (TotalBlocks-- > 0) {
                i.Read(buf, BlockSize, ptr); o.Write(buf, 0, bytes);
            }
            o.Flush(); o.Close();
        }
    }
}
'@
        }

        if ($BootFile) {
            if('BDR','BDRE' -contains $Media) { 
                Write-Warning "Bootable image doesn't seem to work with media type $Media"
                Write-Log "Warning: Bootable image may not work with media type $Media"
            }
            ($Stream = New-Object -ComObject ADODB.Stream -Property @{Type=1}).Open()
            $Stream.LoadFromFile((Get-Item -LiteralPath $BootFile).Fullname)
            ($Boot = New-Object -ComObject IMAPI2FS.BootOptions).AssignBootImage($Stream)
        }

        $MediaType = @('UNKNOWN','CDROM','CDR','CDRW','DVDROM','DVDRAM','DVDPLUSR','DVDPLUSRW','DVDPLUSR_DUALLAYER','DVDDASHR','DVDDASHRW','DVDDASHR_DUALLAYER','DISK','DVDPLUSRW_DUALLAYER','HDDVDROM','HDDVDR','HDDVDRAM','BDROM','BDR','BDRE')
        Write-Verbose -Message "Selected media type is $Media with value $($MediaType.IndexOf($Media))"
        Write-Log "Selected media type: $Media (value: $($MediaType.IndexOf($Media)))"
        ($Image = New-Object -com IMAPI2FS.MsftFileSystemImage -Property @{VolumeName=$Title}).ChooseImageDefaultsForMediaType($MediaType.IndexOf($Media))

        if (!($Target = New-Item -Path $Path -ItemType File -Force:$Force -ErrorAction SilentlyContinue)) { 
            Write-Error -Message "Cannot create file $Path. Use -Force parameter to overwrite if the target file already exists."
            Write-Log "Error: Cannot create file $Path"
            break 
        }
    }

    Process {
        if($FromClipboard) {
            if($PSVersionTable.PSVersion.Major -lt 5) { 
                Write-Error -Message 'The -FromClipboard parameter is only supported on PowerShell v5 or higher'
                Write-Log "Error: Clipboard not supported on PowerShell version $($PSVersionTable.PSVersion.Major)"
                break 
            }
            $Source = Get-Clipboard -Format FileDropList
        }

        foreach($item in $Source) {
            if($item -isnot [System.IO.FileInfo] -and $item -isnot [System.IO.DirectoryInfo]) {
                $item = Get-Item -LiteralPath $item -ErrorAction SilentlyContinue
                if (-not $item) {
                    Write-Error -Message "Item does not exist: $item"
                    Write-Log "Error: Item does not exist: $item"
                    continue
                }
            }

            if($item) {
                Write-Verbose -Message "Adding item to the target image: $($item.FullName)"
                Write-Log "Adding item to ISO: $($item.FullName)"
                try {
                    $Image.Root.AddTree($item.FullName, $true)
                } catch {
                    Write-Error -Message ($_.Exception.Message.Trim() + ' Try a different media type.')
                    Write-Log "Error adding item to ISO: $($_.Exception.Message)"
                }
            }
        }
    }

    End {
        if ($Boot) { $Image.BootImageOptions=$Boot }
        try {
            $Result = $Image.CreateResultImage()
            if ($Result.TotalBlocks -eq 0) {
                Write-Error -Message "No files were added to the ISO image."
                Write-Log "Error: No files were added to the ISO image"
                throw "Empty ISO image"
            }
            [ISOFile]::Create($Target.FullName,$Result.ImageStream,$Result.BlockSize,$Result.TotalBlocks)
            Write-Verbose -Message "Target image ($($Target.FullName)) has been created"
            Write-Log "Target image created: $($Target.FullName)"
        } catch {
            Write-Error -Message "Failed to create ISO: $($_.Exception.Message)"
            Write-Log "Error creating ISO: $($_.Exception.Message)"
        } finally {
            if ($Result) { [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Result) | Out-Null }
            if ($Image) { [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Image) | Out-Null }
            if ($Stream) { [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Stream) | Out-Null }
            if ($Boot) { [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Boot) | Out-Null }
            [System.GC]::Collect()
            [System.GC]::WaitForPendingFinalizers()
        }
        $Target
    }
}

# Create GUI form
$form = New-Object System.Windows.Forms.Form
$form.Text = "ISO Creator"
$form.Size = New-Object System.Drawing.Size(600,400)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# Source Label and TextBox
$lblSource = New-Object System.Windows.Forms.Label
$lblSource.Location = New-Object System.Drawing.Point(20,20)
$lblSource.Size = New-Object System.Drawing.Size(80,20)
$lblSource.Text = "Source:"
$form.Controls.Add($lblSource)

$txtSource = New-Object System.Windows.Forms.TextBox
$txtSource.Location = New-Object System.Drawing.Point(100,20)
$txtSource.Size = New-Object System.Drawing.Size(350,20)
$form.Controls.Add($txtSource)

$btnBrowseSource = New-Object System.Windows.Forms.Button
$btnBrowseSource.Location = New-Object System.Drawing.Point(460,20)
$btnBrowseSource.Size = New-Object System.Drawing.Size(100,23)
$btnBrowseSource.Text = "Browse"
$btnBrowseSource.Add_Click({
    Write-Log "Source Browse button clicked"
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Multiselect = $true
    if ($openFileDialog.ShowDialog() -eq "OK") {
        $txtSource.Text = ($openFileDialog.FileNames -join ";")
        Write-Log "Selected source files: $($openFileDialog.FileNames -join ', ')"
    }
})
$form.Controls.Add($btnBrowseSource)

# Destination Label and TextBox
$lblDestination = New-Object System.Windows.Forms.Label
$lblDestination.Location = New-Object System.Drawing.Point(20,60)
$lblDestination.Size = New-Object System.Drawing.Size(80,20)
$lblDestination.Text = "Destination:"
$form.Controls.Add($lblDestination)

$txtDestination = New-Object System.Windows.Forms.TextBox
$txtDestination.Location = New-Object System.Drawing.Point(100,60)
$txtDestination.Size = New-Object System.Drawing.Size(350,20)
$form.Controls.Add($txtDestination)

$btnBrowseDestination = New-Object System.Windows.Forms.Button
$btnBrowseDestination.Location = New-Object System.Drawing.Point(460,60)
$btnBrowseDestination.Size = New-Object System.Drawing.Size(100,23)
$btnBrowseDestination.Text = "Browse"
$btnBrowseDestination.Add_Click({
    Write-Log "Destination Browse button clicked"
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($folderBrowser.ShowDialog() -eq "OK") {
        $txtDestination.Text = $folderBrowser.SelectedPath
        Write-Log "Selected destination folder: $($folderBrowser.SelectedPath)"
    }
})
$form.Controls.Add($btnBrowseDestination)

# File Name Label and TextBox
$lblFileName = New-Object System.Windows.Forms.Label
$lblFileName.Location = New-Object System.Drawing.Point(20,100)
$lblFileName.Size = New-Object System.Drawing.Size(80,20)
$lblFileName.Text = "File Name:"
$form.Controls.Add($lblFileName)

$txtFileName = New-Object System.Windows.Forms.TextBox
$txtFileName.Location = New-Object System.Drawing.Point(100,100)
$txtFileName.Size = New-Object System.Drawing.Size(350,20)
$txtFileName.Text = "output.iso"
$form.Controls.Add($txtFileName)

# Create ISO Button
$btnCreateISO = New-Object System.Windows.Forms.Button
$btnCreateISO.Location = New-Object System.Drawing.Point(100,150)
$btnCreateISO.Size = New-Object System.Drawing.Size(100,30)
$btnCreateISO.Text = "Create ISO"
$btnCreateISO.Add_Click({
    Write-Log "Create ISO button clicked"
    
    # Validate inputs
    if (-not $txtSource.Text) {
        [System.Windows.Forms.MessageBox]::Show("Please specify at least one source file.", "Error", "OK", "Error")
        Write-Log "Error: Source file(s) not specified"
        return
    }
    if (-not $txtDestination.Text) {
        [System.Windows.Forms.MessageBox]::Show("Please specify a destination folder.", "Error", "OK", "Error")
        Write-Log "Error: Destination folder not specified"
        return
    }
    if (-not $txtFileName.Text) {
        [System.Windows.Forms.MessageBox]::Show("Please specify a file name.", "Error", "OK", "Error")
        Write-Log "Error: File name not specified"
        return
    }

    # Validate source files
    $sourceFiles = $txtSource.Text -split ";"
    foreach ($file in $sourceFiles) {
        if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
            [System.Windows.Forms.MessageBox]::Show("Source file does not exist: $file", "Error", "OK", "Error")
            Write-Log "Error: Source file does not exist: $file"
            return
        }
    }

    # Ensure .iso extension
    $isoName = $txtFileName.Text
    if (-not $isoName.EndsWith(".iso")) {
        $isoName += ".iso"
    }

    try {
        # Create temporary directory for staging files
        $tempDir = Join-Path $env:TEMP "ISOCreator_$(Get-Date -Format 'yyyyMMddHHmmss')"
        Write-Log "Creating temporary directory: $tempDir"
        New-Item -Path $tempDir -ItemType Directory -Force | Out-Null

        # Copy selected files to temporary directory
        foreach ($file in $sourceFiles) {
            $fileName = [System.IO.Path]::GetFileName($file)
            $destFile = Join-Path $tempDir $fileName
            Write-Log "Copying file to temp directory: $file -> $destFile"
            Copy-Item -LiteralPath $file -Destination $destFile -Force
            if (-not (Test-Path $destFile)) {
                throw "Failed to copy file to temporary directory: $file"
            }
        }

        Write-Log "Creating ISO with Source: $tempDir, Destination: $($txtDestination.Text), FileName: $isoName"
        $isoPath = Join-Path $txtDestination.Text $isoName
        New-IsoFile -Source $tempDir -Path $isoPath -Force

        # Verify ISO size
        $isoFile = Get-Item -LiteralPath $isoPath -ErrorAction SilentlyContinue
        if ($isoFile -and $isoFile.Length -eq 0) {
            throw "Created ISO file is empty: $isoPath"
        }

        [System.Windows.Forms.MessageBox]::Show("ISO created successfully at $isoPath", "Success", "OK", "Information")
        Write-Log "ISO created successfully at $isoPath"
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to create ISO: $($_.Exception.Message)", "Error", "OK", "Error")
        Write-Log "Error creating ISO: $($_.Exception.Message)"
    } finally {
        # Clean up temporary directory
        if (Test-Path $tempDir) {
            Write-Log "Cleaning up temporary directory: $tempDir"
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
})
$form.Controls.Add($btnCreateISO)

# Exit Button
$btnExit = New-Object System.Windows.Forms.Button
$btnExit.Location = New-Object System.Drawing.Point(220,150)
$btnExit.Size = New-Object System.Drawing.Size(100,30)
$btnExit.Text = "Exit"
$btnExit.Add_Click({
    Write-Log "Exit button clicked"
    $form.Close()
})
$form.Controls.Add($btnExit)

# Show the form
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()

Write-Log "Application closed"
