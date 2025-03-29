# Wireshark Uninstallation Script

## Overview
This PowerShell script automatically uninstalls Wireshark 2.2.1 (64-bit) from Windows systems. It provides a simple and consistent method for removing Wireshark installations across multiple machines.

## Features
- Silently uninstalls Wireshark without user interaction
- Verifies if Wireshark is installed before attempting removal
- Provides status output during the uninstallation process

## Usage
1. Open PowerShell with administrative privileges
2. Navigate to the directory containing the script
3. Execute the script:
   ```
   .\wireshark-removal.ps1
   ```

## Requirements
- Windows Server 2019 Datacenter (Build 1809) or compatible Windows system
- PowerShell 5.1 or higher
- Administrative privileges
- Wireshark 2.2.1 (64-bit) installation

## Tested Environments
- Windows Server 2019 Datacenter, Build 1809
- PowerShell 5.1.17763.6189
- Wireshark 2.2.1 (v2.2.1-0-ga6fbd27 from master-2.2)

## Author Information
- Author: Josh Madakor
- Created: September 9, 2024
- Version: 1.0