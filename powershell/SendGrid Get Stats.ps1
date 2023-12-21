# Get daily SendGrid stats from the API and display them in the console

# Set Variables
$AccessToken = "###################################"
$today_date = Get-Date -Format "yyyy-MM-dd"
$start_Date = $today_date
$end_Date = $today_date

#Set API Call Data
$GraphEndpoint = "https://api.sendgrid.com/v3/stats?start_date=$start_Date&end_date=$end_Date&aggregated_by=day"
$Headers = @{
    Authorization = "Bearer $AccessToken"
}

while ($true) {
  # Make API Call
  $result = (Invoke-RestMethod -Method Get -Uri $GraphEndpoint -Headers $Headers).stats.metrics
  $result

  Write-Host "Success %:" $($result.delivered / $result.requests*100)"%"
  Write-Host "Failures Total #:" ($result.blocks + $result.blocks + $result.bounces)
  # Write-Host "Deferred:" $result.deferred
  Write-Host "Time ran:" (Get-Date -Format "HH:mm:ss")

  if ($lastRunRequest -eq $result.requests) {
    Write-Host "No update made"
  }
  else {
    Write-Host -foregroundcolor red "Updated data"
    
  }
  $lastRunRequest = $result.requests
  Start-Sleep 300
  clear
}
