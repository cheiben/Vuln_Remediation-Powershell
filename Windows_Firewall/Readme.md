# Windows_Firewall.ps1

## Description
This PowerShell script assesses and remediates Windows Firewall configuration issues to ensure proper security settings.

## Usage

### Check firewall configuration without making changes
```powershell
.\Windows_Firewall.ps1
```

### Check and fix firewall configuration issues
```powershell
.\Windows_Firewall.ps1 -Secure
```

## What It Checks
- Firewall profile states (enabled/disabled)
- Default inbound action settings
- Notification configurations

## Requirements
- Windows PowerShell 5.1 or later
- Administrator privileges

## Notes
- The script ensures each firewall profile (Domain, Private, Public) is properly configured
- For best security, default inbound action should be set to Block
- No restart is required after applying these changes