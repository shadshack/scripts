# Script to install RSAT Tools on Windows 10 1809 and above

# Check if you're using a WU server
$UseWUServer = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -ErrorAction SilentlyContinue

# If you're using a WU server, disable it and restart the WU service. Doing this so that the RSAT tools are downloaded from Microsoft instead of your WU server, which may not have them.
if ($UseWUServer.UseWUServer -eq 1) {
    # Disable WU server
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0
    # Restart WU service
    Restart-Service -Name wuauserv
}

# Install the RSAT tools
Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online

# Re-enable WU server if it was enabled before
if ($UseWUServer.UseWUServer -eq 1) {
    # Enable WU server
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 1
    # Restart WU service
    Restart-Service -Name wuauserv
}
