# Bulk install SNMP on remote servers and configure SNMP Traps

$SNMP_Community = "public"

# Start transcript
Start-Transcript -Path ".\SNMP_Install.log"

# Import list of servers from text file
$Servers = Get-Content ".\SNMP_Servers.txt"

# Loop through each server in the list and make sure it's reachable over PS Remoting
foreach ($Server in $Servers){
  $Session = New-PSSession -ComputerName $Server -ErrorAction SilentlyContinue
  if ($Session){
    Write-Host -ForegroundColor Green "Session to $Server successful. Starting Install."
    Invoke-Command -Session $Session -ScriptBlock {
      # Check for and install SNMP Service
      if ((Get-WindowsFeature SNMP-Service).InstallState -ne 'Installed'){
        Write-Host "Installing SNMP Service"
        Install-WindowsFeature SNMP-Service -IncludeManagementTools
      }
      else{
        Write-Host "SNMP Service Already Installed"
      }

      # Set up SNMP Traps via Registry keys
      New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\services\SNMP\Parameters\TrapConfiguration\$($SNMP_Community)" -Force
      New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities" -Force
      New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities" -Name $SNMP_Community -Value 4 -PropertyType DWord
     }
    Remove-PSSession $Session
  }
  else{
    Write-Host -ForegroundColor Red "Session to $Server failed"
  }
}

# Stop Transcript
Stop-Transcript
