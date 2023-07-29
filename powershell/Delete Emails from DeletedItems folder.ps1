# This script can be used to delete items from the Deleted Items folder in a mailbox using the Microsoft Graph API

# Set your variables for authentication and mailbox access
$TenantID = "..."
$ClientID = "..."
$ClientSecret = "..."
$EmailAddress = "user@email.com"
$GraphScope = "https://graph.microsoft.com/.default"

# Loop until the user presses CTRL+C
# Can only get 1000 emails at a time, so this will need to run for a while
while ($true) {
  #####################################
  #### Need to get an AccessToken First
  #####################################
  # Get an access token for the Microsoft Graph API using the provided credentials
  $TokenEndpoint = "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token"
  $Body = @{
      Grant_Type    = "client_credentials"
      Scope         = $GraphScope
      Client_Id     = $ClientID
      Client_Secret = $ClientSecret
  }
  $Response = Invoke-RestMethod -Method Post -Uri $TokenEndpoint -Body $Body
  $AccessToken = $Response.access_token


  #####################################
  # Check the mailbox and get the messages in the Deleted Items folder
  #####################################
  # Call the Microsoft Graph API to get the Inbox messages for the specified email address
  $GraphEndpoint = "https://graph.microsoft.com/v1.0/users/$EmailAddress/mailFolders/DeletedItems/messages"
  $Headers = @{
      Authorization = "Bearer $AccessToken"
  }
  $Body = @{
      top = 1000
  }
  $InboxMessages = $null
  $InboxMessages = Invoke-RestMethod -Method Get -Uri $GraphEndpoint -Headers $Headers -Body $Body

  # Output messages
  Write-Host -ForegroundColor Green Messages retrieved: $InboxMessages.Value.Count
  # The below line can show the subjects and sender addresses of the messages
  # $InboxMessages.Value | Select-Object Subject,@{N="SenderAddress";E={$_.from.emailAddress.Address}},receivedDateTime, Id | Format-Table

  #####################################
  # Delete the messages
  #####################################
  # Call the Microsoft Graph API to delete the messages
  $GraphEndpoint = "https://graph.microsoft.com/v1.0/users/$EmailAddress/mailFolders/DeletedItems/messages"

  # Loop through the messages and delete them
  if ($InboxMessages.Value.Count -eq 0) {
      Write-Host -ForegroundColor Green No messages to delete
  }
  else {
    $TotalMessages = $InboxMessages.Value.Count
    $DeletedMessages = 0
    foreach ($Message in $InboxMessages.Value) {
        $MessageID = $Message.Id
        $DeleteEndpoint = "$GraphEndpoint/$MessageID"
        $DeleteResponse = Invoke-RestMethod -Method Delete -Uri $DeleteEndpoint -Headers $Headers
        $DeletedMessages++
        Write-Progress -Activity "Deleting Messages" -Status "Deleting message $DeletedMessages of $TotalMessages - Current Message ID: $MessageID" -PercentComplete (($DeletedMessages / $TotalMessages) * 100)
    }
    # Remove the progress bar after completion
    Write-Progress -Activity "Deleting Messages" -Completed
  }
}
