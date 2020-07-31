#Read the excel file to get all releases
$ReleaseJIRANumber = 'IT-54267'
$SpreadsheetFileName = 'IT-54267_INFO_Task_List_V1.xlsx'
$TempFilePath = 'C:\Temp\DEV team'

New-JiraSession 
$ReleaseJIRA = Get-JiraIssue -Key $ReleaseJIRANumber
$Excel = Get-JiraIssueAttachment -Issue $ReleaseJIRANumber -FileName $SpreadsheetFileName


Invoke-JiraMethod -Uri (Get-JiraIssueAttachment -Issue $ReleaseJIRANumber -FileName $SpreadsheetFileName).Content -OutFile  $TempFilePath


$A = Import-Excel -Path $Excel.Content -WorksheetName 'deployment instruction'

$ReleaseNumbers ='4.08.83CH','4.08.84CH','4.08.85CH','4.08.86CH','4.08.87CH','4.08.88CH','4.08.89CH'
$ReleaseFolderRoot = '\\aukbmedc01\group\Shared\IT Strategy\BIDelivery\Releases\WarehouseV4\'
#$ReleaseNumber = '4.08.39VK'
$ReleaseType = 'Report'
$SqlServerProd = "PRDLGDWRS1"
$DatabaseName = "LinkReports"


foreach($ReleaseNumber in $ReleaseNumbers){ 
#$ReleaseNumber}
      $ReleaseLocation = $ReleaseFolderRoot + $ReleaseNumber
      Write-Host -ForegroundColor Yellow $ReleaseLocation
      $ReportsFolder = $ReleaseLocation + '\Reports'
      $ExcludeFolder = $ReleaseFolderRoot +$ReleaseNumber+ '\Reports'+'\Rollback'
      
      if ($ReleaseType -eq 'Report') {
      #Write-Host $ReleaseLocation + '\Reports'
         $Files = Get-ChildItem -Path $ReportsFolder -Recurse -Filter *.rdl 
         #-Include  *.rdl -Exclude $ExcludeFolder
      }else{Write-Host $ReleaseType}
      
      foreach($file in $Files){
          $TASERExists = 0
          if( $file.Directory.Name -ne 'Rollback'){
          #$file.BaseName
          $ReportName = $file.BaseName
          $SQlCheckTASErExists = "SELECT COUNT(*) As TaserCount FROM ReportSubscriptions WHERE ReportName = '$ReportName' "
          $TASERExists = Invoke-DbaQuery -Sqlinstance $SqlServerProd -Database $DatabaseName -Query $SQlCheckTASErExists
          Write-host $ReleaseNumber $ReportName $TASERExists.TaserCount
          }
      
      }
}

Get-Help Get-AzBlueprint
Install-Module -Name Az.Blueprint

Get-InstalledModule -Name Az.Blueprint

#Start-DbaAgentJob -SqlInstance LGHBDB17 -Job 'Run Process MC Extracts' -Verbose

Set-PowershellIcon 


$Cred = Get-DbaCredential -SqlInstance LGHBDB17 
$C1 = $Cred.Item(0) 
$C1.GetType()


Install-Module -Name SqlServerDsc 
Update-Module -Name dbatools -Force
Get-InstalledModule -Name dbatools 
 
