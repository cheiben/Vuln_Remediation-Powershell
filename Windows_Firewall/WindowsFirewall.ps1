# Simple Firewall Configuration Script
# Run with -Secure to fix firewall security issues

param (
    [switch]$Secure
)

function Check-FirewallConfig {
    Write-Host "Checking Windows Firewall configuration..." -ForegroundColor Cyan
    
    $issues = @()
    
    try {
        $firewallProfiles = Get-NetFirewallProfile -ErrorAction Stop
        
        foreach ($profile in $firewallProfiles) {
            if (-not $profile.Enabled) {
                Write-Host "Windows Firewall is disabled for profile: $($profile.Name)" -ForegroundColor Red
                $issues += "$($profile.Name): Firewall disabled"
            }
            
            if ($profile.DefaultInboundAction -eq "Allow") {
                Write-Host "Windows Firewall default inbound action is set to Allow for profile: $($profile.Name)" -ForegroundColor Red
                $issues += "$($profile.Name): Default inbound action is Allow"
            }
        }
        
        if ($issues.Count -eq 0) {
            Write-Host "Windows Firewall is properly configured" -ForegroundColor Green
        }
        
        return $issues
    }
    catch {
        Write-Host "Error checking Windows Firewall configuration: $_" -ForegroundColor Red
        return $false
    }
}

function Secure-Firewall {
    param($issues)
    
    Write-Host "Fixing Windows Firewall configuration..." -ForegroundColor Cyan
    
    try {
        $firewallProfiles = Get-NetFirewallProfile -ErrorAction Stop
        $fixedCount = 0
        
        foreach ($profile in $firewallProfiles) {
            $changes = @()
            
            if ($issues -contains "$($profile.Name): Firewall disabled") {
                Set-NetFirewallProfile -Name $profile.Name -Enabled True -ErrorAction Stop
                $changes += "Enabled firewall"
                $fixedCount++
            }
            
            if ($issues -contains "$($profile.Name): Default inbound action is Allow") {
                Set-NetFirewallProfile -Name $profile.Name -DefaultInboundAction Block -ErrorAction Stop
                $changes += "Set default inbound action to Block"
                $fixedCount++
            }
            
            if ($changes.Count -gt 0) {
                Write-Host "Fixed Windows Firewall configuration for profile $($profile.Name): $($changes -join ', ')" -ForegroundColor Green
            }
        }
        
        if ($fixedCount -gt 0) {
            Write-Host "Successfully fixed Windows Firewall configuration issues" -ForegroundColor Green
        }
        else {
            Write-Host "No Windows Firewall configuration issues to fix" -ForegroundColor Cyan
        }
    }
    catch {
        Write-Host "Error fixing Windows Firewall configuration: $_" -ForegroundColor Red
    }
}

# Main execution
$issues = Check-FirewallConfig

if ($Secure -and $issues.Count -gt 0) {
    Secure-Firewall -issues $issues
}