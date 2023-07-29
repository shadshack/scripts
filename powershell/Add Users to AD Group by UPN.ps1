$users = "user.1@email.com",
"user.2@email.com"

$group = "Group_Name"

foreach ($user in $users) {
    $userObj = Get-ADUser -Filter {UserPrincipalName -eq $user}
    if ($userObj) {
        Add-ADGroupMember -Identity $group -Members $userObj
    } else {
        Write-Warning "User with UPN $user not found."
    }
}
