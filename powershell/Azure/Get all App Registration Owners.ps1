# This script will get a list of unique owners of all App Registrations in your tenant
# Useful to go grant the "Directory Readers" role to these users so they can see the App Registrations in the Azure Portal and be able to manage them

# Import Modules
Import-Module Microsoft.Graph.Applications
Import-Module Microsoft.Graph.Authentication

# Connect to Graph
Connect-MgGraph

# Get all applications
$allApps = Get-MgApplication -All:$true

# Get the owners of all the apps into an array
$owners = $allApps | ForEach-Object { Get-MgApplicationOwner -All -ApplicationId $_.Id }
$ownerEmails = $owners.AdditionalProperties.userPrincipalName | Select-Object -Unique

$ownerEmails.Count
