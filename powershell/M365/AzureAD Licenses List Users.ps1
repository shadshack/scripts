# Gets all users with a specific license and outputs to a CSV

$SKU = "POWERBI_PRO_GOV"

# Script gets all the PowerBI Pro licensed users
Connect-MgGraph -Scopes "User.Read.All", "Group.ReadWrite.All", "Directory.Read.All"

# Get all users with G3 license
$Sku = Get-MgSubscribedSku -All | Where-Object SkuPartNumber -eq $SKU
$LicensedUsers = $null
$LicensedUsers = Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq $($sku.SkuId) )" -ConsistencyLevel eventual -All

# Write to a CSV
$LicensedUsers | Select-Object DisplayName, UserPrincipalName | Export-Csv -Path ".\PowerBIProUsers_$(Get-Date -Format 'dd-MM-yyyy').csv" -NoTypeInformation
