# Azure Function App code to send email notifications when App Registration secrets are about to expire
# Needs to be run from a Function App within the same tenant as the App Registrations and which has the appropriate permissions to read the App Registrations

# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format.
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"

# Import AzureAD Module
Import-Module AzureAD -UseWindowsPowershell #-SkipEditionCheck
Import-Module Az.Accounts -UseWindowsPowershell #-SkipEditionCheck
# Import-Module Az.Resources -UseWindowsPowershell

# Login to System-assigned Managed Identity
Write-Output "Using system-assigned managed identity"    
try {
  Connect-AzAccount -Identity -ErrorAction stop -WarningAction SilentlyContinue | Out-Null
  } catch {
    Write-Output "There is no system-assigned user identity. Aborting.";
     exit
    }

# Set variables from Function's Application Settings
$DaysNotice = $ENV:DaysNotice
$SenderAddress = $ENV:SenderAddress
$FallbackOwner = $ENV:FallbackOwner
$smtpServer = $ENV:smtpServer
$smtpPort = $ENV:smtpPort

# Write variables to log for troubleshooting
Write-Host DaysNotice : $DaysNotice
Write-Host SenderAddress : $SenderAddress
Write-Host FallbackOwner : $FallbackOwner
Write-Host smtpServer : $smtpServer
Write-Host smtpPort : $smtpPort

# Connect to AzureAD Powershell Module
$context = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile.DefaultContext
$aadToken = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate($context.Account, $context.Environment, $context.Tenant.Id.ToString(), $null, [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Never, $null, "https://graph.windows.net").AccessToken
Connect-AzureAD -AadAccessToken $aadToken -AccountId $context.Account.Id -TenantId $context.tenant.id

# List all AD Applications for Testing
# Get-AzureADApplication

function Send-ExpirationNotification($email, $app, $endDate) {
    $subject = "Secret Expiration Notification for App: $app"
    $body = @"
Dear $($email.Split('@')[0]),<br />
<br />
This is a friendly reminder that the secret for the application '$app' is going to expire on $($endDate.ToShortDateString()).<br />
You are receiving this notification because you are listed as an owner of this application.<br />
<br />
To renew the secret, please follow the steps below: <br />
<ol>
<li>Go to the <a href="https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/$($secret.AppId)/isMSAApp~/false">Azure Portal Certificates & Secrets page</a></li>
<li>Create a new secret / certificate in the appropriate tab</li>
<li>Integrate the new secret / certificate in your application</li>
<li>Validate that the application is working as expected with the new secret / certificate</li>
<li>Delete the old secret / certificate from the website in step 1 to stop these email alerts from triggering</li>
</ol>
Please renew the secret before the expiration date to avoid any disruptions in your application. Please feel free to enter a ticket to the Cloud Services team if you have any questions or need assistance.<br />
<br />
Thank you.
"@
    Send-MailMessage -From $SenderAddress -To $email -Subject $subject -Body $body -BodyAsHtml -SmtpServer $smtpServer -Port $smtpPort
}

# Retrieving the list of secrets that expires in the above days
$SecretsToExpire = Get-AzureADApplication -All:$true | ForEach-Object {
    $app = $_
    $owners = Get-AzureADApplicationOwner -ObjectId $app.ObjectId | Select-Object -ExpandProperty UserPrincipalName -ErrorAction SilentlyContinue
    @(
        Get-AzureADApplicationPasswordCredential -ObjectId $app.ObjectId
        Get-AzureADApplicationKeyCredential -ObjectId $app.ObjectId
    ) | Where-Object {
        $_.EndDate -lt (Get-Date).AddDays($DaysNotice)
    } | ForEach-Object {
        $id = "Not set"
        if ($_.CustomKeyIdentifier) {
            $id = [System.Text.Encoding]::UTF8.GetString($_.CustomKeyIdentifier)
        }
        [PSCustomObject] @{
            App = $app.DisplayName
            ObjectID = $app.ObjectId
            AppId = $app.AppId
            Type = $_.GetType().name
            KeyIdentifier = $id
            EndDate = $_.EndDate
            Owners = $owners
        }
    }
}

# Gridview list - if running locally see the list more cleanly
# $SecretsToExpire | Out-GridView

# Printing the list of secrets that are near to expire
if ($SecretsToExpire.Count -eq 0) {
    Write-Output "No secrets found that will expire in this range"
} else {
    Write-Output "Secrets that will expire in this range: $SecretsToExpire.Count"
    Write-Output $SecretsToExpire
    # Sending email notifications to the owners
    foreach ($secret in $SecretsToExpire) {
        if ($Secret.Owners -eq $null)
            {
                Write-Host $Secret.App Has no Owner. Setting to $FallbackOwner
                $Secret.Owners = $FallbackOwner
            }
        foreach ($owner in $secret.Owners) {
            Write-Host Emailing $owner about $secret.App
            Send-ExpirationNotification -email $owner -app $secret.App -endDate $secret.EndDate
        }
    }
}
