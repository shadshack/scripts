# Script to copy Azure SQL Server Firewall rules from one server to another
# Useful if you're setting up a new server and need to copy a LOT of rules

# Login to Azure account (if not already logged in)
Connect-AzAccount -TenantId 11111111111111111111111 -Subscription 111111111111111111111

# Set the resource group and server names for the source and target Azure SQL servers
$sourceResourceGroupName = "Source_RG"
$sourceServerName = "source-sql-server"
$targetResourceGroupName = "Target_RG"
$targetServerName = "target-sql-server"

# Get the firewall rules from the source SQL server
$firewallRules = Get-AzSqlServerFirewallRule -ResourceGroupName $sourceResourceGroupName -ServerName $sourceServerName

# Loop through the firewall rules and add them to the target SQL server
foreach ($rule in $firewallRules) {
    $ruleName = $rule.FirewallRuleName
    $startIpAddress = $rule.StartIpAddress
    $endIpAddress = $rule.EndIpAddress

    # Create a new firewall rule on the target server
    New-AzSqlServerFirewallRule -ResourceGroupName $targetResourceGroupName -ServerName $targetServerName -FirewallRuleName $ruleName -StartIpAddress $startIpAddress -EndIpAddress $endIpAddress

    Write-Output "Firewall rule '$ruleName' copied to the target server."
}

Write-Output "Firewall rules copied successfully from the source server to the target server."
