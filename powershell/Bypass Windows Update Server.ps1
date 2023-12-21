# Bypass using a WSUS server which is defined by GPO.  This is useful for testing Windows Updates from the internet or if WSUS is down.

# Set reg key to not use WUServer
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0 -Force

# Restart Windows Update Service
Restart-Service -Name wuauserv
