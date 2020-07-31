$ReleaseNumbers ='4.08.76CH','4.08.74CH','4.08.75CH','4.08.70CH','4.08.72CH','4.08.71CH','4.08.77CH','4.08.73CH'
$ReleaseFolderRoot = '\\aukbmedc01\group\Shared\IT Strategy\BIDelivery\Releases\WarehouseV4\'
#$ReleaseNumber = '4.08.17VK'
$ReleaseType = 'Report'
$SqlServerProd = "PRDLGDWRS1"
$DatabaseName = "LinkReports"


foreach($ReleaseNumber in $ReleaseNumbers){ 
#$ReleaseNumber}
      $ReleaseLocation = $ReleaseFolderRoot + $ReleaseNumber
      
      $ReportsFolder = $ReleaseLocation + '\Reports'
      $ExcludeFolder = $ReleaseFolderRoot +$ReleaseNumber+ '\Reports'+'Rollback'
      
      if ($ReleaseType -eq 'Report') {
      #Write-Host $ReleaseLocation + '\Reports'
         $Files = Get-ChildItem -Path $ReportsFolder -Recurse -Filter *.rdl 
         #-Include  *.rdl -Exclude $ExcludeFolder
      }
      
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

