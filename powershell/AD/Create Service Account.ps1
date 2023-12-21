# Create Service Account in AD and add it to a group

# Import the Active Directory module for the Get-ADUser cmdlet
# Import-Module ActiveDirectory

# Set the AD User Name
$Name = "svc_whatever"
$Password = "password here"
$Description = "description here"
$OU = "OU=OrganizationalUnit,DC=contoso,DC=com"

# Set the AD User Parameters
$splat = @{
    Name = $Name
    # 
    Path = $OU
    SamAccountName = $Name
    GivenName = $Name
    Surname = $Name
    DisplayName = $Name
    UserPrincipalName = "$($Name)@contoso.com"
    AccountPassword = (ConvertTo-SecureString -AsPlainText $Password -Force)
    Enabled = $true
    ChangePasswordAtLogon = $false
    PasswordNeverExpires = $true
    Description = $Description
    CannotChangePassword = $true
}

# Create the AD User
New-ADUser @splat

# Add the AD User to an AD Group
Add-ADGroupMember -Identity "group_name" -Members $Name

# Copy the username and password to the clipboard
"$Name`n$Password" | clip
