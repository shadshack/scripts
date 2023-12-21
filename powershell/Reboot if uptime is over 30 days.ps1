# Schedules a reboot with warning messages if the system uptime is over 30 days.
# Run as a scheduiled task on a monthly basis.

# Get the system uptime
$uptime = (Get-Date) - (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime

# Check if uptime is greater than 30 days
if ($uptime.Days -gt 30) {
    Write-Host "System uptime is $($uptime.Days) days."
    Write-Host "Scheduling a reboot..."

    # Schedule a reboot
    shutdown /r /t 2700 /d p:4:1 /c "This computer is scheduled to reboot in 45 minutes. Please save your work."
    msg.exe * /TIME:900 Warning: Your computer will reboot in 45 minutes. Save your work now.
    Start-Sleep -Seconds 900
    msg.exe * /TIME:900 Warning: Your computer will reboot in 30 minutes. Save your work now.
    Start-Sleep -Seconds 900
    msg.exe * /TIME:900 Warning: Your computer will reboot in 15 minutes. Save your work now.
}
else {
    Write-Host "System uptime is less than or equal to 30 days. No reboot needed."
}
