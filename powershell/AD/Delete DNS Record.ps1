# Looks for a DNS record and deletes it

# Set Variables
$DC = "dc01"
$Zone = "domain.com"
$RecordName = "DNSRECORDNAME"

# Show record
$record = Get-DnsServerResourceRecord -Computer $DC -ZoneName $Zone -Name $RecordName
$record

# Delete the record
Remove-DnsServerResourceRecord -ComputerName $DC -ZoneName $Zone -Name $RecordName -RRType $record.RecordType
