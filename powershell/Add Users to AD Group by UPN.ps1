$users = "user.1@myflfamilies.com",
"user.2@myflfamilies.com"

$group = "GGZ_Group_Name"

foreach ($user in $users) {
    $userObj = Get-ADUser -Filter {UserPrincipalName -eq $user}
    if ($userObj) {
        Add-ADGroupMember -Identity $group -Members $userObj
    } else {
        Write-Warning "User with UPN $user not found."
    }
}
