# Prompt for network path
$networkPath = Read-Host "Enter network path"

# Get ACL for network path
$networkPathAcl = (Get-Acl $networkPath).Access | Format-Table
$networkPathAcl

# Prompt for AD group
$adGroup = Read-Host "Enter AD group from list above that you'd like to add the user to (not including 'AD\')"

# Prompt for username
$users = Read-Host "Enter username(s) to add to AD group. Separate multiple users with a comma (no spaces)"

# For each user entered, add to AD group
foreach ($user in $users.Split(",")){
  # See if user is already a member of AD group
  if ((Get-ADGroupMember -Identity $adGroup).SamAccountname -contains $user){
    Write-Host -ForegroundColor Green "$user already a member of AD group"
  } else {
    Write-Host -ForegroundColor Yellow "$user not in AD group. Adding user."
    
    # Add user to AD group
    Add-ADGroupMember -Identity $adGroup -Members $user
    
    # Validate user was added to AD group
    if ((Get-ADGroupMember -Identity $adGroup).SamAccountname -contains $user){
      Write-Host -ForegroundColor Green "$user was added to AD group successfully"
    } else {
      Write-Host -ForegroundColor Red "$user was not added to AD group"
    }
  }
}

# Summarize changes
Write-Host -ForegroundColor Green $users "added to AD group '$($adGroup)' for access to location '$($networkPath)'"
