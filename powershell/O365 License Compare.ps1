# Compares the users in an AD group to the users with a specific license

$groupID = "00000000-0000-0000-0000-000000000000"
$licenseSKU = "ENTERPRISEPACK_GOV"

# Log in
Connect-MgGraph -Scopes "User.Read.All", "Group.ReadWrite.All", "Directory.Read.All"
Import-Module AzureAD
Connect-AzureAD

# Get all users with G3 license
$g3Sku = Get-MgSubscribedSku -All | Where-Object SkuPartNumber -eq $licenseSKU
$LicensedUsers = $null
$LicensedUsers = Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq $($g3sku.SkuId) )" -ConsistencyLevel eventual -All

# Get all users in the AD group
$adGroupMembers = $null
$adGroupMembers = Get-MgGroupMember -All -GroupID $groupID | Select-Object -ExpandProperty AdditionalProperties



# Compare the two lists
$Comparison = $null
$Comparison = Compare-Object -ReferenceObject $LicensedUsers.UserPrincipalName -DifferenceObject $adGroupMembers.userPrincipalName -IncludeEqual

# Change the side indicator to something more meaningful
$Comparison | ForEach-Object {
    if ($_.SideIndicator -eq "==") {
        $_.SideIndicator = "Both"
    }
    elseif ($_.SideIndicator -eq "=>") {
        $_.SideIndicator = "AD Group Only"
    }
    elseif ($_.SideIndicator -eq "<=") {
        $_.SideIndicator = "Licensed Users Only"
    }
}

# Output Counts
Write-Host "Total Licensed Users: $($LicensedUsers.Count)"
Write-Host "Total AD Group Members: $($adGroupMembers.Count)"

# Output how many users are in each category
$Comparison | Group-Object -Property SideIndicator | Select-Object Name, Count

# Output to gridview
$Comparison | Out-GridView

# Output to CSV
$Comparison | Export-Csv -Path ".\LicenseCompare.csv" -NoTypeInformation
