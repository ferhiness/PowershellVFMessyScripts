Connect-MsolService -MsGraphAccessToken

#get-Command -Module MSOnline -ShowCommandInfo |  Out-GridView

$User1 = Get-MsolUser -DomainName 'linkgroup.com' -SearchString 'Vanessa Fernandes'  | Select-Object UserPrincipalName, LastDirSyncTime, isLicensed
$User1.LastPasswordChangeTimestamp
$User1.Licenses
$User1.BlockCredential

$U2 = Get-MsolUser -DomainName 'linkgroup.com' -SearchString 'Jones'
$U2.Licenses

$UsersK =  Get-MsolUser -DomainName 'linkgroup.com' -SearchString 'Kanda'  | Select-Object UserPrincipalName, DisplayName ,LastDirSyncTime, isLicensed, BlockCredential 
Get-MsolUser -DomainName 'linkgroup.com' -SearchString 'piyal' | Select-Object UserPrincipalName, DisplayName ,LastDirSyncTime, isLicensed, BlockCredential 

