# Script to test SMTP relay

# Edit these to change the sender and recipient addresses
$senderAddress = "noreply@email.com"
$recipientAddress = "yourname@email.com"

$smtpServer = "smtp.relay.domain.com"
$smtpPort = 25

# Test connection to the server on port 25
if ((Test-NetConnection -ComputerName $smtpServer -Port $smtpPort).TcpTestSucceeded){
  Write-Host -ForegroundColor Green "TCP Connect on port 25 succeeded. Attempting to send mail message."
  Write-Host -ForegroundColor Green "If the mail still does not arrive, check the SMTP relay for whitelisting of the sending server IP."
  Send-MailMessage -To $recipientAddress `
  -From $senderAddress `
  -Subject "Test mail $(Get-Date -Format 'HH:mm MM/dd/yyyy')" `
  -SmtpServer smtpout.dcf.state.fl.us `
  -Port 25 `
  -Body 'This is a test email'
}
else{
  Write-Host -ForegroundColor Red "TCP Connect on port 25 failed. Check network connectivity."
}
