$DeploymentStatus = New-Object -TypeName 'System.Collections.ArrayList';
$WarningList = New-Object -TypeName 'System.Collections.ArrayList';


$Dir = '\\aukbmedc01\Group\Shared\VNessa\Vanessa\Azure Hyperscale Stuff\Managed Instance Template\LGNRDB03\Warehouse\SP\'
$Type = $Dir |  Split-Path -Leaf

$SQlServer = 'LGHBDB17'
$Database = 'Warehouse'

cd $Dir

#$Dir -Filter *.sql 
#
Get-ChildItem $Dir -Filter *.sql | 
  ForEach-Object {
     $FileName = $_.FullName
     $BaseName = $_.Name
     
     $Err = ''
     $Warn = ''
     $SQl =  (Get-Content -Raw $FileName).Replace('SET ANSI_NULLS ON','').Replace('<<TargetSchema>>',"$Database").Replace('SET QUOTED_IDENTIFIER ON', '')
     try{
     $QueryStatus = Invoke-DbaQuery -SqlInstance $SQlServer -Database $Database -Query $SQl -ErrorAction Continue -ErrorVariable $Err -WarningAction Continue -WarningVariable $Warn
     $obj=new-object PSObject -Property @{Type="$Type";ScriptNamer="$BaseName"; Status=1;ErrorMessage="Success"}
     Write-Host "Deployed $FileName"
     $WarnErr = new-object PSObject -Property @{DBNAme="$Database";Type="$Type";ScriptName="$BaseName";;Warning="$Err $Warn"}
     }catch{Write-Host "Error Deploying $FileName"}
     $obj=new-object PSObject -Property @{DBNAme="$Database";Type="$Type";ScriptName="$BaseName"; Status=99;ErrorMessage="$Err $Warn"}
     $WarnErr = new-object PSObject -Property @{DBNAme="$Database";Type="$Type";ScriptName="$BaseName";;Warning="$Err $Warn"}
        If ($Warn-eq "") {
        $Destination = $Dir+'\Success\'
             Move-Item -Path $FileName -Destination $Destination
        }
        ElseIf ($Warn -ne "") {
        $Destination = $Dir+'\Warning\'
             Move-Item -Path $FileName -Destination $Destination
        }
     
     $DeploymentStatus.Add($obj)
     $WarningList.Add($WarnErr)
     
  }

  $DeploymentStatus | Export-Csv -Path "C:\Temp\ScrathArea\Azure Move\MI_$Database.csv"