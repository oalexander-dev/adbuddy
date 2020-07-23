# ADBuddy PowerShell Utility

This ps utility runs alongside VISTA and monitors active ADB device connections.
When a connection state changes, the engineer is alerted via SMS.

## Usage
First, locate PowerShell modules folder. Copy the PowerShell-SMS/ folder to this location.

Inside of root directory,
`./adbuddy.ps1 -contact 13334445555`

-contact <phone number> sets who will recieve alerts when a device connection changes.
