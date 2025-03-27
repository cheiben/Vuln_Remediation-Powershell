# Simple SMB Security Script
# Run with -Secure to fix SMB security issues

param (
    [switch]$Secure
)

function Check-SMBSecurity {
    Write-Host "Checking SMB security configuration..." -ForegroundColor Cyan
    
    $vulnerabilities = @()
    
    # Check if SMBv1 is enabled (major security risk)
    try {
        $smb1Feature = Get-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -ErrorAction SilentlyContinue
        if ($smb1Feature -and $smb1Feature.State -eq "Enabled") {
            Write-Host "Critical vulnerability: SMBv1 protocol is enabled" -ForegroundColor Red
            $vulnerabilities += "SMBv1 Protocol Enabled"
        }
    }
    catch {
        # Try alternative check method
        $smb1Config = Get-SmbServerConfiguration -ErrorAction SilentlyContinue | Select-Object EnableSMB1Protocol
        if ($smb1Config -and $smb1Config.EnableSMB1Protocol) {
            Write-Host "Critical vulnerability: SMBv1 protocol is enabled" -ForegroundColor Red
            $vulnerabilities += "SMBv1 Protocol Enabled"
        }
    }
    
    # Check SMB Signing requirements
    $smbConfig = Get-SmbServerConfiguration -ErrorAction SilentlyContinue
    if ($smbConfig) {
        if (-not $smbConfig.RequireSecuritySignature) {
            Write-Host "High severity: SMB signing is not required" -ForegroundColor Red
            $vulnerabilities += "SMB Signing Not Required"
        }
        
        if (-not $smbConfig.EncryptData) {
            Write-Host "Medium severity: SMB encryption is not enabled" -ForegroundColor Yellow
            $vulnerabilities += "SMB Encryption Not Enabled"
        }
    }
    
    if ($vulnerabilities.Count -eq 0) {
        Write-Host "SMB is securely configured" -ForegroundColor Green
    }
    
    return $vulnerabilities
}

function Secure-SMB {
    param($vulnerabilities)
    
    Write-Host "Fixing SMB security configuration..." -ForegroundColor Cyan
    
    $rebootRequired = $false
    
    # Disable SMBv1 Protocol if needed
    if ($vulnerabilities -contains "SMBv1 Protocol Enabled") {
        try {
            $smb1Feature = Get-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -ErrorAction SilentlyContinue
            if ($smb1Feature -and $smb1Feature.State -eq "Enabled") {
                Write-Host "Disabling SMBv1 protocol feature..." -ForegroundColor Cyan
                Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -NoRestart | Out-Null
                Write-Host "Disabled SMBv1 protocol feature" -ForegroundColor Green
                $rebootRequired = $true
            }
        }
        catch {
            Write-Host "Error disabling SMBv1 Windows feature: $_" -ForegroundColor Red
            
            # Try alternative method
            try {
                Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force -ErrorAction Stop
                Write-Host "Disabled SMBv1 protocol using SMB configuration" -ForegroundColor Green
            }
            catch {
                Write-Host "Error disabling SMBv1 protocol: $_" -ForegroundColor Red
            }
        }
    }
    
    # Enable SMB Signing and Encryption if needed
    try {
        $smbConfig = Get-SmbServerConfiguration -ErrorAction SilentlyContinue
        if ($smbConfig) {
            if ($vulnerabilities -contains "SMB Signing Not Required") {
                Set-SmbServerConfiguration -RequireSecuritySignature $true -Force -ErrorAction Stop
                Write-Host "Enabled required SMB signing" -ForegroundColor Green
            }
            
            if ($vulnerabilities -contains "SMB Encryption Not Enabled") {
                Set-SmbServerConfiguration -EncryptData $true -Force -ErrorAction Stop
                Write-Host "Enabled SMB encryption" -ForegroundColor Green
            }
        }
    }
    catch {
        Write-Host "Error configuring SMB security settings: $_" -ForegroundColor Red
    }
    
    if ($rebootRequired) {
        Write-Host "A system restart is required to complete the changes" -ForegroundColor Yellow
    }
}

# Main execution
$vulnerabilities = Check-SMBSecurity

if ($Secure -and $vulnerabilities.Count -gt 0) {
    Secure-SMB -vulnerabilities $vulnerabilities
}