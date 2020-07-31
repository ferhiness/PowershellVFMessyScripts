

$Dir = 'C:\Temp\SVN\BIX_Staging'
$SQlServer = 'LGHBDVDB05'
$Database = 'ODSBIX'
cd $Dir
Get-ChildItem $Dir -Filter *.sql | 
  ForEach-Object {
     $FileName = $_.FullName
     $SQl =  (Get-Content -Raw $FileName) 
     try{
     $QueryStatus = Invoke-DbaQuery -SqlInstance $SQlServer -Database $Database -Query $SQl
     Write-Host "Deployed $FileName"
     }catch{Write-Host "Error Deploying $FileName"}
  }


