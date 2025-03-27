# Simple Service Hardening Script
# Run with -Disable to disable unnecessary services

param (
    [switch]$Disable
)

# List of potentially unnecessary services that pose security risks
$riskServices = @(
    "Telnet", 
    "TlntSvr", 
    "ftpsvc", 
    "SNMP", 
    "SharedAccess", 
    "RemoteRegistry", 
    "SSDPSRV", 
    "upnphost", 
    "WMSvc", 
    "RpcLocator", 
    "NetTcpPortSharing"
)

function Check-UnnecessaryServices {
    Write-Host "Checking for unnecessary services..." -ForegroundColor Cyan
    
    $runningServices = @()
    
    foreach ($serviceName in $riskServices) {
        $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
        
        if ($service) {
            $startType = (Get-WmiObject -Class Win32_Service -Filter "Name='$($service.Name)'").StartMode
            
            if ($service.Status -eq "Running" -or $startType -ne "Disabled") {
                Write-Host "Unnecessary service found: $($service.DisplayName) [$($service.Name)] - Status: $($service.Status), Start Type: $startType" -ForegroundColor Yellow
                $runningServices += $service
            }
        }
    }
    
    if ($runningServices.Count -eq 0) {
        Write-Host "No unnecessary services running" -ForegroundColor Green
    }
    
    return $runningServices
}

function Disable-RiskServices {
    param($services)
    
    Write-Host "Disabling unnecessary services..." -ForegroundColor Cyan
    
    $disabledCount = 0
    
    foreach ($service in $services) {
        Write-Host "Processing service: $($service.DisplayName) [$($service.Name)]" -ForegroundColor Cyan
        
        if ($service.Status -eq "Running") {
            try {
                Stop-Service -Name $service.Name -Force -ErrorAction Stop
                Write-Host "Service stopped: $($service.DisplayName)" -ForegroundColor Green
            }
            catch {
                Write-Host "Error stopping service $($service.DisplayName): $_" -ForegroundColor Red
            }
        }
        
        try {
            Set-Service -Name $service.Name -StartupType Disabled -ErrorAction Stop
            Write-Host "Service disabled: $($service.DisplayName)" -ForegroundColor Green
            $disabledCount++
        }
        catch {
            Write-Host "Error disabling service $($service.DisplayName): $_" -ForegroundColor Red
        }
    }
    
    Write-Host "Successfully disabled $disabledCount services" -ForegroundColor Green
}

# Main execution
$services = Check-UnnecessaryServices

if ($Disable -and $services.Count -gt 0) {
    Disable-RiskServices -services $services
}