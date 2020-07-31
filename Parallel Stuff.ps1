#Run Script against multiple databases
$ServerNAme = 'au-e-sqlmi-aaspireods-dev.f429637c13ca'
$ServerURL =  "$ServerNAme.database.windows.net"
$SqlCredentials = Get-Credential -UserName SQlAdmin -Message "Password for SQLAdmin"
 

$RunDatabaseList = "ODSaaspirePRODA1", "ODSaaspirePRODB2", "ODSaaspirePRODC3", "ODSaaspirePRODD4", "ODSaaspirePRODF6", "ODSaaspirePRODG7", "ODSaaspirePRODH8", "ODSaaspirePRODO", "ODSaaspirePRODR"

#get-help Start-Parallel -examples

$RunList = @()

#$RunDatabaseList |   Start-Parallel -Scriptblock {"Starting:$_ "; Write-Host Get-Date}
foreach ($Db in $RunDatabaseList) {
    $RunList += [pscustomobject]@{
        Server = $ServerURL;
        RunOnThisDatabase = $Db;
        Query = 'SELECT DB_NAME()';
      }
}

$RunList |Invoke-Parallel  -Throttle 9 -Verbose:$True -Scriptblock {
    $Server = $($_.Server)
    $Db = $($_.RunOnThisDatabase)
    $Query = $($_.Query)
    "Running $Query on  $ServerURL  Databasename $Db"
    Invoke-DbaQuery -SqlInstance $ServerURL  -Database $Db -Query $Query  -SqlCredential $SqlCredentials
    
}


Resolve-Path $ScriptFolderPath 

#Claculate first and Last day of Month
[ValidateRange(1,12)][int]$month = 3
$year = 2019
$last = [DateTime]::DaysInMonth($year, $month)
$first = Get-Date -Day 1 -Month $month -Year $year -Hour 0 -Minute 0 -Second 0
$last = Get-Date -Day $last -Month $month -Year $year -Hour 23 -Minute 59 -Second 59




#### Execute Query on Multiple DBs Testing Method 1

workflow batchall{
param([string []] $databases)
    foreach -parallel ($Database in $databases){
       Write-Host "$Database"
       Invoke-DbaQuery -SqlInstance $SqlMIServer -Database $Database -SqlCredential $SqlCredential -Query "SELECt DB_NAME() As DBName, GETDATE() As TodaysDate"
    }
}

batchall -databases $DBList | Format-Table DBName, TodaysDate