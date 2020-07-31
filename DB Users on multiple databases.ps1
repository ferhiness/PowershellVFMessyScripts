#Get-Command -Module  DBATools
Get-DbaAvailabilityGroup -SqlInstance PRDLGDB1 | Select SqlInstance, LocalReplicaRole, PrimaryReplica, 

$ServerName = "LGNRDB07"
$UserToCreate = "APAC\SQL_LGHBDVDB06_svc"
$Server = New-Object('Microsoft.SqlServer.Management.Smo.Server') $ServerName 

$Server.databases | Where-Object {$_.IsSystemObject -eq $false } | select Name

$SQLCreateUSer =  " USE [BP_PRD]
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N''APAC\SQL_LGHBDVDB06_svc'') CREATE USER [APAC\SQL_LGHBDVDB06_svc] FOR LOGIN [APAC\SQL_LGHBDVDB06_svc] WITH DEFAULT_SCHEMA=[dbo];
;
ALTER ROLE [db_datareader] ADD MEMBER [APAC\SQL_LGHBDVDB06_svc]
"

 
 foreach ($db in $Server.databases){
  if (! $db.Users.Contains($UserToCreate)){
   


  }
 }

 #BP_PRD
  #$dbFrom = $Server.databases | Where-Object {$_.Name -eq "RM_REST" } 
   $db1 = $Server.databases | Where-Object {$_.Name -eq "BP_PRD" } 

  if (!$db1.Users.Contains($UserToCreate)){
    $usr1 = New-Object ('Microsoft.SqlServer.Management.Smo.User') ($db1, $UserToCreate)
    $usr1.Login = $UserToCreate
    $usr1.Create()
  }

  $UTest = $dbFrom.Users | Where-Object {$_.Name  -eq $UserToCreate }
  $UTest.GetType()
  $dbFrom.Users.GetType()
  
  #Find-DbaUserObject -SqlInstance $ServerName   | Where-Object {-Name  -eq $UserToCreate }
  $DBUsertoCopy = Export-DbaUser -SqlInstance $ServerName -Database "RM_REST" -User $UserToCreate
  $Server.Query($SQLCreateUSer)
 
  Invoke-DbaSqlCmd -SqlInstance LGNRDB07 -Database $db1.Name -Query "CREATE USER [APAC\SQL_LGHBDVDB06_svc] FOR LOGIN [APAC\SQL_LGHBDVDB06_svc] WITH DEFAULT_SCHEMA=[dbo];"

 
  
  
  