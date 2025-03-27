# Windows Updates Check and Install Script
# Automatically checks for updates and installs them if found

[CmdletBinding()]
param (
    [Parameter()]
    [switch]$SecurityOnly,
    
    [Parameter()]
    [switch]$ScanOnly,
    
    [Parameter()]
    [switch]$AllUpdates
)

# Display a formatted message with color
function Write-Message {
    param (
        [string]$Message,
        [string]$Color = "White"
    )
    
    Write-Host $Message -ForegroundColor $Color
}

# Check for Windows updates and return results
function Check-WindowsUpdates {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]$SecurityUpdatesOnly
    )
    
    Write-Message "Checking for missing Windows updates..." "Cyan"
    
    try {
        # Create update session
        $session = New-Object -ComObject Microsoft.Update.Session
        $searcher = $session.CreateUpdateSearcher()
        
        # Define search criteria
        $searchCriteria = "IsInstalled=0"
        if ($SecurityUpdatesOnly) {
            $searchCriteria += " AND CategoryIDs contains '0FA1201D-4330-4FA8-8AE9-B877473B6441'"
        }
        
        # Search for updates
        $searchResult = $searcher.Search($searchCriteria)
        
        if ($searchResult.Updates.Count -eq 0) {
            Write-Message "No missing updates found" "Green"
            return $null
        }
        
        Write-Message "Found $($searchResult.Updates.Count) updates available" "Yellow"
        
        # List updates
        for ($i = 0; $i -lt $searchResult.Updates.Count; $i++) {
            $update = $searchResult.Updates.Item($i)
            $severity = if ($update.MsrcSeverity) { $update.MsrcSeverity } else { "Regular" }
            Write-Message "[$($i+1)] $($update.Title) - Severity: $severity" "Yellow"
        }
        
        return $searchResult
    }
    catch {
        Write-Message "Error checking for Windows updates: $_" "Red"
        return $null
    }
}

# Install Windows updates
function Install-WindowsUpdatesFromResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        $UpdateSearchResult
    )
    
    try {
        Write-Message "Starting update installation process..." "Cyan"
        
        $session = New-Object -ComObject Microsoft.Update.Session
        $updates = $UpdateSearchResult.Updates
        
        # Create collection for updates
        $updatesToDownload = New-Object -ComObject Microsoft.Update.UpdateColl
        
        # Add updates to collection
        for ($i = 0; $i -lt $updates.Count; $i++) {
            $update = $updates.Item($i)
            if ($update.EulaAccepted -eq $false) {
                $update.AcceptEula()
            }
            $updatesToDownload.Add($update) | Out-Null
        }
        
        # Download updates
        Write-Message "Downloading updates..." "Cyan"
        $downloader = $session.CreateUpdateDownloader()
        $downloader.Updates = $updatesToDownload
        $downloadResult = $downloader.Download()
        
        if ($downloadResult.ResultCode -ne 2) {
            Write-Message "Download failed with code: $($downloadResult.ResultCode)" "Red"
            return $false
        }
        
        # Install updates
        Write-Message "Installing downloaded updates..." "Cyan"
        $installer = $session.CreateUpdateInstaller()
        $installer.Updates = $updatesToDownload
        $installResult = $installer.Install()
        
        Write-Message "Installation completed with result code: $($installResult.ResultCode)" "Cyan"
        
        if ($installResult.RebootRequired) {
            Write-Message "A system restart is required to complete the installation" "Yellow"
        }
        
        return $true
    }
    catch {
        Write-Message "Failed to install updates: $_" "Red"
        return $false
    }
}

# Main execution
Write-Message "Windows Update Checker and Installer" "Cyan"
Write-Message "--------------------------------" "Cyan"

# Determine search criteria based on parameters
# By default, search for security updates unless AllUpdates is specified
$securityOnly = if ($AllUpdates) { $false } else { $true }
if ($SecurityOnly) { $securityOnly = $true }

# Check for updates
$updates = Check-WindowsUpdates -SecurityUpdatesOnly:$securityOnly

# If updates found and not in scan-only mode, install them
if ($updates -and $updates.Updates.Count -gt 0) {
    if (-not $ScanOnly) {
        Write-Message "Updates found. Installing..." "Yellow"
        $result = Install-WindowsUpdatesFromResult -UpdateSearchResult $updates
        
        if ($result) {
            Write-Message "Update process completed successfully" "Green"
        } else {
            Write-Message "Update process encountered issues" "Red"
        }
    } else {
        Write-Message "Updates found. Run without -ScanOnly to install them." "Yellow"
    }
} elseif ($null -eq $updates) {
    Write-Message "No updates required at this time." "Green"
}