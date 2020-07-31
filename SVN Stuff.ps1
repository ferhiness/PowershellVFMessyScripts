svn info $PATH
$PATH = "C:\SVN\TASER SQl Scripts"
$File = "C:\SVN\TASER SQl Scripts\TASER_Account Balance 6000 - Christian Super.sql"
$currentrevision = svn info  $File

$currentrevision 

[xml] $RevisionList = svn log --verbose --xml -r 21048
$RevisionFileList = $RevisionList.log.logentry.paths.path | %{$_.InnerText}

$RevisionFileList | ForEach-Object { $outputFile = Split-Path $_ -leaf 
                                     

                                     [string] $FileContent = get-content $outputFile | select-string -Pattern "DECLARE" | Where-Object {$_ -like '*@ReportSubscriptionSKey*'}
                                     #$SubNos.ToString().Replace("DECLARE @ReportSubscriptionSKey INT =", "")
                                     #$SubNos.ToString().IndexOf("--")
                                     $SubNumber = $FileContent.Replace("DECLARE", "").Replace("@ReportSubscriptionSKey", "").Replace(" INT", "").Replace("=","").Replace("INT","").Substring(0, $SubNumber.ToString().IndexOf("--")).Trim()
                                     #$FileContent.Substring(0,  $SubNos.ToString().IndexOf("--"))
                                     #$SubNumber.Substring(0, $SubNumber.ToString().IndexOf("--")).Trim()
                                     Write-Host $outputFile : $SubNumber
                                     }

$RevisionFileList | ForEach-Object { $FileName = Split-Path $_ -leaf 
                                         #Write-Host $FileName
                                         $EmailSubject =  $FileName.Replace("TASER_", "").Replace(".sql","")
                                         $EmailSubject  }

$databasename = "Linkreports"
$BasesqlQuery = "SELECT * FROM " + $databasename + ".dbo.ReportSubscriptions "
$FilterColumn = " EmailSubject "

$RevisionFileList | ForEach-Object { $FileName = Split-Path $_ -leaf 
                                     #Write-Host $FileName
                                     $EmailSubject =  $FileName.Replace("TASER_", "").Replace(".sql","")
                                     #$EmailSubject 
                                     $SQLCommand = 
                                            new-object system.data.sqlclient.sqlcommand(
                                                $BasesqlCommand + " WHERE " + $FilterColumn + " IN ( '" + $EmailSubject + "')",$connection)
                                     $SQLCommand.CommandText
                                   }



Select-Xml -Content $RevisionList -XPath "//log/logentry" | foreach {$_.node.InnerText}


svn log --verbose -r 21048 

svn list -r 21048
svn diff --revision 21048:21047

TortoiseProc /command:log /findtype:path 

Get-SvnRepository

$ReportList = Invoke-DbaSqlQuery -SqlInstance PRDLGDWRS1 -Database LinkReports -Query 'SELECT * FROM LinkReports.dbo.ReportSubscriptions'
Write-DbaDataTable -SqlInstance 'LGHBDVDB06' -Database 'LinkReports' -InputObject $ReportList -Schema Backup -Table 'ReportSubscriptionsProd' -AutoCreateTable  -WhatIf

