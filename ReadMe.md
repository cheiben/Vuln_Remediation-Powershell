# Windows Security Toolkit

A collection of PowerShell scripts for Windows security assessment and hardening.

## Overview

This toolkit provides lightweight, modular PowerShell scripts for identifying and remediating common security vulnerabilities in Windows environments. Each script is organized in its own folder with dedicated documentation.

## Components

| Component | Description |
|-----------|-------------|
| WindowsUpdates| Checks for and installs Windows security updates |
| Disable-service | Identifies and disables unnecessary services |
| SMBSecurity| Hardens SMB protocol configuration |
| ProtocolSecurity| Disables weak TLS/SSL protocols |
| FirewallConfig| Secures Windows Firewall configuration |
| BitLocker| Enables BitLocker disk encryption |
| Guest-account| Enables/Disbales Guest account |
| Wireshark_removal| Uninstall unwanted software |
| Cypher_suite| Enables/Disables cypher |

## Quick Start

Each component has its own folder containing:
- PowerShell script(s) for specific security functions
- README.md with detailed documentation

Example usage:
```powershell
# Navigate to a component directory
cd WindowsUpdates

# View the README for documentation
Get-Content README.md

# Run the script
.\Windows-Updates.ps1 -AllUpdates
```

## Requirements

- Windows PowerShell 5.1 or later
- Administrator privileges
- Windows 10/11 or Windows Server 2016+

## Security Notes

- These scripts are designed for security hardening and should be tested in a non-production environment first
- Some scripts modify system settings and may require a restart to apply changes
- Review each component's README for specific requirements and potential impacts


## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.


by# Cheikh B