#Deploy to multi0ple Schemas

$SqlCredential = Get-Credential -UserName 'SqlAdmin' -Message 'Password for SqlAdmin user' 
$SqlMIServer = 'au-e-sqlmi-aaspireods-dev.f429637c13ca.database.windows.net'


$ScriptFolderPath =  'C:\Temp\ScrathArea\Deploy'

$DBList = 'ODSaaspirePRODA1', 'ODSaaspirePRODB2', 'ODSaaspirePRODC3', 'ODSaaspirePRODD4', 'ODSaaspirePRODF6', 'ODSaaspirePRODG7', 'ODSaaspirePRODH8', 'ODSaaspirePRODO', 'ODSaaspirePRODR'

cd $ScriptFolderPath 

$SQLFiles = Get-ChildItem -Path $ScriptFolderPath -Filter *.sql 

$SQLFiles | ForEach-Object {
    $outputFile = $_ #Split-Path $_ -leaf                                   
    [string] $FileContent = get-content $outputFile -Raw
    
    #$CleanFileContent =  $FileContent.Replace("GO", "") 
    Write-Host $outputFile
    foreach  ($DeloyToDatabaseName in $DBList){
      $UpdatedFileContent = $FileContent.Replace('<<ODSSchema>>',$DeloyToDatabaseName ).Replace('<<ODSDatabase>>', $DeloyToDatabaseName)
      Write-Host "Deploying $outputFile to $DeloyToDatabaseName on $SqlMIServer" 
      try{
        #Invoke-DbaQuery -SqlInstance $SqlMIServer -Database $DeloyToDatabaseName -SqlCredential $SqlCredential  -File $outputFile 
        Invoke-DbaQuery -SqlInstance $SqlMIServer -Database $DeloyToDatabaseName -SqlCredential $SqlCredential -Query $UpdatedFileContent
      }catch{
        Write-Error "Error"
      }
     }
}



#######################################################################################################################


$SqlCredential = Get-Credential -UserName 'SqlAdmin' -Message 'Password for SqlAdmin user' 
$SqlMIServer = 'au-e-sqlmi-aaspireods-dev.f429637c13ca.database.windows.net'



$RunQuery = "
	EXEC sp_changedbowner 'SQLAdmin'
    GO
"

$DBList = 'ODSaaspirePRODA1', 'ODSaaspirePRODB2', 'ODSaaspirePRODC3', 'ODSaaspirePRODD4', 'ODSaaspirePRODF6', 'ODSaaspirePRODG7', 'ODSaaspirePRODH8', 'ODSaaspirePRODO', 'ODSaaspirePRODR'
foreach  ($DeloyToDatabaseName in $DBList){
     try 
    {
        Write-Host "Running Query on :- $($SqlMIServer) on $($DeloyToDatabaseName)"
        Invoke-DbaQuery -SqlInstance $SqlMIServer -Database $DeloyToDatabaseName -SqlCredential $SqlCredential -Query $RunQuery -Verbose
        Write-Host "Completed Query on :- $($SqlMIServer) on $($DeloyToDatabaseName)"

    }catch{
        Write-Host "Some error occured"
    }

}


#######################################################################################################################

#Run data for multiple years

$SqlCredential = Get-Credential -UserName 'SqlAdmin' -Message 'Password for SqlAdmin user' 
$SqlMIServer = 'au-e-sqlmi-aaspireods-dev.f429637c13ca.database.windows.net'

$Years = 2012, 2013, 2014, 2015, 2016,2017,2018,2019

$DBList = 'ODSaaspirePRODA1', 'ODSaaspirePRODB2', 'ODSaaspirePRODC3', 'ODSaaspirePRODD4', 'ODSaaspirePRODF6', 'ODSaaspirePRODG7', 'ODSaaspirePRODH8', 'ODSaaspirePRODO', 'ODSaaspirePRODR'


$stopwatch =  [system.diagnostics.stopwatch]::StartNew()

foreach($Year in $Years){

    $RunQuery = "

    INSERT INTO TrusteeReporting.dbo.TopNDescription
    ( [Description], [LastChangeTime], [LastChangeUser], [CreateTime], [CreateUser])
    SELECT DISTINCT U.[Description], GETDATE(), SUSER_NAME(), GETDATE(), SUSER_NAME()
    FROM [Extract].udfPlanMonthTopNSnapshot ('$Year-01-01','*') U
    LEFT JOIN TrusteeReporting.dbo.TopNDescription T on U.[Description] = T.[Description]
    WHERE T.[Description] IS NULL
    "

    #$RunQuery

    foreach  ($DeloyToDatabaseName in $DBList){
              try 
             {
                 Write-Host "Running Query on :- $($SqlMIServer) on $($DeloyToDatabaseName)"
                 Invoke-DbaQuery -SqlInstance $SqlMIServer -Database $DeloyToDatabaseName -SqlCredential $SqlCredential -Query $RunQuery
                 Write-Host "Completed Query on :- $($SqlMIServer) on $($DeloyToDatabaseName)"

             }catch{
                 Write-Host "Some error occured"
             }
       }
}


$stopwatch.Stop()

$stopwatch.Elapsed.Hours
$stopwatch.Elapsed.Minutes
$stopwatch.Elapsed.Seconds
$stopwatch.Elapsed.TotalSeconds





#######################################################################################################################


$SqlCredential = Get-Credential -UserName 'SqlAdmin' -Message 'Password for SqlAdmin user' 
$SqlMIServer = 'au-e-sqlmi-aaspireods-dev.f429637c13ca.database.windows.net'



$RunQuery = "
DECLARE @ReportDate	DateTime = '2018-09-01'
DECLARE @PlanSKeyList  Varchar(MAX) = NULL
EXEC [Extract].[PlanEmployerContributionLoad] @ReportDate, @PlanSKeyList
"

$DBList = 'ODSaaspirePRODA1', 'ODSaaspirePRODB2', 'ODSaaspirePRODC3', 'ODSaaspirePRODD4', 'ODSaaspirePRODF6', 'ODSaaspirePRODG7', 'ODSaaspirePRODH8', 'ODSaaspirePRODO', 'ODSaaspirePRODR'

$QueriesToRun = @()

foreach($DB in $DBList){
    $QueriesToRun += [pscustomobject]@{
    Server = $SqlMIServer;
    RunOnThisDatabase = $DB;
    Query = $RunQuery
   
    }
}

#$QueriesToRun.Count
$stopwatch =  [system.diagnostics.stopwatch]::StartNew()

$QueriesToRun | Invoke-Parallel  -Throttle 10 -Verbose:$True -ScriptBlock {
    try 
    {
        Write-Host "Running Query on :- $($_.Server) on $($_.RunOnThisDatabase)"
        Invoke-DbaQuery -SqlInstance $_.Server -Database $_.RunOnThisDatabase -SqlCredential $SqlCredential -Query $_.Query
        Write-Host "Completed Query on :- $($_.Server) on $($_.RunOnThisDatabase)"

    }catch{
        Write-Host "Some error occured"
    }

}

$stopwatch.Stop()

$stopwatch.Elapsed.Hours
$stopwatch.Elapsed.Minutes
$stopwatch.Elapsed.Seconds
$stopwatch.Elapsed.TotalSeconds

 