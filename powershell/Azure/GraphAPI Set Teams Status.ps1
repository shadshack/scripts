# Commands to get and set Teams Presence using Graph API

# Set user email address
$email = "email@domain.com"

# Connect to Graph Powershell
Connect-MgGraph -Scopes "Presence.ReadWrite"
$GraphClientId = $(Get-MgContext).ClientId

# Get user id
$userId = (Get-MgUser -Filter "mail eq '$email'").id

# Get Current Presence
Get-MgUserPresence -UserId $userId

# Set Available
Set-MgUserPresence -UserId $userId -SessionId $GraphClientId -Availability Available -Activity "Available" -ExpirationDuration 4:00:00

# Set Busy
# Set-MgUserPresence -UserId $userId -SessionId $GraphClientId -Availability Busy -Activity "InACall"

# Set Away
# Set-MgUserPresence -UserId $userId -SessionId $GraphClientId -Availability Away -Activity "Away"

# Clear Presence
# Clear-MgUserPresence -UserId $userId -SessionId $GraphClientId
