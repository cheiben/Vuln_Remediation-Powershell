# Disable-Services.ps1

## Description
This PowerShell script identifies and optionally disables unnecessary Windows services that may pose security risks. It focuses on services that are commonly targeted in security exploits.

## Usage

### Check for unnecessary services without disabling them
```powershell
.\Disable-Services.ps1
```

### Check and disable unnecessary services
```powershell
.\Disable-Services.ps1 -Disable
```

## Services Checked
- Telnet
- FTP
- SNMP
- Remote Registry
- SSDP
- UPnP
- And others that may pose security risks

## Requirements
- Windows PowerShell 5.1 or later
- Administrator privileges

## Notes
- By default, the script only scans for services without making changes
- Use the -Disable parameter with caution as it will stop and disable services
- Disabling certain services might affect system functionality depending on your environment