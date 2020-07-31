####################################################################################  
## Deploy TASERs from SVN to prod
## 2018-12-30  V.Fernandes   Initial attempts to automate TASEr deployment
## 2019-01-09  V.Fernandes   
####################################################################################  
#Declaration Section
$RevisionToGet = 22111
$JIRANumber = "INFO-24688"
$SqlServer = "PRDLGDWRS1"
$DatabaseName = "LinkReports"

##Initialize & Get-Revision Details 
$PATH = "C:\SVN\TASER SQl Scripts"
cd $PATH
svn info $PATH
$error.Clear()
[xml] $RevisionList = svn log --verbose --xml -r $RevisionToGet

# Get all files commited in Revision
$RevisionFileList = $RevisionList.log.logentry.paths.path | %{$_.InnerText}
#$RevisionFileList.Count # Is it more than 1 file
# Who committed it
$SVNCommitUser = $RevisionList.log.logentry.author
$SVNCommitDate = $RevisionList.log.logentry.date
$SVNCommitDateFormatted =  $SVNCommitDate.Replace("Z","").Replace("T", " ").Substring(0,23)

Write-Host "Number of Files in Revision: " $RevisionFileList.Count $SVNCommitUser " " $SVNCommitDate # Is it more than 1 file

$RevisionFileList | ForEach-Object { $outputFile = Split-Path $_ -leaf                                   
                                     [string] $FileContent = get-content $outputFile -Raw
                                     $CleanFileContent =  $FileContent.Replace("GO", "") 
                                     
                                     #For each file get the ReportSubscription Skeys & EmailSubject
                                     $FilewithPath = $PATH + "\" + $outputFile
                                     $EmailSubject =  $outputFile.Replace("TASER_", "").Replace(".sql","")

                                     #Assume for now that there are more than one TASER per file
                                     #This will be changed
                                     $ReportSubscriptionSKeyLines = @()
                                     #$ReportSubscriptionSKeyLines.Count
                                     get-content $outputFile | select-string -Pattern "DECLARE" -AllMatches |select-string -Pattern "@ReportSubscriptionSKey" -AllMatches | Foreach { 
                                        $ReportSubscriptionSKeyLines += $_
                                        }
                                      # Deploy TASERs in File
                                    try{
                                        $DeployResult = Invoke-DbaSqlQuery -SqlInstance $SqlServer -Database $DatabaseName -Query $FileContent -ErrorAction Stop 
                                     }catch{
                                        Write-Host "TASER Deployment Error"
                                        $error
                                        $error.Clear()
                                     }
                                     for ($i=0; $i -le $ReportSubscriptionSKeyLines.Count-1 ; $i++) {
                                           [string] $ReportSubscriptionSKeyLine = $ReportSubscriptionSKeyLines[$i]
                                            #$ReportSubscriptionSKeyLine.GetType()
                                            #$ReportSubscriptionSKeyDeclaration =  $ReportSubscriptionSKeyLine.Substring(0, $ReportSubscriptionSKeyLine.IndexOf("--")-1)
                                            if ($ReportSubscriptionSKeyLine.Contains("--")){
                                                $ReportSubscriptionSKeyDeclaration =  $ReportSubscriptionSKeyLine.Substring(0, $ReportSubscriptionSKeyLine.IndexOf("--"))
                                            }else{$ReportSubscriptionSKeyDeclaration = $ReportSubscriptionSKeyLine}

                                            $SubNumber = $ReportSubscriptionSKeyDeclaration.Replace("DECLARE", "").Replace("@ReportSubscriptionSKey", "").Replace(" INT", "").Replace("=","").Replace(" ","")
                                            if ($SubNumber.Contains("NULL")  ){
                                                $NewSubNumberSQL = "SELECT top 1 ReportSubscriptionSKey,EmailSubject, ReportOutputName from LinkReports.dbo.ReportSubscriptions WHERE EmailSubject = '$EmailSubject' AND  SVNRevisionNo is NULL  ORDER BY ReportSubscriptionSkey DESC"
                                                $NewSubNumber = Invoke-DbaSqlQuery -SqlInstance $SqlServer -Database $DatabaseName -Query $NewSubNumberSQL -InformationVariable $Info -MessagesToOutput  -OutVariable $O1 -ErrorVariable $ErrorMsg -WarningVariable $WarningMsg 
                                                try{
                                                    $NewSubNumber = Invoke-DbaSqlQuery -SqlInstance $SqlServer -Database $DatabaseName -Query $NewSubNumberSQL -InformationVariable $Info -MessagesToOutput  -OutVariable $O1 -ErrorVariable $ErrorMsg -WarningVariable $WarningMsg 
                                                    Write-Host "New TASER created: " $NewSubNumber.Item(0) : $NewSubNumber.Item(1) 
                                                    $MyTestSub = $NewSubNumber.Item(0)
                                                    }catch{
                                                        Write-Host "Error getting new Subscription number"
                                                    }
                                                
                                            }
                                             else { Write-Host "Updated $SubNumber" 
                                                    $MyTestSub = $SubNumber  
                                                   }
                                            # Update the SVN Revision details in ReportSubscriptions
                                            
                                            $UpdateSVNDetailsSQL = "UPDATE LinkReports.dbo.ReportSubscriptions SET SVNRevisionNo = $RevisionToGet, SVNCommitDate = '" + $SVNCommitDate.Substring(0,23).Replace("T"," ") + "' , SVNCommitUser = '$SVNCommitUser' WHERE ReportSubscriptionSKey = $MyTestSub"
                                            try{
                                                 $result = Invoke-DbaSqlQuery -SqlInstance $SqlServer  -Database "LinkReports" -Query $UpdateSVNDetailsSQL -Verbose -MessagesToOutput  
                                                }catch{
                                                Write-Host "Issue" 
                                                $error
                                                $error.Clear()
                                                }
                                              }
                                     }



Function TASER-Test {
(Param $SVNRevisionNo, Param $TestOption  )
if(!$TestOption ){
  $TestOption = 2
  }
# Get all ReportSubscriptionSkeys in file

# Run a test for each one
 $RunDate = Get-Date -Format 'yyyy-MM-dd hh:mm:ss'
 $ExecSPSQL = "DECLARE @ReportSubSKeyList varchar(8000) = '$MyTestSub'
                 DECLARE @UseTestOption tinyint = $TestOption
                 DECLARE @RC int
                 EXECUTE @RC = [dbo].[RunTaserSubscriptionList]  @ReportSubSKeyList, @UseTestOption
                 SELECT @RC"

 $CheckLogSQL = "SELECT top 1 * FROM LinkReports.dbo.ReportSubscriptionsLog WHERE ReportSubscriptionSKey = $MyTestSub AND StartTime >= '$RunDate' ORDER BY Starttime DESC"
 try{
     $result = Invoke-DbaSqlQuery -SqlInstance $SqlServer -Database "LinkReports" -Query $ExecSPSQL -Verbose -MessagesToOutput  
   }catch{ Write-Host "Error in testing $MyTestSub"
           $error
           $error.Clear()
   } 
# Get The Result
 $TASERRunResult = Invoke-DbaSqlQuery -SqlInstance $SqlServer -Database "LinkReports" -Query $CheckLogSQL -Verbose -MessagesToOutput  
  if (!$TASERRunResult ){
             Write-Host "No Log"
     }else{
        switch($TASERRunResult.ReturnedValue)  {
              1 {Write-Host "Successfully tested $MyTestSub";break}
             -1 {Write-Host "Test execution for $MyTestSub is Still running";break }
        default {Write-Host "Post Deployment Test of $MyTestSub Failed with error below";$TASERRunResult.Result;break}
       } #End of switch   
     } #End of TASERRunResult test
}                  