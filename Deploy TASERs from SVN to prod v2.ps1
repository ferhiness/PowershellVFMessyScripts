####################################################################################  
## Deploy TASERs from SVN to prod
## 2018-12-30  V.Fernandes   Initial attempts to automate TASEr deployment
## 2019-01-09  V.Fernandes   
####################################################################################  

# This is prod Don't 
Return "This is a pro script"
#Login to JIRA
#Set-JiraConfigServer "https://jira/"
#Get-JiraConfigServer

New-JiraSession 
###########################################
Invoke-DbaQuery -SqlInstance PRDLGDWRS1 -Database LinkReports -Query "IF EXISTS (select * from LinkReports.dbo.ReportSubscriptionsTestLog )
BEGIN
      TRUNCATE TABLE LinkReports.dbo.ReportSubscriptionsTestLog
END"

###########################################
#region  Function Declarations

$RevisionToGet = 23613  
$JIRANumber = "INFO-29237"
$SqlServer = "PRDLGDWRS1"
$DatabaseName = "LinkReports"
$TestOption = 2
$MyTestSub = ""

#region Initialize & Get-Revision Details 
$PATH = "\\AUKBMEDC01\Group\Shared\VNessa\SVN\TASER SQl Scripts"
cd $PATH

#Update svn 
svn update
svn info $PATH
$error.Clear()
[xml] $RevisionList = svn log --verbose --xml -r $RevisionToGet

 

# Get all files commited in Revision

$RevisionFileList = $RevisionList.log.logentry.paths.path | Where-Object -Property 'action' -NE 'D' | %{$_.InnerText}
#$RevisionFileList.Count # Is it more than 1 file
# Who committed it
$SVNCommitUser = $RevisionList.log.logentry.author
$SVNCommitDate = $RevisionList.log.logentry.date
$SVNCommitDateFormatted =  $SVNCommitDate.Replace("Z","").Replace("T", " ").Substring(0,23)
$JIRADeploymentComment = "Deployed TASERs for Revision $RevisionToGet`n"

if( $RevisionFileList.GetType().Name -eq 'String'){
    Write-Host 'Single file in Revision '
}else {
    Write-Host "Number of Files in Revision " $RevisionToGet " :"   $RevisionFileList.Count $SVNCommitUser " " $SVNCommitDate # Is it more than 1 file
    # First Check if the revision contains more than X TASERS
    $RevisionFileList.Count
    if ($RevisionFileList.Count -gt $WarningCount ){
        Write-Host -ForegroundColor Yellow  "***Large revision warning:- " $RevisionFileList.Count " files"
    Write-Host ""
    }
}

$RevisionFileList | ForEach-Object { $outputFile = Split-Path $_ -leaf                                   
                                     [string] $FileContent = get-content $outputFile -Raw
                                     #$CleanFileContent =  $FileContent.Replace("GO", "") 
                                     $CleanFileContent =  $FileContent -replace "\bGO\b", "" 

                                     #For each file get the ReportSubscription Skeys & EmailSubject
                                     $FilewithPath = $PATH + "\" + $outputFile
                                     $EmailSubject =  $outputFile -replace "TASER_", ""  -replace ".sql",""  #$outputFile.Replace("TASER_", "").Replace(".sql","")
                                     #Assume for now that there are more than one TASER per file
                                     #This will be changed
                                     $ReportSubscriptionSKeyLines = @()
                                     #$ReportSubscriptionSKeyLines.Count
                                     get-content $outputFile | select-string -Pattern "DECLARE" -AllMatches |select-string -Pattern "@ReportSubscriptionSKey" -AllMatches | Foreach { 
                                        $ReportSubscriptionSKeyLines += $_
                                        }
                                      # Deploy TASERs in File

                                     for ($i=0; $i -le $ReportSubscriptionSKeyLines.Count-1 ; $i++) {
                                           [string] $ReportSubscriptionSKeyLine = $ReportSubscriptionSKeyLines[$i]
                                             if ($ReportSubscriptionSKeyLine.Contains("--")){
                                                  $ReportSubscriptionSKeyDeclaration =  $ReportSubscriptionSKeyLine.Substring(0, $ReportSubscriptionSKeyLine.IndexOf("--"))

                                              }elseif($ReportSubscriptionSKeyLine.Contains("/*")){$ReportSubscriptionSKeyDeclaration = $ReportSubscriptionSKeyLine.Substring(0, $ReportSubscriptionSKeyLine.IndexOf("/*")) 
                                              } else{$ReportSubscriptionSKeyDeclaration = $ReportSubscriptionSKeyLine}
                                             #Actual Deploying here
                                             try{
                                                $DeployResult = 0
                                                #$DeployResult = Invoke-DbaQuery -SqlInstance $SqlServer -Database $DatabaseName -Query $CleanFileContent -ErrorAction Stop 
                                                 if ($ReportSubscriptionSKeyLines.Count -gt 1 ){
                                                   Write-Host "more than 1 TASER in $FilewithPath" -ForegroundColor Red -BackgroundColor White
                                                   break;
                                                    #$DeployResult = Invoke-DbaQuery -SqlInstance $SqlServer -Database $DatabaseName -File $FilewithPath -ErrorVariable DeployError -MessagesToOutput 
                                                    }
                                                 else{
                                                     Write-Host "Deploying $FilewithPath"
                                                    $DeployResult = Invoke-DbaQuery -SqlInstance $SqlServer -Database $DatabaseName -Query $CleanFileContent -ErrorAction Stop -ErrorVariable DeployError -Verbose
                                                 }
                                             }catch{
                                                Write-Host "TASER Deployment Error" 
                                                $error
                                                $DeployError
                                                $error.Clear()
                                             }
                                            $SubNumber = $ReportSubscriptionSKeyDeclaration.Replace("DECLARE", "").Replace("@ReportSubscriptionSKey", "").Replace("INT", "").Replace("=","").Replace(" ","").Replace("`t","")
                                            if ($SubNumber.ToUpper().Contains("NULL")  ){
                                                $NewSubNumberSQL = "SELECT top 1 ReportSubscriptionSKey,EmailSubject, ReportOutputName from LinkReports.dbo.ReportSubscriptions WHERE EmailSubject = '$EmailSubject' AND  SVNRevisionNo is NULL  ORDER BY ReportSubscriptionSkey DESC"
                                                try{
                                                    $NewSubNumber = Invoke-DbaQuery -SqlInstance $SqlServer -Database $DatabaseName -Query $NewSubNumberSQL -InformationVariable Info -MessagesToOutput  -OutVariable O1 -ErrorVariable ErrorMsg -WarningVariable WarningMsg 
                                                    Write-Host "New TASER created: " $NewSubNumber.Item(0) : $NewSubNumber.Item(1) 
                                                    $MyTestSub = $NewSubNumber.Item(0)
                                                    $JIRADeploymentComment = $JIRADeploymentComment + "`n $MyTestSub : $EmailSubject"
                                                    }catch{
                                                        Write-Host "Error getting new Subscription number $Info" 
                                                   }
                                            }
                                             else { 
                                                    #Added this check because Mindtree sometimes out the UAT subscription number in the script & leave it there  so updates come in as new TASErs with large sub numbers
                                                    $ExpectedSubscriptionNumberSQL = 'SELECT ISNULL(MAX(ReportSubscriptionSkey),0) + 1  As NextExpectedRSkey FROM [LinkReports].[dbo].[ReportSubscriptions]'
                                                    $ExpectedSubscriptionNumber = (Invoke-DbaQuery -SqlInstance $SqlServer  -Database "LinkReports" -Query $ExpectedSubscriptionNumberSQL).NextExpectedRSkey


                                                    if ($ExpectedSubscriptionNumber -lt [convert]::ToInt32($SubNumber) ){
                                                         Write-Color -BackGroundColor Red -Color White  "Expected Subscription Number  $ExpectedSubscriptionNumber file contains  $SubNumber "
                                                         break
                                                    }

                                                    Write-Host "Updated $SubNumber" 
                                                    $Enabled = 0
                                                    $MyTestSub = $SubNumber 

                                                    $JIRADeploymentComment = $JIRADeploymentComment + "`n $SubNumber : $EmailSubject"
                                                   }

                                            #Check if it is enabled or not. Disabled is mostly for existing TASERs 
                                            $EnabledSQL = "SELECt Enabled FROM LinkReports.dbo.ReportSubscriptions WHERE ReportSubscriptionSKey = $MyTestSub" 
                                            $Enabled =  Invoke-DbaQuery -SqlInstance $SqlServer  -Database "LinkReports" -Query $EnabledSQL -Verbose -MessagesToOutput  
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
                                             $ExecSPSQL = " DECLARE @ReportSubSKeyList varchar(8000) = '$MyTestSub'
                                                            DECLARE @UseTestOption int = $TestOption
                                                            DECLARE @RC int
                                                            EXECUTE @RC = [dbo].[RunTaserSubscriptionList]  @ReportSubSKeyList, @UseTestOption
                                                            SELECT @RC"


                                            if ($TestOption -ne 0){
                                               $CheckLogSQL = "SELECT top 1 * FROM LinkReports.dbo.ReportSubscriptionsTestLog WHERE ReportSubscriptionSKey = $MyTestSub AND StartTime >= '$RunDate' ORDER BY Starttime DESC"
                                             }else{
                                                $CheckLogSQL = "SELECT top 1 * FROM LinkReports.dbo.ReportSubscriptionsLog WHERE ReportSubscriptionSKey = $MyTestSub AND StartTime >= '$RunDate' ORDER BY Starttime DESC"
                                             }


                                             try{
                                                $RunDate = Get-Date -Format 'yyyy-MM-dd hh:mm:ss'
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

#Get-Command -Module JiraPS
#Invoke-DbaQuery -SqlInstance $SqlServer -Database LinkReports -Query "SELECT ReportSubscriptionSkey,ReturnedValue, Result FROM  LinkReports.dbo.ReportSubscriptionsTestLog"

#$JIRANumber = "INFO-23887"

$JIRAAdditinalComment = " "
$JIRADeploymentComment = $JIRADeploymentComment + "`n`nKindest Regards,`n" + (Get-ADUser -Identity $env:username).Name
#$JIRADeploymentComment 

$JIRAIssue = Get-JiraIssue -Key $JIRANumber 

foreach ($JIRAComment in $JIRAIssue.Comment){ if ( $JIRAComment.Body -match $RevisionToGet ){$ReassignUser = $JIRAComment.UpdateAuthor} }
$ReassignUser

if (!$ReassignUser ) { $ReassignUser =  $JIRAComment.UpdateAuthor}

#$JIRAIssue.Reporter.name
#$JIRAIssue.customfield_10177.name

$CurrentlyAssignedUser = $JIRAIssue.Assignee
$CCUserList = ''
if ( $JIRAComment.Body -match $RevisionToGet -and $JIRAComment.Body -match 'CC:' ){ 
      $Pos = $JIRAComment.Body.IndexOf('CC:',[System.StringComparison]::CurrentCultureIgnoreCase ) +3; $Len = $JIRAComment.Body.Length
      $CCUserList = $JIRAComment.Body.Substring( $Pos ,$Len-$Pos ) }
$CCUserList

if (!$CCUserList ) { $CCUserList =  $JIRAComment.UpdateAuthor}

if ($CurrentlyAssignedUser.Name -ne $ReassignUser.Name  ){
   $JIRADeploymentComment = $JIRADeploymentComment + "`nCC:[~"+$ReassignUser.Name + "]"
}

# $JIRADeploymentComment = $JIRADeploymentComment + ",[~" + $JIRAIssue.Reporter.name + "]"
# $JIRADeploymentComment = $JIRADeploymentComment + ",[~" + $JIRAIssue.customfield_10177.name + "]"

if($CCUserList ){
   $JIRADeploymentComment = $JIRADeploymentComment+ ',' + $CCUserList
}

$JIRADeploymentComment

#$JIRADeploymentComment = $JIRADeploymentComment.Replace('.','')
# $JIRADeploymentComment =  $JIRADeploymentComment + "`n`n"+ 'PS: Thou TASERs have been deployed, the report /Operations Reporting/Data integrity reports/Compliance - Members with a Personal Contribution Aged 75 Years and Older  will likely need to have performance improvements to avoid Timeout failures'
Add-JiraIssueComment -Issue  $JIRANumber -Comment $JIRADeploymentComment                
$DS = GET-Date -Format O
#$DS  = '2019-12-16T14:36:58.4606164+11:00'
# $TimeSpent2 = New-TimeSpan -Hours 2 -Minutes 45
#$TimeSpent = $TimeSpent2
#$TimeSpent = New-TimeSpan -Minutes 30

$TimeSpent = New-TimeSpan -Minutes   ( 15 * $TASERObjs.Count)
if ( $TimeSpent.TotalMinutes -lt 1){Write-host "Issue logging JIRA Time $TimeSpent.TotalMinutes "}
else {
    Add-JiraIssueWorklog -Issue $JIRANumber -Comment "Deployed and tested TASERs " -DateStarted ($DS) -TimeSpent $TimeSpent 
    Set-JiraIssue -Issue $JIRANumber -Assignee $ReassignUser.Name 
}

$D =  ( (GET-Date ).AddHours(-3).AddDays(3) -Format O )
$D.ToUniversalTime()  -Format O 

#$env:UserName
#Set-JiraIssue -Issue $JIRANumber -Assignee $ReassignUser.Name 

$EmailSubject.Length
$EmailSubjectinFileLine.Length

$EmailSubject -eq $EmailSubjectinFileLine
$EmailSubjectinFileLine.CompareTo($EmailSubject)

$Try1 =  $TASERObjs[0] 

 foreach( $TASERObj in $TASERObjs ){ $TASERObj.RevisionNo.ToString()+ ' ' +  $TASERObj.ReportSubSkey+ ' ' + $TASERObj.EmailSubject+ ' ' + $TASERObj.FileName }



