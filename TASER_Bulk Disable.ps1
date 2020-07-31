#$ComputerName = $env:COMPUTERNAME

$TASERSKeys =  @(6181,6182,6183,6185,6190,6191,6192,6193,6198,5421,5422,5423,5424,5425,5426,5427,5428,5429,5434,5436,5437,5438,5439,5440,5441,5442,7011,7015,7032,7136,7254,7467,7526,7750,8680)
$TASERBasePATH = "C:\SVN\TASER SQl Scripts\"
$TempDest = "C:\Temp\SVN"

cd $TASERBasePATH 
svn update 
svn info $TASERBasePATH
$error.Clear()

#Get The Files from SVN
$SqlEmailSubjectlist = "SELECT ReportSubscriptionSKey,  EmailSubject, 'TASER_' + EmailSubject+ '.sql' As SVNFilename FROM Linkreports.dbo.ReportSubscriptions WHERE ReportSubscriptionSkey IN (6181,6182,6183,6185,6190,6191,6192,6193,6198,5421,5422,5423,5424,5425,5426,5427,5428,5429,5434,5436,5437,5438,5439,5440,5441,5442,7011,7015,7032,7136,7254,7467,7526,7750,8680) "

$SVNFileList = Invoke-DbaQuery -SqlInstance PRDLGDWRS1 -Database LinkReports -Query $SqlEmailSubjectlist 
$SVNFileList | select SVNFilename
foreach($file  in $SVNFileList){
  $Source = $TASERBasePATH + $file.SVNFilename
    Write-host  $Source
    (Get-Content ($Source)) |  Foreach-Object {$_ -replace "DECLARE \@Enabled \[bit\] = 1", ("DECLARE @Enabled [bit] = 0")} | Set-Content  ("C:\Temp\ScrathArea\"+$file.SVNFilename)
   # Copy-Item $file.SVNFilename $TempDest
}

#Now put them back in SVN





