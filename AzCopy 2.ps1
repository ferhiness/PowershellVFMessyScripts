

$filesToUpload = Get-ChildItem $localFolder
$Results = New-Object -TypeName 'System.Collections.ArrayList';


cd "C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy\"

#.\AzCopy.exe cp "\\lghbdb24\DSBackup\PRODB2_MI\ODS_PRODB2_MI_20190708_28.bak" "$BLOBDestoinationURL/?sv=2018-03-28&ss=bfqt&srt=sco&sp=rwdlacup&se=2019-07-10T19:36:15Z&st=2019-07-09T11:36:15Z&spr=https&sig=Iq6OYHS91xt8DAz1XDi4OrKDqv5m5G%2FtOdMDknT8HbY%3D"

foreach ($Myfile in $filesToUpload){
  Write-Host "$localFolder\$Myfile"
  .\AzCopy.exe cp "$localFolder\$Myfile" "$DestinationURL/?sv=2018-03-28&ss=bfqt&srt=sco&sp=rwdlacup&se=2019-07-10T19:36:15Z&st=2019-07-09T11:36:15Z&spr=https&sig=Iq6OYHS91xt8DAz1XDi4OrKDqv5m5G%2FtOdMDknT8HbY%3D"
}

Start-Sleep -7200 
.\AzCopy.exe cp "D:\SQL_DATA\SQLData_2\Backup\PRODD4_MI\*.bak" "$BLOBDestoinationURL/?sv=2018-03-28&ss=bfqt&srt=sco&sp=rwdlacup&se=2019-07-16T15:39:29Z&st=2019-07-15T07:39:29Z&spr=https&sig=QyBRv6WtjszShtsA8ZZy9pRhbgF0NFEt0gp3iyuGkNU%3D"
