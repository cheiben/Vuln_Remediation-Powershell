# TLS Cipher Suite Configuration Script

## Overview
This PowerShell script configures TLS cipher suites on a Windows server. It allows for setting either a secure or insecure cipher suite order based on your environment requirements.

## Features
- Configures secure TLS cipher suites for production environments
- Option to configure less secure cipher suites if needed for compatibility
- Automatically creates required registry keys if they don't exist
- Applies settings through Group Policy
- Provides verification of applied settings

## Usage
1. Open PowerShell with administrative privileges
2. Set the `$secureEnvironment` variable to:
   - `$true` for secure environments (recommended for production)
   - `$false` for less secure environments (only when backward compatibility is required)
3. Run the script
4. Restart the server to apply changes

## Requirements
- Windows Server OS
- Administrative privileges

## Notes
- A server restart is required for changes to take effect
- The secure configuration disables older, vulnerable cipher suites
- The insecure configuration includes older cipher suites for legacy application compatibility

## Security Implications
Using the insecure configuration (`$secureEnvironment = $false`) exposes your server to potential security vulnerabilities. Only use this setting when absolutely necessary for legacy system compatibility, and consider upgrading those systems as soon as possible.