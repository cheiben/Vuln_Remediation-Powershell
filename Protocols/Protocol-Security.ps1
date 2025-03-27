# Simple TLS/SSL Protocol Security Script
# Run with -Secure to disable weak protocols

param (
    [switch]$Secure
)

function Check-WeakProtocols {
    Write-Host "Checking for weak TLS/SSL protocols..." -ForegroundColor Cyan
    
    $weakProtocols = @(
        @{Name = "SSL 2.0"; Path = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0"},
        @{Name = "SSL 3.0"; Path = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0"},
        @{Name = "TLS 1.0"; Path = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0"},
        @{Name = "TLS 1.1"; Path = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1"}
    )
    
    $enabledProtocols = @()
    
    foreach ($protocol in $weakProtocols) {
        $serverPath = "$($protocol.Path)\Server"
        $clientPath = "$($protocol.Path)\Client"
        
        $serverEnabled = $true
        $clientEnabled = $true
        
        # Check server side
        if (Test-Path $serverPath) {
            $serverSetting = Get-ItemProperty -Path $serverPath -Name "Enabled" -ErrorAction SilentlyContinue
            if ($serverSetting -and $serverSetting.Enabled -eq 0) {
                $serverEnabled = $false
            }
        }
        
        # Check client side
        if (Test-Path $clientPath) {
            $clientSetting = Get-ItemProperty -Path $clientPath -Name "Enabled" -ErrorAction SilentlyContinue
            if ($clientSetting -and $clientSetting.Enabled -eq 0) {
                $clientEnabled = $false
            }
        }
        
        if ($serverEnabled -or $clientEnabled) {
            Write-Host "Weak protocol enabled: $($protocol.Name) - Server: $serverEnabled, Client: $clientEnabled" -ForegroundColor Yellow
            $enabledProtocols += $protocol
        }
    }
    
    if ($enabledProtocols.Count -eq 0) {
        Write-Host "No weak TLS/SSL protocols enabled" -ForegroundColor Green
    }
    
    return $enabledProtocols
}

function Disable-WeakProtocols {
    param($protocols)
    
    Write-Host "Disabling weak TLS/SSL protocols..." -ForegroundColor Cyan
    
    foreach ($protocol in $protocols) {
        $serverPath = "$($protocol.Path)\Server"
        $clientPath = "$($protocol.Path)\Client"
        
        # Create paths if they don't exist
        if (!(Test-Path $protocol.Path)) {
            New-Item -Path $protocol.Path -Force | Out-Null
        }
        if (!(Test-Path $serverPath)) {
            New-Item -Path $serverPath -Force | Out-Null
        }
        if (!(Test-Path $clientPath)) {
            New-Item -Path $clientPath -Force | Out-Null
        }
        
        # Disable server-side protocol
        New-ItemProperty -Path $serverPath -Name "Enabled" -Value 0 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $serverPath -Name "DisabledByDefault" -Value 1 -PropertyType DWORD -Force | Out-Null
        
        # Disable client-side protocol
        New-ItemProperty -Path $clientPath -Name "Enabled" -Value 0 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $clientPath -Name "DisabledByDefault" -Value 1 -PropertyType DWORD -Force | Out-Null
        
        Write-Host "Disabled $($protocol.Name)" -ForegroundColor Green
    }
    
    # Enable TLS 1.2
    $tls12Path = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2"
    $tls12ServerPath = "$tls12Path\Server"
    $tls12ClientPath = "$tls12Path\Client"
    
    # Create paths if they don't exist
    if (!(Test-Path $tls12Path)) {
        New-Item -Path $tls12Path -Force | Out-Null
    }
    if (!(Test-Path $tls12ServerPath)) {
        New-Item -Path $tls12ServerPath -Force | Out-Null
    }
    if (!(Test-Path $tls12ClientPath)) {
        New-Item -Path $tls12ClientPath -Force | Out-Null
    }
    
    # Enable TLS 1.2
    New-ItemProperty -Path $tls12ServerPath -Name "Enabled" -Value 1 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $tls12ServerPath -Name "DisabledByDefault" -Value 0 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $tls12ClientPath -Name "Enabled" -Value 1 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $tls12ClientPath -Name "DisabledByDefault" -Value 0 -PropertyType DWORD -Force | Out-Null
    
    Write-Host "Enabled TLS 1.2" -ForegroundColor Green
    Write-Host "A system restart is required for protocol changes to take effect" -ForegroundColor Yellow
}

# Main execution
$enabledProtocols = Check-WeakProtocols

if ($Secure -and $enabledProtocols.Count -gt 0) {
    Disable-WeakProtocols -protocols $enabledProtocols
}