#Oracle section

    $User = "DBMAN"
    $PasswordFile = "D:\SQL_DATA\Data\ITOP\Keys\ora.txt"
    $KeyFile = "D:\SQL_DATA\Data\ITOP\Keys\AES.key"
    $key = Get-Content $KeyFile
    $MyCredential = New-Object -TypeName System.Management.Automation.PSCredential `
     -ArgumentList $User, (Get-Content $PasswordFile | ConvertTo-SecureString -Key $key)

    $username = $MyCredential.UserName
    $password = $MyCredential.GetNetworkCredential().Password
    $data_source = "pdbrepo"
    $connection_string = "User Id=$username;Password=$password;Data Source=$data_source"





$TemplateJsonFilename = "C:\VF Queries\Queries\DBA Stuff\CDC Stuff\Ora_To_LogStream.json"

$TemplateJson = Get-Item $TemplateJsonFilename

$TemplateJSonFileCOntents = Get-Content $TemplateJson -Raw

$TemplateJSonFileCOntents = $TemplateJSonFileCOntents -replace "^//.*\n", "" 
#ConvertFrom-Json : Invalid JSON primitive: .
#At line:1 char:20

$TemplateJSonObject = ConvertFrom-Json $TemplateJSonFileCOntents

$TemplateJSonTaskList = $TemplateJSonObject.'cmd.replication_definition'.tasks
$TemplateJsonDBs = $TemplateJSonObject.'cmd.replication_definition'.databases

$TemplateJSonTaskList.Count 
$DB = $TemplateJsonDBs.Item(0)

$TemplateJSonTaskList.Item[0]
$Task =  $TemplateJSonTaskList.Item(0)

$TaskSettings = $Task.task_settings
$Task.task.task_type

$source_tablesObject = $Task.source.source_tables
$TableListObjects = $source_tablesObject.explicit_included_tables
$IncludeTableObj = New-Object -TypeName psobject  
##TODO - Get the Oracle list of tables

{
$IncludeTableObj | Add-Member -MemberType NoteProperty -Name owner -Value  'ATU_DATA'
$IncludeTableObj | Add-Member -MemberType NoteProperty -Name owner -name   ''
$IncludeTableObj | Add-Member -MemberType NoteProperty -Name owner -estimated_size  ''
$IncludeTableObj | Add-Member -MemberType NoteProperty -Name owner -orig_db_id  ''
$IncludeTableObj | Add-Member -MemberType NoteProperty -Name owner -description  ''
 }

$I.task.target_names
$I.task.target_names
$I.source.source_tables
$I.targets
$I.task.source_name
$I.targets.Item(0).rep_target



$SqlSourceTableList = "SELECT 'ATU_DATA' As [owner], TableName As [name], 0 As  [estimated_size], 0 As orig_db_id,  '' As [description]
FROM Staging.dbo.EOM_BatchList WHERE Batch = 7"

$Credentialpwd = Get-Credential -Message "MI Creds" -UserName 'SQLAdmin' 


$SourceTblList = Invoke-DbaQuery -SqlInstance 'au-e-sqlmi-dev.fd1171b98898.database.windows.net' -Database 'Staging' -SqlCredential $Credentialpwd -Query $SqlSourceTableList
$SourceTblListJSON = ConvertTo-Json -InputObject  

$SourceTblList 

