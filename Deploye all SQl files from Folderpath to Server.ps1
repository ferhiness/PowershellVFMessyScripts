 
  
$SQLScriptFolderPath = "C:\VF Queries\Queries\DBA Stuff\Azure\PEGA\BIX\ODSBIX_OnPrem\"
$SQLPostDeploymentPath = "C:\VF Queries\Queries\DBA Stuff\Azure\PEGA\BIX\ODSBIX_OnPrem\Deployed"

$SQLServer = "LGNRDB03"
$SQLDatabase = 'ODSBIX'

#Clean up the filenames

Get-ChildItem -Path $SQLScriptFolderPath -Filter BIX_DT01.* |Rename-Item  -NewName { $_.name -replace ‘BIX_DT01.’,’dbo.’  } -WhatIf

Get-ChildItem -Path $SQLScriptFolderPath -Filter *.Table.sql |Rename-Item  -NewName { $_.name -replace ‘.Table.sql’,’.sql’  } -WhatIf

Get-ChildItem -Path $SQLScriptFolderPath -Filter *.StoredProcedure.sql |Rename-Item  -NewName { $_.name -replace ‘.StoredProcedure.sql’,’.sql’  } -WhatIf

Get-ChildItem -Path $SQLScriptFolderPath -Filter *.StoredProcedure.sql |Rename-Item  -NewName { $_.name -replace ‘.UserDefinedFunction.sql’,’.sql’  } -WhatIf


# Now start deploying & moving to deployed folder
$scripts = Get-ChildItem $SQLScriptFolderPath | Where-Object {$_.Extension -eq ".sql"}
  
foreach ($s in $scripts)
    {
        
        $FullFilePath = $SQLScriptFolderPath+$s
        
        [string] $FileContent = get-content $FullFilePath  -Raw
        Write-Host "Running Script : " $FullFilePath  
        #-BackgroundColor DarkGreen -ForegroundColor White
        try{
              $result = Invoke-DbaQuery -SqlInstance $SqlServer  -Database $SQLDatabase  -file $FullFilePath -Verbose -MessagesToOutput  
              move-item -Path $FullFilePath -Destination $SQLPostDeploymentPath
           }catch{
             Write-Host -BackgroundColor White  -ForegroundColor Red "Issue Encountered Deploying $FullFilePath " $result
             $error 
             $error.Clear()
           }
        
    }