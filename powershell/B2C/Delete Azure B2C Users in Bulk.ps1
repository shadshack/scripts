# Install the module if you don't have it already
# Install-Module -Name Microsoft.Graph -MinimumVersion 2.6.1

# Set the list of users to delete
$deleteEmails = "user1@domain.com", "user2@domain.com", "user3@domain.com"

# Connect to Azure AD (you will be prompted to login)
$tenantId = "################################"
Connect-MgGraph -TenantId $TenantId -Scopes "User.ReadWrite.All"

# Get all users in the tenant and some extra properties
$users = @()
$users = Get-MgUser -All -Property GivenName, Surname, Id, identities

# Show how many users were returned
Write-Host "Total count of users returned:" $users.count

# Iterate through the list of users and delete them
foreach ($deleteEmail in $deleteEmails) {
    $userToDelete = $null
    $userToDelete = ($users | Where-Object {($_.identities | Where-Object SignInType -eq "emailAddress").IssuerAssignedId -eq $deleteEmail}).Id

    Write-Host "Deleting user:" $deleteEmail
    Remove-MgUser -UserId $userToDelete -Confirm:$false
}
