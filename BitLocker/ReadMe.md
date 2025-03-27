# BitLockerEncryption.ps1

## Description
This PowerShell script checks for BitLocker disk encryption status and can enable BitLocker on unprotected volumes.

## Usage

### Check BitLocker status without enabling encryption
```powershell
.\BitLockerEncryption.ps1
```

### Check and enable BitLocker on unprotected volumes
```powershell
.\BitLockerEncryption.ps1 -Enable
```

### Specify a custom password for BitLocker (instead of default)
```powershell
.\BitLockerEncryption.ps1 -Enable -Password "SET PASSWORD "
```

## What It Does
- Checks if BitLocker feature is available
- Identifies unprotected volumes that support BitLocker
- For OS volumes: Uses TPM if available, password protector if not
- For fixed data volumes: Uses password protector

## Requirements
- Windows PowerShell 5.1 or later
- Administrator privileges
- Windows Pro, Enterprise, or Education edition
- TPM chip (recommended but not required)

## Notes
- A system restart may be required after enabling BitLocker for the first time
- For security reasons, change the default password immediately if used
- Recovery keys should be backed up securely (automatically done through Active Directory in domain environments)