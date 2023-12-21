# Gets a list of all folders in the H: drive and generates a CSV file for bulk migration to OneDrive via Sharepoint Migration Manager

# Step 1: Get folder names in file share
$folderPath = "\\fileserv\users"
$folderNames = Get-ChildItem -Path $folderPath -Directory | Select-Object -ExpandProperty Name

# Step 2: Lookup UPNs for SAMAccountNames
$upns = @()
foreach ($folderName in $folderNames) {
    $samAccountName = $folderName
    $user = Get-ADUser -Filter { SamAccountName -eq $samAccountName } -Properties UserPrincipalName
    $upns += $user.UserPrincipalName
}

# Step 3: Generate CSV with required columns
$csvData = @()
$i = 0
foreach ($folderName in $folderNames){
    $upnForFileName = $upns[$i] -replace '@', '_' -replace '\.', '_'
    $rowData = [PSCustomObject]@{
        FileSharePath = "\\hqfileserv\users\$($folderName)"
        Delete1 = ""
        Delete2 = ""
        SharePointSite = "https://fldcf-my.sharepoint.com/personal/$upnForFileName"
        DocLibrary = "Documents"
        DocSubFolder = "Home Folder"
    }
    $csvData += $rowData
    $i++
}

$csvData | Export-Csv -Path "H_Drive_Bulk_Migrate.csv" -NoTypeInformation
