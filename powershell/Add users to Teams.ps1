# Bulk add users to a MS Team
# Connect to Teams
Connect-MicrosoftTeams

# Get the ID of the team
$team = Get-Team -DisplayName "Group_Name"

# Populate list of users to add to the team
$users = "name.1@email.com",
"name.2@email.com"

# Add members to the team
foreach ($user in $users) {
    Add-TeamUser -GroupId $team.GroupId -User $user -Role Member
}
