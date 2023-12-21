# Azure Function App code to send email notifications when B2C App Registration secrets are about to expire
# Connects from the Function App to the B2C Tenant using the Client ID and Secret stored in the Function App's Application Settings

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
# Import-Module AzureAD -UseWindowsPowershell #-SkipEditionCheck
# Import-Module Az.Resources -UseWindowsPowershell

# Import Modules
Import-Module Microsoft.Graph.Authentication #-UseWindowsPowershell #-SkipEditionCheck
Import-Module Microsoft.Graph.Applications #-UseWindowsPowershell
Import-Module Az.Accounts -UseWindowsPowershell #-SkipEditionCheck

# Set variables from Function's Application Settings
$B2Cenv = "Prod"
$clientID = $ENV:B2C_Prod_ClientID
$secret = ConvertTo-SecureString $ENV:B2C_Prod_Secret -AsPlainText -Force
$tenant = $ENV:B2C_Prod_TenantID
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
Write-Host ClientID : $clientID
Write-Host secret : $secret
Write-Host TenantID : $tenant


# Log in with client ID and secret
Write-Host "Logging into B2C identity"
$psCred = New-Object System.Management.Automation.PSCredential($clientID , $secret)
Connect-MgGraph -TenantId $tenant -ClientSecretCredential $psCred

# Get all apps (for testing)
# Get-MgApplication -All:$true

function Send-ExpirationNotification($email, $app, $endDate) {
    $subject = "Secret Expiration Notification for B2C $B2Cenv App: $app"
    $body = @"
Dear $($email.Split('@')[0]),<br />
<br />
This is a friendly reminder that the secret for the application '$app' is going to expire on $($endDate.ToShortDateString()) in the B2C $($B2Cenv) Tenant.<br />
You are receiving this notification because you are listed as an owner of this application.<br />
<br />
To renew the secret, please follow the steps below: <br />
<ol>
<li>Log in to the $($B2Cenv) B2C Tenant in the Azure portal</li>
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

# Get all applications
$allApps = Get-MgApplication -All:$true

# Get all secrets that are going to expire in the next $DaysNotice days
$SecretsToExpire = @()
$SecretsToExpire = foreach ($app in $allApps) {
  @(
    $app.PasswordCredentials
    $app.KeyCredentials
  ) | Where-Object {
    $_.EndDateTime -lt (Get-Date).AddDays($DaysNotice)
  } | ForEach-Object {
    $id = "Not set"
    if ($_.CustomKeyIdentifier) {
      $id = [System.Text.Encoding]::UTF8.GetString($_.CustomKeyIdentifier)
    }
    [PSCustomObject] @{
      App = $app.DisplayName
      ObjectID = $app.Id
      AppId = $app.AppId
      Type = $_.GetType().name
      KeyIdentifier = $id
      EndDate = $_.EndDateTime
    }
  }
}

# Printing the list of secrets that are near to expire
if ($SecretsToExpire.Count -eq 0) {
    Write-Output "No secrets found that will expire in this range"
} else {
    Write-Output "Secrets that will expire in this range: $SecretsToExpire.Count"
    Write-Output $SecretsToExpire
    # Sending email notifications to the fallback owner (B2C Owners doesn't like to play nice, also Cloud Services should just get them all)
    foreach ($secret in $SecretsToExpire) {
            Write-Host Emailing $Fallbackowner about $secret.App
            Send-ExpirationNotification -email $Fallbackowner -app $secret.App -endDate $secret.EndDate
    }
}
