# Connect to Teams
Connect-MicrosoftTeams

# Get the ID of the team
$team = Get-Team -DisplayName "Name.Team"

# Populate list of users to add to the team
$users = "user1@domain.com",
"user2@domain.com"

# Add members to the team
foreach ($user in $users) {
    # Try adding the user to the team, if there's an error, save the user to a list
    try {
        Add-TeamUser -GroupId $team.GroupId -User $user -Role Member
    }
    catch {
        $failedUsers += $user
    }
}

# If there are any failed users, list them
if ($failedUsers) {
    Write-Host "The following users could not be added to the team:"
    $failedUsers
}
