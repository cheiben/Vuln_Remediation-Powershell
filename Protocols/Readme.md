# Protocol-Security.ps1

## Description
This PowerShell script checks for and disables weak TLS/SSL protocols on Windows systems while ensuring strong protocols are enabled.

## Usage

### Check for weak protocols without disabling them
```powershell
.\Protocol-Security.ps1
```

### Check and disable weak protocols
```powershell
.\Protocol-Security.ps1 -Secure
```

## Protocols Managed
- Disables: SSL 2.0, SSL 3.0, TLS 1.0, TLS 1.1 (insecure protocols)
- Enables: TLS 1.2 (secure protocol)

## Requirements
- Windows PowerShell 5.1 or later
- Administrator privileges
- Windows Server or Windows 10/11

## Notes
- A system restart is required after making protocol changes
- Disabling older protocols may affect compatibility with legacy applications
- Modern security standards require TLS 1.2 or higher