# This script will compare all users with a G3 license to the HR email list and output a CSV of users that are not in the HR email list.
# Useful for finding users that have a license but are not in the HR email list, such as contractors.
# Also can filter out a list of service accounts that are in a specific group.

# Set variables
$HRData = "HR Reference Email List.csv"
$outputLocation = ".\Licensed Users not in HR List - With Details - $(Get-Date -Format yyyy-MM-dd).csv"
$serviceAccountGroupName = "group_name"

# Log in
Connect-MgGraph -Scopes "User.Read.All", "Group.ReadWrite.All", "Directory.Read.All", "AuditLog.Read.All"
# Import-Module AzureADPreview
# Connect-AzureAD

# Get all users with G3 license
$g3Sku = Get-MgSubscribedSku -All | Where-Object SkuPartNumber -eq 'ENTERPRISEPACK_GOV'
$LicensedUsers = $null
Write-Host "Getting all users with a license. This will take a few minutes..."
$LicensedUsers = Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq $($g3sku.SkuId) )" -ConsistencyLevel eventual -All -Select "DisplayName,UserPrincipalName,SigninActivity,AssignedLicenses,AccountEnabled,ObjectId,onPremisesDistinguishedName,onPremisesSamAccountName"
# $LicensedUsers | Select-Object DisplayName,UserPrincipalName,AccountEnabled,@{N="AADLastSignInDateTime";E={$_.SigninActivity.LastSignInDateTime}},@{N="AADLastNonInteractiveSignInDateTime";E={$_.SigninActivity.LastNonInteractiveSignInDateTime}},AssignedLicenses,Id,onPremisesDistinguishedName,onPremisesSamAccountName | Out-Gridview
Write-Host -ForegroundColor Yellow "Number of users with a license: " $LicensedUsers.Count

# Read in list of emails from HR
$HRUsers = (Import-Csv -Path $HRData).empl_email

# Compare lists
$comparison = @()
$comparison = Compare-Object -ReferenceObject $LicensedUsers.UserPrincipalName -DifferenceObject $HRUsers -IncludeEqual

# Make the SideIndicator column something that makes more sense
$comparison | ForEach-Object {
    if ($_.SideIndicator -eq "==") {
        $_ | Add-Member -MemberType NoteProperty -Name "Status" -Value "Match"
    }
    elseif ($_.SideIndicator -eq "=>") {
        $_ | Add-Member -MemberType NoteProperty -Name "Status" -Value "Not Licensed"
    }
    elseif ($_.SideIndicator -eq "<=") {
        $_ | Add-Member -MemberType NoteProperty -Name "Status" -Value "Not in HR Database"
    }
}

# Make a new array of just the users that are not in HR Database
$LicensedUsersNotInHRDatabase = $comparison | Where-Object Status -eq "Not in HR Database" | Select-Object -property InputObject
# $LicensedUsersNotInHRDatabase.Count

# Loop up members of the "Service Accounts" group
$serviceAccountGroupId = (Get-MgGroup -Filter "DisplayName eq '$($serviceAccountGroupName)'").Id
$serviceAccountIds = Get-MgGroupMember -GroupId $serviceAccountGroupId -All

# look up each user by Id and get UserPrincipalName
$serviceAccounts = @()
foreach ($id in $serviceAccountIds) {
    $serviceAccounts += (Get-MgUser -UserId $id.Id)
}

# Remove any users that are a part of the "Service Accounts" group
$LicensedUsersNotInHRDatabase = $LicensedUsersNotInHRDatabase | Where-Object { $_.InputObject -notin $serviceAccounts.UserPrincipalName }
Write-Host -ForegroundColor Yellow "Number of users with a license that don't exist in the HR Database `n(excluding service accounts in DCF-O365-G3-Licensing_ServiceAccounts): " $LicensedUsersNotInHRDatabase.Count
# $LicensedUsersNotInHRDatabase | Out-GridView

# Make a new array of data from $LicensedUsers but only if the user's email matches one in $LicensedUsersNotInHRDatabase
$LicensedUsersNotInHRDatabaseDetails = $LicensedUsers | Where-Object { $_.UserPrincipalName -in $LicensedUsersNotInHRDatabase.InputObject }

# Go through each user and look them up in on-prem AD to make sure they exist and get the LastLogonDate if they do
foreach ($user in $LicensedUsersNotInHRDatabaseDetails) {
    # Reset variables
    $onPremUser = $null
    $existsOnPrem = $null
    $onPremLogonDate = $null
    $description = $null

    # Look up the user in on-prem AD
    $onPremUser = Get-ADUser -Identity $user.onPremisesSamAccountName -Properties LastLogonDate, Description -ErrorAction SilentlyContinue

    # If the user exists in on-prem AD, get the LastLogonDate
    if ($onPremUser) {
        $onPremLogonDate = $onPremUser.LastLogonDate
        $description = $onPremUser.Description
        $existsOnPrem = $true
    }
    # If the user doesn't exist in on-prem AD
    else {
        $existsOnPrem = $false
    }

    # $onPremLogonDate = (Get-ADUser -Identity $user.onPremisesSamAccountName -Properties LastLogonDate).LastLogonDate


    $user | Add-Member -MemberType NoteProperty -Name "OnPremLastLogonDate" -Value $onPremLogonDate -Force
    $user | Add-Member -MemberType NoteProperty -Name "Description" -Value $description -Force
    $user | Add-Member -MemberType NoteProperty -Name "ExistsOnPrem" -Value $existsOnPrem -Force
}

# Save the results to a CSV
$LicensedUsersNotInHRDatabaseDetails | Select-Object DisplayName,UserPrincipalName,onPremisesSamAccountName,AccountEnabled,ExistsOnPrem,OnPremLastLogonDate,@{N="AADLastLogonDateTime";E={$_.SigninActivity.LastSignInDateTime}},@{N="AADLastNonInteractiveLogonDateTime";E={$_.SigninActivity.LastNonInteractiveSignInDateTime}},onPremisesDistinguishedName,Description,AssignedLicenses,Id | Export-Csv -Path $outputLocation -NoTypeInformation

# Remove license and disable any users where ExistsOnPrem is False
# Write-Host -ForegroundColor Yellow About to disable ($LicensedUsersNotInHRDatabaseDetails | Where-Object ExistsOnPrem -eq $false).count Users
# $LicensedUsersNotInHRDatabaseDetails | Where-Object ExistsOnPrem -eq $false | ForEach-Object {
#     $user = $_
#     # Remove the license
#     Set-MgUserLicense -UserId $user.Id -AddLicenses @() -RemoveLicenses @($g3sku.SkuId)

#     # Disable the user
#     Update-MgUser -UserId $user.Id -AccountEnabled:$false
# }
