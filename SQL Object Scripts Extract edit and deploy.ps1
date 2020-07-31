# Extract from SQL server
Import-Module sqlServer

Get-PSDrive

$ServerName = 'LGNRDB03'
$Database = 'ODSaaspirePRODR'
$Filter =  'tmp*.sql'
# dir "SQLSERVER:\SQL\$ServerName\default\Databases\$Database"

$ObjectPath = "SQLSERVER:\SQL\$ServerName\default\Databases\$Database\Views\"
dir $ObjectPath  <# | Where-Object {$_.Name -in 'tmpADV201', 'tmpADV211', 'tmpADV301', 'tmpADV301A', 'tmpCLA035', 'tmpCLA080', 'tmpMAS005', 'tmpMAS006', 'tmpMAS011', 'tmpPLA080', 'tmpPLA150'}  #>| Measure-Object
$FilePath = "C:\Temp\ScrathArea\Azure Move\LGNRDB03\"
#"\\AUKBMEDC01\Group\Shared\VNessa\Vanessa\Azure Hyperscale Stuff\Managed Instance Template\$ServerName\$Database\SP\"
# dir $ObjectPath

#dir $FilePath

cd $ObjectPath

#dir  $ObjectPath  |Where-Object {$_.Name -like 'tmp*'}|  foreach { $_.Script()  | Add-Content -Path "C:\Temp\ScrathArea\Azure Move\LGNRDB03\$($_.Schema)_$($_.Name)_$(Get-date -f 'yyyyMMdd').sql"}
dir  $ObjectPath  |Where-Object {$_.Schema -like 'Deleted'}|  foreach { $_.Script()  | Add-Content -Path "C:\Temp\ScrathArea\Azure Move\LGNRDB03\$($_.Schema)_$($_.Name)_$(Get-date -f 'yyyyMMdd').sql"}

dir  $ObjectPath |Where-Object {$_.Name -notlike 'APAC*'} |  foreach { $_.Script()  | Add-Content -Path "C:\Temp\ScrathArea\Azure Move\LGNRDB03\$($_.Schema)_$($_.Name)_$(Get-date -f 'yyyyMMdd').sql"}

#| Where-Object {$_.Name -in 'tmpADV201', 'tmpADV211', 'tmpADV301', 'tmpADV301A', 'tmpCLA035', 'tmpCLA080', 'tmpMAS005', 'tmpMAS006', 'tmpMAS011', 'tmpPLA080', 'tmpPLA150'} 
dir  $ObjectPath |
foreach { $_.Script()  | Add-Content -Path "C:\Temp\ScrathArea\Azure Move\LGNRDB03\$($_.Schema)_$($_.Name)_$(Get-date -f 'yyyyMMdd').sql"}




# Edit contents of all files in folder
$SourceFilesPath = '\\aukbmedc01\Group\Shared\VNessa\Vanessa\Azure Hyperscale Stuff\Managed Instance Template\\LGNRDB03\ODS\\Functions\'

Get-ChildItem -Path $SourceFilesPath  -Filter *.sql| 
 ForEach-Object {
   $Filename = $_.FullName
   $SqlContent = (Get-Content -Path $Filename).Replace('ODSaaspirePRODR', 'ODS_PRODC3_MI').Replace('ON [Data]', 'ON [PRIMARY]').Replace('getdate()','SYSDATETIME()').Replace('[datetime]','[datetime2]').Replace('GO','').Replace('COLLATE Latin1_General_CI_AS','').Replace('<<ODSDAtabase>>MonthPS', 'ODS_PRODC3_MIMonthPS').Replace('COLLATE Latin1_General_CI_AS','').Replace('ON [Index]','ON [PRIMARY]').Replace('SET ANSI_NULLS ON', '').Replace('GO', '').Replace('SET QUOTED_IDENTIFIER ON','').Replace('StagingReference.dbo.[StringToTable]', 'STRING_SPLIT')
   #$SqlContent = (Get-Content -Path $Filename).Replace('<<ODSDAtabase>>MonthPS', 'ODS_PRODC3_MIMonthPS').Replace('COLLATE Latin1_General_CI_AS','')
   
   Set-Content -Path $Filename -Value $SqlContent

 }

 # Rename all files in folder

 Get-ChildItem -Path $SourceFilesPath | 
 ForEach-Object {
   $Filename = $_.FullName
   $NewFileName =  $Filename.replace('dbo_', 'tmp_')
   Move-Item -Path $Filename -Destination $NewFileName
   Write-Host "Renamed " $_.BaseName " to " $NewFileName
 }

 # deploy all files in folder to Database
$SourceFilesPath = '\\aukbmedc01\Group\Shared\VNessa\Vanessa\Azure Hyperscale Stuff\Managed Instance Template\\LGNRDB03\ODS\\Functions\'
$SQlServer = 'LGHBDB17'
$TargetDB = 'ODS_PRODC3_MI'
$DeploymentStatus = New-Object -TypeName 'System.Collections.ArrayList';
$WarningList = New-Object -TypeName 'System.Collections.ArrayList';
$Find1 = 'ON [WarehouseData]'
$Replace1= 'ON [PRIMARY]'
$Find2 = '<<ODSDatabase>>'
$Replace2 = 'ODS_PRODC3_MI'
$Find3 = 'ON [Data]'
$replace3 = 'ON [PRIMARY]'
#   $SQl =  (Get-Content -Raw $FileName).Replace($Find1,$Replace1).Replace($Find2 ,$Replace2)
#.Replace('SET ANSI_NULLS ON','').Replace('<<TargetSchema>>',"$Database").Replace('SET QUOTED_IDENTIFIER ON', '')
  
Get-ChildItem $SourceFilesPath -Filter *.sql | 
   ForEach-Object {
     $FileName = $_.FullName
     $BaseName = $_.Name
     
     $Err = ''
     $Warn = ''
     $SQl =  (Get-Content -Raw $FileName).Replace($Find1,$Replace1).Replace($Find2 ,$Replace2).Replace($Find3, $replace3).Replace("GO",'').Replace('SET ANSI_NULLS ON','').Replace('SET QUOTED_IDENTIFIER ON','').Replace('[datetime]','[datetime2]')
     try{
     $QueryStatus = Invoke-DbaQuery -SqlInstance $SQlServer -Database $TargetDB -Query $SQl -ErrorAction Stop -ErrorVariable Err -WarningAction Continue -WarningVariable Warn 
     $obj=new-object PSObject -Property @{Type="$Type";ScriptNamer="$BaseName"; Status=1;ErrorMessage="Success"}
     Write-Host "Deployed $FileName  $Err"
     $WarnErr = new-object PSObject -Property @{DBNAme="$TargetDB";Type="$Type";ScriptName="$BaseName";;Warning="$Err $Warn"}
    }catch{Write-Host "Error Deploying $FileName"
         $obj=new-object PSObject -Property @{DBNAme="$TargetDB";Type="$Type";ScriptName="$BaseName"; Status=99;ErrorMessage="$Err $Warn"}
    }
    
     $WarnErr = new-object PSObject -Property @{DBNAme="$TargetDB";Type="$Type";ScriptName="$BaseName";;Warning="$Err $Warn"}
        If (!$Warn ){
        $Destination = $SourceFilesPath+'\Success\'
             Move-Item -Path $FileName -Destination $Destination
        }
        ElseIf ($Warn ) {
        $Destination = $SourceFilesPath+'\Warning\'
             Move-Item -Path $FileName -Destination $Destination
        }
     
     $DeploymentStatus.Add($obj)
     $WarningList.Add($WarnErr)
     
  }

