# Commands to stop and disable DC services. Can be used to shut down services on a DC to test outages before decommissioning.

# Stop Services
Set-Service -Name "DNS" -Status stopped
Set-Service -Name "NtFrs" -Status stopped
Set-Service -Name "kdc" -Status stopped
Set-Service -Name "IsmServ" -Status stopped
Set-Service -Name "ADWS" -Status stopped
Set-Service -Name "NTDS" -Status stopped

# Re-Enable Services
Set-Service -Name "DNS" -Status running -StartupType Automatic
Set-Service -Name "NtFrs" -Status running -StartupType Automatic
Set-Service -Name "kdc" -Status running -StartupType Automatic
Set-Service -Name "IsmServ" -Status running -StartupType Automatic
Set-Service -Name "ADWS" -Status running -StartupType Automatic
Set-Service -Name "NTDS" -Status running -StartupType Automatic
