
$Cred = Get-Credential -UserName SQLAdmin -Message "Enter Password for SQLAdmin"

ConvertFrom-SecureString  $Cred.Password

$Cred.GetNetworkCredential() | fl *
$txt = [PSCredential]::new("X", $Password).GetNetworkCredential().Password
$txt


Invoke-DbaQuery -SqlInstance au-e-sqlmi-dev.fd1171b98898.database.windows.net -Database Config -Query "SELECT GETDATE()" -SqlCredential $Cred 


Connect-MsolService 

New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://ps.outlook.com/mail/" 


$Loc='australiaeast'
$SandboxSubId = '5ca504d8-b0fe-4e27-aab1-6aaf37020e60'
$NonProdSubId = '3c35bad4-fd51-4dea-89bc-30ac8ca1057f'
$rgName = 'auedvzodsrsg002'

Connect-AzAccount -ServicePrincipal

#$CurrentContext = Get-AzSubscription -SubscriptionId $SandboxSubId | Set-AzContext 
$CurrentContext = Get-AzSubscription -SubscriptionId $NonProdSubId | Set-AzContext 

$AzAA =   New-AzAutomationAccount -ResourceGroupName rg-vf-Training -Name testazaccount1 -Location 'Australia East'

Get-AzContext