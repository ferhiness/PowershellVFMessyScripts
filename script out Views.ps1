$sourceserver = "LGNRDB03"
$Databasename = "WarehouseREST"
$ScriptFolderDestination = "C:\GIT repostitory\SqlServerBiOps\REST\AWS\ODS Extracts\Views\Full\"
#$Tables =  Get-DbaTable -SqlInstance $sourceserver  -Database $Databasename

#Invoke-DbaWhoIsActive -SqlInstance $sourceserver  -ShowOwnSpid -ShowSystemSpids | Out-GridView

#Get-Help Export-DbaScript 
#get-help Get-DbaDatabaseView -examples
# get-help Get-DbaDatabaseView -detailed
#$ViewList = Find-DbaView -SqlInstance $sourceserver -Database $Databasename -Pattern "DLT"  
#Find-DbaView -SqlInstance $sourceserver -Database $Databasename -Pattern "DLT"  
#Get-DbaDatabaseView -SqlInstance $sourceserver -Database $Databasename -ExcludeSystemView


#$ViewList | ForEach-Object { Export-DbaScript  -Path ($ScriptFolderDestination  + $_.Name + “.sql”) }
Get-DbaDatabaseView -SqlInstance $sourceserver   -Database $Databasename -ExcludeSystemView     | ForEach-Object {
        if ($_.Schema.Equals("DataExtract") -and ($_.Name.Contains("DLT")  -and -Not ($_.Name.Contains("Delta")) ) ){
            Export-DbaScript -InputObject $_ -Path ( $ScriptFolderDestination+$_.Name + “.sql”) 
        }  
        #  Export-DbaScript -InputObject $_ -Path ( $ScriptFolderDestination+$_.Name + “.sql”) 
          
}
