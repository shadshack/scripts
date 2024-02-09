# This script just tests sending an email using the Microsoft Graph API PowerShell module.
# The script is designed to be run as an Azure Automation Runbook
# The runbook needs to have a System-Assigned Managed Identity with the following permissions assigned to it's associated Enterprise Application in Azure AD:
#   - Directory.Read.All
#   - Mail.ReadWrite
# The script uses the Microsoft Graph PowerShell modules to connect to Microsoft Graph and send an email

# Import the Graph Modules we need
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Mail
Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Users.Actions

# Connect to Microsoft Graph with System-Assigned Managed Identity
Connect-MgGraph -Identity

# Set the email sender account ID
$senderAddress = "sender@mdomain.com"
$senderID = Get-MgUser -Filter "mail eq '$($senderAddress)'" | Select-Object -ExpandProperty Id

# Set the recipient email address
$recipientAddress = "recipient@domain.com"

# Set email parameters
$subject = "Test Email - $(Get-Date -Format 'yyyy-MM-dd')"

$body = "<html><body>
<p>This is a test email.</p>
</body></html>"

$params = @{
  Message = @{
    Subject = $subject
    Importance = "High"
    Body = @{
      ContentType = "HTML"
      Content = $body
    }
    ToRecipients = @(
      @{
        EmailAddress = @{
          Address = $recipientAddress
        }
      }
    )
  }
  SaveToSentItems = "false"
}

# Send the email
Send-MgUserMail -UserId $senderID -BodyParameter $params
