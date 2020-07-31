$resourcegroupname = 'rg-vf-Training'
$location = 'Australia East'
$servername = 'svr-vf-training'
$svruser = "vfsvruser" #vfsvradmin
$svrpass = 'KdiP2goDBA8rRZVF'
$serverURL = $servername + '.database.windows.net'
$databasename = 'db-sql-vf-TestAudit1' 
$ADSecurityGroup = 'Azure AD Security Group'
$AllowedIPs = "139.130.2.94"


$SubscriptionID = "5ca504d8-b0fe-4e27-aab1-6aaf37020e60"
Login-AzureRmAccount -Subscription "Sandbox" 
$Sub = Get-AzureRmSubscription -SubscriptionId $SubscriptionID -ErrorAction SilentlyContinue

#$RG =  Get-AzureRmResourceGroup -Name $resourcegroupname 
 
$ResourceList = Get-AzureRmResource -ResourceGroupName $resourcegroupname

$SQlServer =  Get-AzureRmSqlServer -ServerName $servername -ResourceGroupName $resourcegroupname -ErrorAction SilentlyContinue -ErrorVariable DBGetError
if(!$SQlServer) {$SQlServer = New-AzureRmSqlServer -ServerName $servername -ResourceGroupName $resourcegroupname -Location $location }

$database = Get-AzureRmSqlDatabase -ResourceGroupName $resourcegroupname -ServerName $servername -DatabaseName $databasename -ErrorAction SilentlyContinue -ErrorVariable GetDBError
$GetDBError
if(!$database){ $database = New-AzureRmSqlDatabase -ResourceGroupName $resourcegroupname ` -ServerName $servername ` -DatabaseName $databasename -RequestedServiceObjectiveName "S0" -AsJob }

$database
#Create Audit on front end & then get the details here just to see..  later we can replicate the create with Powershell

#Remove-AzureRmSqlDatabase 
$startip = "175.45.116.0"
$endip = "175.45.116.99"
$FirewallRule = New-AzureRmSqlServerFirewallRule -ResourceGroupName rg-vf-Training -ServerName $servername -FirewallRuleName 'IPsToAllowforServer' -StartIpAddress $startip -EndIpAddress $endip 

$FirewallRule = Get-AzureRmFirewall -ResourceGroupName 'rg-vf-Training' 

#Remove-AzureRmFirewall -ResourceGroupName 'rg-vf-Training'  -Name 'IPsToAllow' -Force
#$startipRange = "139.130.2.0"
#$endipRange = "139.130.2.255"

#$FirewallRule = New-AzureRmSqlServerFirewallRule -ResourceGroupName $resourcegroupname `
#    -ServerName $servername `
#    -FirewallRuleName "AllowedIPs" -StartIpAddress $startipRange -EndIpAddress $endipRange

$storageAccountName = "savftrainingaudit"
$storageAccountName.Length
$storageAccount = Get-AzureRmStorageAccount   -Name $storageAccountName -ResourceGroupName $resourcegroupname -ErrorAction SilentlyContinue -ErrorVariable getSAErrorMesage
#Get-AzureRmStorageAccount : 'accountName' exceeds maximum length of '24'
if(!$storageAccount) {$storageAccount = New-AzureRmStorageAccount -ResourceGroupName $resourcegroupname -Name $storageAccountName -Type "Standard_LRS" -Location $location}

$SaKey = Get-AzureRmStorageAccountKey -ResourceGroupName $resourcegroupname -Name $storageAccountName


