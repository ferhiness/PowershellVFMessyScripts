$DeploymentStatus = New-Object -TypeName 'System.Collections.ArrayList';
$WarningList = New-Object -TypeName 'System.Collections.ArrayList';
#cd c:\

#$Dir = '\\aukbmedc01\Group\Shared\VNessa\Vanessa\Azure Hyperscale Stuff\Managed Instance Template\Scripts from MI\Config\\Schemas\'


$SQlServer = 'LGHBDB17'
$Database = 'Warehouse'
$Type = 'Views'
$Dir = "\\aukbmedc01\Group\Shared\VNessa\Vanessa\Azure Hyperscale Stuff\Managed Instance Template\LGNRDB03\$Database\$Type\"

$Type = $Dir |  Split-Path -Leaf

cd $Dir
dir $Dir | Measure-Object
#$Dir -Filter *.sql 
#$ObjectName = $BaseName.Replace("dbo_",'').Replace("_20200723.sql",'')
#$Query = "SELECT * from sys.objects where [name] = '$ObjectName'"
#Invoke-DbaQuery -SqlInstance $Server -Database TrusteeReporting -Query "SELECT GETDATE()"

Get-ChildItem $Dir -Filter *.sql | 
  ForEach-Object {
     $FileName = $_.FullName
     $BaseName = $_.Name
     $SQl =  (Get-Content -Raw $FileName).Replace('ON [WarehouseData]','ON [PRIMARY]').Replace('WarehouseData',"PRIMARY").Replace('APRA','[PRIMARY]').Replace('WarehouseIndexes', '[PRIMARY]')
     try{
     $QueryStatus = Invoke-DbaQuery -SqlInstance $SQlServer -Database $Database -Query $SQl -ErrorAction Continue -ErrorVariable $Err -WarningAction Continue -WarningVariable $Warn
     $obj=new-object PSObject -Property @{Type="$Type";ScriptNamer="$BaseName"; Status=1;ErrorMessage="Success"}
     Write-Host "Deployed $FileName"
     $WarnErr = new-object PSObject -Property @{DBNAme="$Database";Type="$Type";ScriptName="$BaseName";;Warning="$Err $Warn"}
     }catch{Write-Host "Error Deploying $FileName"
     $obj=new-object PSObject -Property @{DBNAme="$Database";Type="$Type";ScriptName="$BaseName"; Status=99;ErrorMessage="$Err $Warn"}
     $WarnErr = new-object PSObject -Property @{DBNAme="$Database";Type="$Type";ScriptName="$BaseName";;Warning="$Err $Warn"}
     
     }
     $DeploymentStatus.Add($obj)
     $WarningList.Add($WarnErr)
     
  }

  $DeploymentStatus | Export-Csv -Path "C:\Temp\ScrathArea\Azure Move\MI_$Database.csv"