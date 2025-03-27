# Windows-Updates.ps1

## Description
A simple PowerShell script to check for and install Windows updates. This script can scan for available updates and optionally install them automatically.

## Usage

### Check and install all updates (including non-security updates)
```powershell
.\Windows-Updates.ps1 -AllUpdates
```

### Check for all updates without installing them
```powershell
.\Windows-Updates.ps1 -AllUpdates -ScanOnly
```

### Check and install security updates only
```powershell
.\Windows-Updates.ps1 -SecurityOnly
```

## Requirements
- Windows PowerShell 5.1 or later
- Administrator privileges
- Internet connection

## Notes
- The script will display a notification if a system restart is required after installing updates
- Colored output shows status of operations (green for success, yellow for warnings, red for errors)