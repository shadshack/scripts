##################################################################
# Get all users in a tenant from Microsoft Graph using Powershell
# Authenticate Graph Powershell module using a client ID / secret
# https://learn.microsoft.com/en-us/powershell/microsoftgraph/authentication-commands?view=graph-powershell-1.0
##################################################################

# Install Microsoft Graph Powershell module. Needs relatively new version of module to support client secret authentication. Tested with 2.6.1.
# https://docs.microsoft.com/en-us/graph/powershell/installation
Install-Module -Name Microsoft.Graph -MinimumVersion 2.6.1

# Set Variables
$TenantId = "tenantid"
$ClientId = "clientid"
$ClientSecret = "clientsecret"

# Convert client secret to secure string
$ClientSecret = ConvertTo-SecureString -String $ClientSecret -AsPlainText -Force

# Convert client ID and secret to secure credentials
[pscredential]$ClientSecretCredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $ClientId, $ClientSecret

# Log in to Microsoft Graph
Connect-MgGraph -TenantId $TenantId -ClientSecretCredential $ClientSecretCredential

# Get all users in the tenant and some extra properties
$users = Get-MgUser -All -Property GivenName, Surname, SignInActivity, Id, identities

# Show how many users were returned
Write-Host "Total count of users returned:" $users.count

# Set file name with today's date
$filename = "users_" + (Get-Date -Format "yyyy-MM-dd") + ".csv"

# Export to a CSV
$users | Select-Object GivenName, Surname, @{N="email";E={($_.identities | Where-Object SignInType -eq "emailAddress").IssuerAssignedId}}, Id, @{N="LastSignInDateTime";E={$_.SignInActivity.LastSignInDateTime}} | Export-Csv -Path $filename -NoTypeInformation
