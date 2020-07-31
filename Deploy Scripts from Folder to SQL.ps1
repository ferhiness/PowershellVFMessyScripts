$ScriptFolderPath =  'C:\VF Queries\Queries\DBA Stuff\Azure\PEGA\BIX\20190808\dbo'
#$RevisionToGet # TODO Deploy from revision
#$JIRANumber = ''
$UATSqlServer = "LGHBDVDB05"
$DeloyToDatabaseName = "ODSBIX"


cd $ScriptFolderPath 

$SQLFiles = Get-ChildItem -Path $ScriptFolderPath -Filter *.sql   #-Recurse
$SQLFiles | Foreach-Object {
         $SQLFileName = $_.FullName
         [string] $FileContent = get-content $_. -Raw
         $CleanFileContent =  $FileContent.Replace("GO", "") 

         try{
               $DeployResult = 0
               Write-Host "Deploying $SQLFileName "
               $DeployResult = Invoke-DbaQuery -SqlInstance $UATSqlServer -Database $DeloyToDatabaseName -File $outputFile -ErrorVariable DeployError -MessagesToOutput }
              
                  
            }catch{
               Write-Host -ForegroundColor Red "TASER Deployment Error"
               $error
               $DeployError
               $InfoVar
               $error.Clear()
            }
}



