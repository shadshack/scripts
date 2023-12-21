# This script will look up a user in B2C and return their MFA status if the account exists

# Set your variables for authentication and mailbox access
$TenantID = "#######################"
$ClientID = "#########################"
$ClientSecret = "secret"
$GraphScope = "https://graph.microsoft.com/.default"

# Prompt for the user's email address
$userEmailAddress = Read-Host -Prompt "Enter the user's email address"

#####################################
# Need to get an AccessToken First
#####################################
# Get an access token for the Microsoft Graph API using the provided credentials
$TokenEndpoint = "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token"
$Body = @{
    Grant_Type    = "client_credentials"
    Scope         = $GraphScope
    Client_Id     = $ClientID
    Client_Secret = $ClientSecret
}
$response = $null
$response = Invoke-RestMethod -Method Post -Uri $TokenEndpoint -Body $Body
$AccessToken = $Response.access_token

#####################################
# Get User ID From Email Address
#####################################
$filter = "(identities/any(i:i/issuer eq 'fldcfb2cprod.onmicrosoft.com' and i/issuerAssignedId eq '$($userEmailAddress)'))"
$GraphEndpoint = "https://graph.microsoft.com/beta/users/?filter=$filter"
$Headers = @{
    Authorization = "Bearer $AccessToken"
}
$response = $null
$response = Invoke-RestMethod -Method Get -Uri $GraphEndpoint -Headers $Headers
$userObjectID = $null
$userObjectID = $response.value.id

# If the user exists, continue. If not, exit the script
if ($null -eq $userObjectID) {
    Write-Host -Foregroundcolor Red "User $userEmailAddress not found."
    exit
}

#####################################
# Get User Details by ID
#####################################
# Call the Microsoft Graph API for the user's details
$GraphEndpoint = "https://graph.microsoft.com/beta/users/$($userObjectID)"

$Headers = @{
    Authorization = "Bearer $AccessToken"
}
$response = $null
$response = Invoke-RestMethod -Method Get -Uri $GraphEndpoint -Headers $Headers

# Check if the user has MFA options
$MFAOptions = $null
$MFAOptions = ($response | Select-Object extension_*_MFAOptions)

$MFAValueName = $null
$MFAValueName = $MFAOptions | ForEach-Object {$_.psobject.properties.name}

# Write output of user status
if ($response.$MFAValueName){
  Write-Host -ForegroundColor Green "User $userEmailAddress exists with MFA options:" $response.$MFAValueName
}
else {
  Write-Host -ForegroundColor Yellow "User $userEmailAddress exists with no MFA options. Account creation may have been aborted, user will be prompted to enroll in MFA on next login."
}
