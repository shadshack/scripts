$user = "last-first"

while ($true){
    try {
        Get-ADUser $user
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
        Write-Host "User does not exist"
    }
    Start-Sleep 5
}
