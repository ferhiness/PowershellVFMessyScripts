New-JiraSession

$JIRAAddComment = '`n' #Start Blank

$Revisions =    22734, 22524,22521
#21927,  21928, 21929, 21930, 21931, 21933, 21934, 21935, 21936, 21937, 21938, 22051, 22052,       22054, 22129, 22130, 22131, 22133, 22134, 22135, 22136, 22137, 22139, 22147, 22148, 22152,       22153, 22154,22171,  22172, 22174, 22175, 22183, 22184, 22185,22204,22205,22206,22207

$JIRANumber = "INFO-27702"
$SqlServer = "PRDLGDWRS1"
$DatabaseName = "LinkReports"
$TestOption = 2


$PATH = "C:\SVN\TASER SQl Scripts"
cd $PATH
#Update svn 
svn update 
svn info $PATH

foreach ($RevisionToGet in  $Revisions){
  svn update
  svn info $PATH
  $error.Clear()
  [xml] $RevisionList = svn log --verbose --xml -r $RevisionToGet
  $RevisionFileList = $RevisionList.log.logentry.paths.path | Where-Object -Property 'action' -NE 'D' | %{$_.InnerText}
  $SVNCommitUser = $RevisionList.log.logentry.author
  $SVNCommitDate = $RevisionList.log.logentry.date
  $SVNCommitDateFormatted =  $SVNCommitDate.Replace("Z","").Replace("T", " ").Substring(0,23)
  $JIRADeploymentComment = "Deployed TASErs for Revision $RevisionToGet`n"
  Write-Host "Number of Files in Revision " $RevisionToGet " :"   $RevisionFileList.Count $SVNCommitUser " " $SVNCommitDate # Is it more than 1 file

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

                                    #Only 1 TASER per file allowed. Multiples need to be sent back for splitting
                                     if ($ReportSubscriptionSKeyLines.Count > 1 ){
                                        $DeploymentIssue = "$outputFile contains multiple Subscriptions that need to be split "
                                        Write-Host -ForegroundColor Red $DeploymentIssue
                                        Write-Host "Number of subscriptions in file is "  $ReportSubscriptionSKeyLines.Count -ForegroundColor Red -BackgroundColor White
                                        break
                                    }
                                      # Deploy TASERs in File
                                    try{
                                        $DeployResult = 0
                                        Write-Host "Deploying $FilewithPath"
                                        #$DeployResult = Invoke-DbaSqlQuery -SqlInstance $SqlServer -Database $DatabaseName -Query $CleanFileContent -ErrorAction Stop 
                                         if ($ReportSubscriptionSKeyLines.Count -gt 1 ){
                                         $DeployResult = Invoke-DbaQuery -SqlInstance $SqlServer -Database $DatabaseName -File $FilewithPath -ErrorVariable DeployError -MessagesToOutput }
                                         else{
                                         $DeployResult = Invoke-DbaQuery -SqlInstance $SqlServer -Database $DatabaseName -Query $CleanFileContent -ErrorAction Stop -ErrorVariable DeployError
                                         }
                                         #$DeployResult = Invoke-DbaSqlQuery -SqlInstance $SqlServer -Database $DatabaseName -File $outputFile -ErrorVariable DeployError -MessagesToOutput 
                                         #Invoke-DbaSqlQuery -SqlInstance $SqlServer -Database $DatabaseName -Query $FileContent -ErrorVariable DeployError -MessagesToOutput 

                                     }catch{
                                        Write-Host "TASER Deployment Error" 
                                        $error
                                        $DeployError
                                        $error.Clear()
                                     }
                                     for ($i=0; $i -le $ReportSubscriptionSKeyLines.Count-1 ; $i++) {
                                           [string] $ReportSubscriptionSKeyLine = $ReportSubscriptionSKeyLines[$i]
                                            #$ReportSubscriptionSKeyLine.GetType()
                                            #$ReportSubscriptionSKeyDeclaration =  $ReportSubscriptionSKeyLine.Substring(0, $ReportSubscriptionSKeyLine.IndexOf("--")-1)
                                            if ($ReportSubscriptionSKeyLine.Contains("--")){
                                                $ReportSubscriptionSKeyDeclaration =  $ReportSubscriptionSKeyLine.Substring(0, $ReportSubscriptionSKeyLine.IndexOf("--"))
                                            }else{$ReportSubscriptionSKeyDeclaration = $ReportSubscriptionSKeyLine}

                                            $SubNumber = $ReportSubscriptionSKeyDeclaration.Replace("DECLARE", "").Replace("@ReportSubscriptionSKey", "").Replace("INT", "").Replace("=","").Replace(" ","").Replace("`t","")
                                            if ($SubNumber.ToUpper().Contains("NULL")  ){
                                                $NewSubNumberSQL = "SELECT top 1 ReportSubscriptionSKey,EmailSubject, ReportOutputName from LinkReports.dbo.ReportSubscriptions WHERE EmailSubject = '$EmailSubject' AND  SVNRevisionNo is NULL  ORDER BY ReportSubscriptionSkey DESC"
                                               # $NewSubNumber = Invoke-DbaSqlQuery -SqlInstance $SqlServer -Database $DatabaseName -Query $NewSubNumberSQL -InformationVariable Info -MessagesToOutput  -OutVariable O1 -ErrorVariable ErrorMsg -WarningVariable WarningMsg 
                                                try{
                                                    $NewSubNumber = Invoke-DbaQuery -SqlInstance $SqlServer -Database $DatabaseName -Query $NewSubNumberSQL -InformationVariable Info -MessagesToOutput  -OutVariable O1 -ErrorVariable ErrorMsg -WarningVariable WarningMsg 
                                                    Write-Host "New TASER created: " $NewSubNumber.Item(0) : $NewSubNumber.Item(1) 
                                                    $MyTestSub = $NewSubNumber.Item(0)
                                                    $JIRADeploymentComment = $JIRADeploymentComment + "`n $MyTestSub : $EmailSubject"
                                                    }catch{
                                                        Write-Host "Error getting new Subscription number"
                                                    }
                                                
                                            }
                                             else { Write-Host "Updated $SubNumber" 
                                                    $Enabled = 0
                                                    $MyTestSub = $SubNumber  
                                                    $EnabledSQL = "SELECt Enabled FROM LinkReports.dbo.ReportSubscriptions WHERE ReportSubscriptionSKey = $MyTestSub" 
                                                    $Enabled =  Invoke-DbaQuery -SqlInstance $SqlServer  -Database "LinkReports" -Query $EnabledSQL -Verbose -MessagesToOutput  
                                                    
                                                    $JIRADeploymentComment = $JIRADeploymentComment + "`n $SubNumber : $EmailSubject"
                                                   }
                                            # Update the SVN Revision details in ReportSubscriptions
                                            
                                            $UpdateSVNDetailsSQL = "UPDATE LinkReports.dbo.ReportSubscriptions SET SVNRevisionNo = $RevisionToGet, SVNCommitDate = '" + $SVNCommitDate.Substring(0,23).Replace("T"," ") + "' , SVNCommitUser = '$SVNCommitUser' WHERE ReportSubscriptionSKey = $MyTestSub"
                                            try{
                                                 $result = Invoke-DbaQuery -SqlInstance $SqlServer  -Database "LinkReports" -Query $UpdateSVNDetailsSQL -Verbose -MessagesToOutput  
                                                }catch{
                                                Write-Host "Issue" 
                                                $error
                                                $error.Clear()
                                                }

                                            if ($Enabled.Enabled){
                                             # Test all ReportSubscriptionSkeys in file
                                             $RunDate = Get-Date -Format 'yyyy-MM-dd hh:mm:ss'
                                             $ExecSPSQL = "DECLARE @ReportSubSKeyList varchar(8000) = '$MyTestSub'
                                                            DECLARE @UseTestOption tinyint = $TestOption
                                                            DECLARE @RC int
                                                            EXECUTE @RC = [dbo].[RunTaserSubscriptionList]  @ReportSubSKeyList, @UseTestOption
                                                            SELECT @RC"
            
                                            if ($TestOption -ne 0){
                                               $CheckLogSQL = "SELECT top 1 * FROM LinkReports.dbo.ReportSubscriptionsTestLog WHERE ReportSubscriptionSKey = $MyTestSub AND StartTime >= '$RunDate' ORDER BY Starttime DESC"
                                             }else{
                                                $CheckLogSQL = "SELECT top 1 * FROM LinkReports.dbo.ReportSubscriptionsLog WHERE ReportSubscriptionSKey = $MyTestSub AND StartTime >= '$RunDate' ORDER BY Starttime DESC"
                                             }
                                            
                                             try{
                                                $result = Invoke-DbaQuery -SqlInstance $SqlServer -Database "LinkReports" -Query $ExecSPSQL -Verbose -MessagesToOutput  
                                               }catch{ Write-Host "Error in testing $MyTestSub"
                                                      $error
                                                      $error.Clear()
                                               } 
                                             #Wait a bit 
                                             Start-Sleep -Seconds 5
                                             $TASERRunResult = Invoke-DbaQuery -SqlInstance $SqlServer -Database "LinkReports" -Query $CheckLogSQL -Verbose -MessagesToOutput  
                                              if (!$TASERRunResult ){
                                                        Write-Host "No Log"
                                                }else{
                                                   switch($TASERRunResult.ReturnedValue)  {
                                                         1 {Write-Host "Successfully tested $MyTestSub";break}
                                                        -1 {Write-Host "Test execution for $MyTestSub is Still running";break }
                                                   default {Write-Host "Post Deployment Test of $MyTestSub Failed with error below";$TASERRunResult.Result;break}
                                                  } #End of switch   
                                                } #End of TASERRunResult test
                                           } #Only Test Subs that are enabled
                                           else { Write-Host "Not testing $MyTestSub"}
                                        } #End of for each ReportSubscriptionSKey
                                     } #End of for each file in RevisionList
}

$JIRAIssue = Get-JiraIssue -Key $JIRANumber
foreach ($JIRAComment in $JIRAIssue.Comment){ if ( $JIRAComment.Body -match $RevisionToGet ){$ReassignUser = $JIRAComment.UpdateAuthor} }
$ReassignUser
$TASERCnt = $TASERObjs.Count

# Add table 
$JIRATable =  $TASERObjs|  Format-Jira RevisionNo, ReportSubSkey, EmailSubject 
$JIRAAddComment = $JIRAAddComment + "Deployed $TASERCnt  TASERs for Revisions $Revisions $AdditionalComments `n"  +$JIRATable 


# Ending
$JIRADeploymentComment = $JIRAAddComment + "`n`nKindest Regards,`n" + (Get-ADUser -Identity $env:username).Name + "`n`nCC:[~"+$ReassignUser.Name + "]"
$JIRADeploymentComment 
$JIRADeploymentComment2 = 
"{color:#d04437}  {color}
" + $JIRADeploymentComment 

Add-JiraIssueComment -Issue  $JIRANumber -Comment $JIRADeploymentComment                

$DS = GET-Date -Format O

$TimeSpent = New-TimeSpan -Minutes ( 5 * $TASERObjs.Count)

Add-JiraIssueWorklog -Issue $JIRANumber -Comment "Deployed and tested TASERs" -DateStarted ($DS) -TimeSpent $TimeSpent

Set-JiraIssue -Issue $JIRANumber -Assignee $ReassignUser.Name
