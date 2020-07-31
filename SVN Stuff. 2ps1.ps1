$RevisionNoFrom = 21048
#$RevisionNoTo = 21048

$SQLServer = "PRDLGDWRS1"
$databasename = "Linkreports"

$BasesqlCommand = "SELECT * FROM " + $databasename + ".dbo.ReportSubscriptions "
$FilterColumn = " EmailSubject "




[xml] $RevisionFilesXML = svn log --verbose --xml -r $RevisionNoFrom
$RevisionFileNameList = $RevisionList.log.logentry.paths.path | %{$_.InnerText}

#$RevisionFileNameList | ForEach-Object {Write-Host $_}
#For each file in List get subscription number


$RevisionFileNameList | ForEach-Object { $FileName = Split-Path $_ -leaf 
                                         #Write-Host $FileName
                                         $EmailSubject =  $FileName.Replace("TASER_", "").Replace(".sql","")
                                         #$EmailSubject 
                                         $BasesqlCommand + " WHERE " + $FilterColumn + " IN ( '" + $EmailSubject + "')"

                                       }


                                       
$RevisionFileNameList | ForEach-Object { $outputFile = Split-Path $_ -leaf 

                                     [string] $FileContent = get-content $outputFile | select-string -Pattern "DECLARE" | Where-Object {$_ -like '*@ReportSubscriptionSKey*'}
                                     #$SubNos.ToString().Replace("DECLARE @ReportSubscriptionSKey INT =", "")
                                     #$SubNos.ToString().IndexOf("--")
                                     $SubNumber = $FileContent.Replace("DECLARE", "").Replace("@ReportSubscriptionSKey", "").Replace(" INT", "").Replace("=","").Replace("INT","").Substring(0, $SubNumber.ToString().IndexOf("--")).Trim()
                                     #$FileContent.Substring(0,  $SubNos.ToString().IndexOf("--"))
                                     #$SubNumber.Substring(0, $SubNumber.ToString().IndexOf("--")).Trim()
                                     Write-Host $outputFile : $SubNumber
       
       }





