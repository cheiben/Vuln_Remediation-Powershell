# Simple BitLocker Enablement Script
# Run with -Enable to enable BitLocker on unprotected volumes

param (
    [switch]$Enable,
    [string]$Password = "SET YOU PASSWORD!"  # Change this in production!
)

function Check-BitLockerStatus {
    Write-Host "Checking BitLocker status..." -ForegroundColor Cyan
    
    try {
        # Check if BitLocker feature is available
        $bitlockerFeature = Get-WindowsOptionalFeature -FeatureName BitLocker -Online -ErrorAction SilentlyContinue
        
        if (-not $bitlockerFeature -or $bitlockerFeature.State -ne "Enabled") {
            Write-Host "BitLocker feature is not enabled on this system" -ForegroundColor Yellow
            return @{
                NotAvailable = $true
                UnprotectedVolumes = @()
            }
        }
        
        # Get BitLocker volume status
        $bitlockerVolumes = Get-BitLockerVolume -ErrorAction Stop
        $unprotectedVolumes = @()
        
        foreach ($volume in $bitlockerVolumes) {
            # Skip non-fixed drives like USB drives
            if ($volume.VolumeType -ne "OperatingSystem" -and $volume.VolumeType -ne "Fixed") {
                continue
            }
            
            if ($volume.VolumeStatus -ne "FullyEncrypted" -and $volume.VolumeStatus -ne "EncryptionInProgress") {
                Write-Host "Unprotected volume found: $($volume.MountPoint) - $($volume.VolumeType) - Status: $($volume.VolumeStatus)" -ForegroundColor Yellow
                $unprotectedVolumes += $volume
            }
        }
        
        if ($unprotectedVolumes.Count -eq 0) {
            Write-Host "All supported volumes are protected by BitLocker" -ForegroundColor Green
        }
        
        return @{
            NotAvailable = $false
            UnprotectedVolumes = $unprotectedVolumes
        }
    }
    catch {
        Write-Host "Error checking BitLocker status: $_" -ForegroundColor Red
        return @{
            NotAvailable = $true
            UnprotectedVolumes = @()
            Error = $_.Exception.Message
        }
    }
}

function Enable-BitLockerEncryption {
    param(
        $unprotectedVolumes,
        $password
    )
    
    Write-Host "Enabling BitLocker on unprotected volumes..." -ForegroundColor Cyan
    $rebootRequired = $false
    
    # First, check if BitLocker feature is available
    $bitlockerFeature = Get-WindowsOptionalFeature -FeatureName BitLocker -Online -ErrorAction SilentlyContinue
    
    if (-not $bitlockerFeature -or $bitlockerFeature.State -ne "Enabled") {
        Write-Host "BitLocker feature is not enabled on this system. Attempting to enable..." -ForegroundColor Yellow
        
        try {
            Enable-WindowsOptionalFeature -FeatureName BitLocker -Online -NoRestart -ErrorAction Stop
            Write-Host "BitLocker feature enabled" -ForegroundColor Green
            $rebootRequired = $true
        }
        catch {
            Write-Host "Failed to enable BitLocker feature: $_" -ForegroundColor Red
            return
        }
    }
    
    $enabledCount = 0
    
    foreach ($volume in $unprotectedVolumes) {
        Write-Host "Attempting to enable BitLocker on $($volume.MountPoint)..." -ForegroundColor Cyan
        
        try {
            # For OS volume, use TPM if available
            if ($volume.VolumeType -eq "OperatingSystem") {
                $tpm = Get-Tpm -ErrorAction SilentlyContinue
                
                if ($tpm -and $tpm.TpmPresent -and $tpm.TpmReady) {
                    Enable-BitLocker -MountPoint $volume.MountPoint -TpmProtector -ErrorAction Stop
                    Write-Host "Enabled BitLocker with TPM protector on $($volume.MountPoint)" -ForegroundColor Green
                }
                else {
                    # If TPM not available, use password protector
                    $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
                    Enable-BitLocker -MountPoint $volume.MountPoint -PasswordProtector -Password $securePassword -ErrorAction Stop
                    Write-Host "Enabled BitLocker with password protector on $($volume.MountPoint)" -ForegroundColor Green
                    Write-Host "Warning: Using a password protector for OS volume is not recommended" -ForegroundColor Yellow
                }
            }
            else {
                # Use password protector for fixed drives
                $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
                Enable-BitLocker -MountPoint $volume.MountPoint -PasswordProtector -Password $securePassword -ErrorAction Stop
                Write-Host "Enabled BitLocker with password protector on $($volume.MountPoint)" -ForegroundColor Green
            }
            
            $enabledCount++
        }
        catch {
            Write-Host "Failed to enable BitLocker on $($volume.MountPoint): $_" -ForegroundColor Red
        }
    }
    
    if ($enabledCount -gt 0) {
        Write-Host "Successfully enabled BitLocker on $enabledCount volumes" -ForegroundColor Green
    }
    
    if ($rebootRequired) {
        Write-Host "A system restart is required to complete BitLocker setup" -ForegroundColor Yellow
    }
}

# Main execution
$status = Check-BitLockerStatus

if ($Enable -and -not $status.NotAvailable -and $status.UnprotectedVolumes.Count -gt 0) {
    Enable-BitLockerEncryption -unprotectedVolumes $status.UnprotectedVolumes -password $Password
}