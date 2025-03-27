# SMB-Security.ps1

## Description
This PowerShell script assesses and remedies SMB protocol security vulnerabilities, including disabling SMBv1, enabling SMB signing, and configuring encryption.

## Usage

### Check SMB security configuration without making changes
```powershell
.\SMB-Security.ps1
```

### Check and fix SMB security issues
```powershell
.\SMB-Security.ps1 -Secure
```

## What It Checks
- SMBv1 protocol (vulnerable to WannaCry/EternalBlue attacks)
- SMB signing requirements
- SMB encryption settings
- SMB port exposure

## Requirements
- Windows PowerShell 5.1 or later
- Administrator privileges
- Windows Server or Windows 10/11

## Notes
- A system restart may be required after disabling SMBv1
- Securing SMB is critical to prevent lateral movement in networks
- This script follows security best practices from Microsoft