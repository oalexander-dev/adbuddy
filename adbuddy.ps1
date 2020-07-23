# ADBuddy Powershell Script
#
# Runs alongside VISTA, scans for ADB connection errors, attempts to fix issues,
# alerts the testing engineer when it can not.

Import-Module PowerShell-SMS

param (
    [string]$contact = "12488209074",
)

# COMMAND LIBRARY
# Run these with 'Invoke-Expression <$command>'
$adb = ".\platform-tools\adb "
$POLL_DEVICES = $adb + "devices" | Out-String


# SCRIPT
# configure SMS alerts
Set-Nexmo -APIKey bad98693 -APISecret Oz1n96dFeaftEcSJ

# initial devices poll
$device_list_string = Invoke-Expression $POLL_DEVICES

# format string to store by removing title and word device from each line
$device_list_string = ($device_list_string).replace("List of devices attached", "")
$device_list_string = ($device_list_string).replace("device", "")

# parse remaining text for device names, save to array
$device_list = @($device_list_string).Split("[\s]+", [System.StringSplitOptions]::RemoveEmptyEntries)
$device_count = $device_list.Count

# prints device names
Write-Output "`n Devices:"
for ($index = 0; $index -lt $device_list.Count; $index++) {
    Write-Output "  Device $($index + 1): $($device_list[$($index)])"
}

# initial check console message
Write-Output "`n initial scan complete, found $($device_count) devices"
Write-Output "`n begin monitoring: `n"

$loop_count = 0

# monitoring loop
while ($true) {
    # poll devices
    $device_list_string = Invoke-Expression $POLL_DEVICES

    # compare count to previous count after reading in device list
    $device_list_string = ($device_list_string).replace("List of devices attached", "")
    $device_list_string = ($device_list_string).replace("device", "")
    # parse remaining text for device names, save to array
    $device_list = @($device_list_string).Split("[\s]+", [System.StringSplitOptions]::RemoveEmptyEntries)
    $device_count_active = $device_list.Count
    
    # if different or every tenth cycle, give message
    if ($device_count_active -ne $device_count) {
        Write-Output "ERROR: change detected in device list"
        $res = Send-SMS -Provider Nexmo -From 17192126596 -To $contact -Message "ADBuddy error: device disconnected"

        # handle exit with message
        Write-Output "`n done monitoring `n"
        Exit 
    } elseif (($loop_count % 10) -eq 1) {
        Write-Output "status is good at cycle $($loop_count)"
    }

    # delay
    Start-Sleep -Seconds 10
    $loop_count = $loop_count + 1
}

# exit message
Write-Output "`n done monitoring `n"