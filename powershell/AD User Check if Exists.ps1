# Checks every 5 seconds if a user exists in AD. Useful for waiting for a new user to replicate to the DC you're working with.
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
