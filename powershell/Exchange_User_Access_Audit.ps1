# Audit all Shared Mailboxes and Distribution Groups that a user is an owner of
# Change the $user variable below to an email address before running
# This will take about 10-15 minutes to run, since it has to check all the SharedMailbox Permissions

# Set the user to audit
$user = "user@email.com"

# Connect to Exchange
Connect-ExchangeOnline

# Get User details
$userDisplayName = (Get-User $User).Name
$distinguishedName = (get-mailbox $user).DistinguishedName

################
# Mailboxes
################

# Get all SharedMailboxes (This will take a while, there are a lot...)
Write-Host "Getting all SharedMailboxes. This may take a while..." -ForegroundColor Yellow
$mailboxes = Get-Mailbox -ResultSize unlimited -RecipientTypeDetails SharedMailbox

# For each mailbox, get the permissions
$counter = 0
Clear-Variable mailboxesWithPermission 2>$null
# Get a baseline of how long one mailbox takes to check
$queryTimeEstimate = (Measure-Command {Get-MailboxPermission -identity $mailboxes[1] -User $user}).TotalSeconds
foreach ($mailbox in $mailboxes) {
  # Some code for a progress bar, since this takes a while...
  $counter++
  Write-Progress -Activity "Checking permissions for mailbox $counter of $($mailboxes.count)" -CurrentOperation $mailbox.Identity -PercentComplete (($counter / $mailboxes.count) * 100) -SecondsRemaining ($queryTimeEstimate * ($mailboxes.count - $counter))

  # Check the mailbox for the user's permissions
  $mailboxesWithPermission += Get-MailboxPermission -identity $mailbox -User $user | Select-Object Identity, AccessRights, Deny
}


####################
# Groups (DLs, etc)
####################

# Get all Groups (This will take a while, there are a lot...)
Write-Host "Getting all Groups the user is a member of." -ForegroundColor Yellow
$groups = Get-DistributionGroup -Filter "Members -like ""$distinguishedName""" -ResultSize unlimited | Select-Object Name, ManagedBy

# For each group, get the owners
Clear-Variable groupsWithPermission 2>$null
foreach ($group in $groups) {
  # Check the mailbox for the user's permissions
  if ($group.ManagedBy -like $userDisplayName) {
    $groupsWithPermission += $group
  }
}

# Output the results
Write-Host "Shared Mailboxes $user has permissions to:" -ForegroundColor Yellow
$mailboxesWithPermission | Format-Table -AutoSize
Write-Host ""

Write-Host "Groups $user is Owner of:" -ForegroundColor Yellow
$groupsWithPermission.Name | Format-Table -AutoSize
Write-Host ""
