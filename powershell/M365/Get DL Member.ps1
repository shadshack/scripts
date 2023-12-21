# Get all members of Distribution List
Connect-ExchangeOnline
$DLName = "DL-Name@domain.com"
$HQWMembers = Get-DistributionGroupMember -Identity $DLName -ResultSize Unlimited
$HQWMembers.Count
$HQWMembers | select-object Identity,PrimarySmtpAddress | Export-csv DLmembers.csv -NoTypeInformation
