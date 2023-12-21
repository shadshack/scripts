# Script to add Send As and Full Access permissions for a group of users to a group of mailboxes

# Connect to Exchange Online
Connect-ExchangeOnline

# Set variables
$users = "user1@domain.com",
"user2@domain.com"

$mailboxes = "sharedmail1box1@domain.com",
"sharedmail1box2@domain.com"

# Loop through each mailbox and add the users to the mailbox
foreach ($mailbox in $mailboxes) {
    foreach ($user in $users) {
        Add-MailboxPermission -Identity $mailbox -User $user -AccessRights FullAccess -Confirm:$false
        Add-RecipientPermission -Identity $mailbox -Trustee $user -AccessRights SendAs -Confirm:$false
    }
}

# Output summary
Write-Host -ForegroundColor Yellow "Added Send As and Full Access permissions for the following users to the following mailboxes. Changes may take up to an hour to take effect. The mailbox will automatically show up in Outlook, but if it does not a reboot of Outlook or their computers may be required.`n"
Write-Host -ForegroundColor Yellow "Users:`n$($users -join "`n")`n"
Write-Host -ForegroundColor Yellow "Mailboxes:`n$($mailboxes -join "`n")"
