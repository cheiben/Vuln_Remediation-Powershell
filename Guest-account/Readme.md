# Guest Account Administrator Toggle

## Overview
This PowerShell script manages the Guest account's membership in the local Administrators group. It can either add or remove the Guest account from the Administrators group based on your security requirements.

## Features
- Toggles Guest account membership in the Administrators group
- Simple configuration through a single variable
- Includes checks to prevent redundant operations
- Provides clear output of actions taken

## Usage
1. Open PowerShell with administrative privileges
2. Set the `$AddGuestToAdminGroup` variable to:
   - `$True` to add Guest to the Administrators group
   - `$False` to remove Guest from the Administrators group (more secure)
3. Run the script

## Requirements
- Windows operating system
- Administrative privileges
- PowerShell 5.1 or higher

## Security Implications
Adding the Guest account to the Administrators group (`$AddGuestToAdminGroup = $True`) creates a significant security vulnerability. This configuration should only be used in isolated test environments or for specific troubleshooting scenarios, never in production environments.

## Tested On
- Windows Server 2019 Datacenter, Build 1809
- PowerShell 5.1.17763.6189