Invoke-RestMethod -Uri http://ipinfo.io


$resourcegroupname = "rg-vf-training"
$location = "AustraliaEast"
$servername = "svr-vf-training"
$serverURL = $servername + '.database.windows.net'

$ADSecurityGroup = "Azure AD Security Group"
$AllowedIPs = "139.130.2.94"



$SubscriptionID = "5ca504d8-b0fe-4e27-aab1-6aaf37020e60"
Login-AzureRmAccount -Subscription "Sandbox" 
$RG = Get-AzureRmSubscription -SubscriptionId $SubscriptionID -ErrorAction SilentlyContinue

$SQlServer =  Get-AzureRmSqlServer -ServerName $serverURL -ResourceGroupName $resourcegroupname -ErrorAction SilentlyContinue

$startipRange = "139.130.2.0"
$endipRange = "139.130.2.255"

$FirewallRule = New-AzureRmSqlServerFirewallRule -ResourceGroupName $resourcegroupname `
    -ServerName $servername `
    -FirewallRuleName "AllowedIPs" -StartIpAddress $startipRange -EndIpAddress $endipRange

$mySecondDBName = "db-vf-TrainingDBADW2"
$database = New-AzureRmSQLDatabase -ResourceGroupName $resourcegroupname -Servername  $servername -DatabaseName $mySecondDBName -SampleName AdventureWorksLT 
Set-AzureRMSqldatabase -ServerName $servername -DatabaseName $mySecondDBName -ResourceGroupName $resourcegroupname -Edition Basic


# Create a new logical server in Southeast


$serverSEname = "svr-vf-au-se-training"
$location2 = "Australia Southeast"
$svr2adminlogin = "svrvfseadmin"
$svr2password = "vfP@ssw0rdadm1n"

$PWSQL = ConvertTo-SecureString -String $svr2password -AsPlainText -Force
$SQLCredential = New-Object System.Management.Automation.PSCredential($svr2adminlogin,$PWSQL) 


$server = New-AzureRmSqlServer -ResourceGroupName $resourcegroupname  -ServerName $serverSEname  -Location $location2   -SQLAdministratorCredentials $SQLCredential 

#$mySecondThirdName = "db-vf-TrainingDBADW3"
#$database3 = New-AzureRmSQLDatabase -ResourceGroupName $resourcegroupname -Servername  $serverSEname -DatabaseName $mySecondThirdName -SampleName AdventureWorksLT 

$FirewallRuleSE = New-AzureRmSqlServerFirewallRule -ResourceGroupName $resourcegroupname `
    -ServerName $serverSEname `
    -FirewallRuleName "AllowedIPsSE" -StartIpAddress $startipRange -EndIpAddress $endipRange



##################ELASTIC JOB STUFF
$JobDatabaseName = "db-vf-MSDB"

########################TRAINING LAB 4
$Myserver3 = "svr-vf-traininglab4"
$server3URL = $Myserver3 + '.database.windows.net'

$SQlServer3 =  Get-AzureRmSqlServer -ServerName $serverURL -ResourceGroupName $resourcegroupname -ErrorAction SilentlyContinue


$FirewallRule3 = New-AzureRmSqlServerFirewallRule -ResourceGroupName $resourcegroupname `
    -ServerName $Myserver3 `
    -FirewallRuleName "AllowedIPs" -StartIpAddress $startipRange -EndIpAddress $endipRange

$AutomationacocuntName = "vf-trainingLab4-automation"

$AA = New-AzureRmAutomationAccount -ResourceGroupName $resourcegroupname -Name $AutomationacocuntName 
Get-AzureRmAutomationConnection -ResourceGroupName $resourcegroupname -AutomationAccountName $AutomationacocuntName
Get-AzureRmAutomationCertificate -ResourceGroupName $resourcegroupname -AutomationAccountName $AutomationacocuntName

$AAConnection = "conn-vf-aaTrainingLab4"
$CertName = "cert-vf-conncert"


