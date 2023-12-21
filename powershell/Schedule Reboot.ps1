# Schedule a reboot at a specific time with a custom message.

# Prompt for reboot time in 24 hour format
$rebootTime = [datetime](Read-Host -Prompt "Enter reboot time in 24 hour format (HH:mm:ss)")

# Prompt for reboot message
$rebootMessage = Read-Host -Prompt "Enter reboot message"

# Get current time in 24 hour format
$now = Get-Date -Format HH:mm:ss

# Calculate seconds until reboot
$rebootSeconds = (New-TimeSpan -Start $now -End $rebootTime).TotalSeconds

# Schedule reboot
shutdown -r -t $rebootSeconds /c $rebootMessage
