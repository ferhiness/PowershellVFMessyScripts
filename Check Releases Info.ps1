$ReleaseBaseFolder = '\\aukbmedc01\group\Shared\IT Strategy\BIDelivery\Releases\WarehouseV4\'
$ReleaseNo = '4.07.99VK'
$ChangeType = 'Report'
$ReportServerUri = 'http://prdlgdwrs1/ReportServer'
$TASERReportPathBase  = '/'

$Folder = $ReleaseBaseFolder + $ReleaseNo
if ($ChangeType.Contains('Report')){
  $Folder=$Folder+"\Reports\"
  
  $files = get-childitem $Folder -Recurse -Exclude 'Rollback' -Attributes 'a' | where-object{$_.fullname -inotmatch 'Rollback' }
  foreach ($file in $files){
  $file
    
    $TASERReportPathBase  = $TASERReportPathBase  + $file.FullName.Replace($Folder,'').Replace('\','/').Replace('.rdl', '')
    $SQLFindTASErExists = "SELECT ReportSubscriptionSKey FROM dbo.ReportSubscriptions
    where ReportName like '%$TASERReportPathBase%' AND Enabled = 1 "
    $TASERList =  Invoke-DbaQuery -SqlInstance PRDLGDWRS1 -Database LinkReports -Query $SQLFindTASErExists
    if($TASERList){  $TASERList }

  }
   
}