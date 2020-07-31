###### UAT   
###########################################
Invoke-DbaQuery -SqlInstance lghbdvdb06 -Database LinkReports -Query "IF EXISTS (select * from LinkReports.dbo.ReportSubscriptionsTestLog )
BEGIN
      TRUNCATE TABLE LinkReports.dbo.ReportSubscriptionsTestLog
END"
###########################################
$TASERObjs = New-Object -TypeName 'System.Collections.ArrayList';

#region  Function Declarations
$RevisionToGet =  23613 #22490#22489#22488#22487  #21927  
$JIRANumber = "INFO-29237"
$SqlServer = "LGHBDVDB06"
$DatabaseName = "LinkReports"
$TestOption = 2
$WarningCount = 10
$HardCodedEnvironmentString = "DECLARE @ReportServerEnvironmentCode [varchar](20) = 'PRODRO2016_SSRS'"

#region Initialize & Get-Revision Details 
$PATH = "\\AUKBMEDC01\Group\Shared\VNessa\SVN\TASER SQl Scripts"

cd $PATH
#Update svn 
## Cleanup locks svn cleanup
svn update 
svn info $PATH
$error.Clear()
[xml] $RevisionList = svn log --verbose --xml -r $RevisionToGet 
# Get all files commited in Revision
$RevisionFileList = $RevisionList.log.logentry.paths.path | Where-Object -Property 'action' -NE 'D'   | %{$_.InnerText}
#$RevisionFileList.Count # Is it more than 1 file
# Who committed it
$SVNCommitUser = $RevisionList.log.logentry.author
$SVNCommitDate = $RevisionList.log.logentry.date
$SVNCommitDateFormatted =  $SVNCommitDate.Replace("Z","").Replace("T", " ").Substring(0,23)
[string] $TASERSKeyList = ""
if( $RevisionFileList.GetType().Name -eq 'String'){
    Write-Output 'Single file in Revision '
}else {
    Write-Host "Number of Files in Revision : $RevisionToGet  "  $RevisionFileList.Count $SVNCommitUser   $SVNCommitDate # Is it more than 1 file
    # First Check if the revision contains more than X TASERS
    $RevisionFileList.Count
    if ($RevisionFileList.Count -gt $WarningCount ){
        Write-Host -ForegroundColor Yellow  "***Large revision warning:- " $RevisionFileList.Count " files"
    Write-Host ""
    }
}

$TASERSKeys = New-Object -TypeName 'System.Collections.ArrayList';
$RevisionFileList | 
ForEach-Object { $outputFile = Split-Path $_ -leaf                                   
                  [string] $FileContent = get-content $outputFile -Raw
                  $CleanFileContent =  $FileContent -replace "\bGO\b", "" 
                  #For each file get the ReportSubscription Skeys & EmailSubject
                  $EmailSubjectinFileLine =  ''
                  $EmailSubject = ''
                  $FilewithPath = $PATH + "\" + $outputFile
                  $EmailSubject =  $outputFile -replace "TASER_", ""  -replace ".sql",""  #$outputFile.Replace("TASER_", "").Replace("Taser_","").Replace(".sql","").Trim()
                  $EmailSubjectMatches = 0

                  #Assume for now that there are more than one TASER per file
                  #This will be changed
                  $ReportSubscriptionSKeyLines = @()
                  $EmailSubjectinFileLine
                  #$ReportSubscriptionSKeyLines.Count
                  get-content $outputFile | select-string -Pattern "DECLARE" -AllMatches |select-string -Pattern "@ReportSubscriptionSKey" -AllMatches | Foreach { 
                     $ReportSubscriptionSKeyLines += $_
                     }

                 Write-Host "Number of subscriptions in file is "  $ReportSubscriptionSKeyLines.Count
                 if ($ReportSubscriptionSKeyLines.Count > 1 ){
                    $DeploymentIssue = "$outputFile contains multiple Subscriptions that need to be split "
                     Write-Host -ForegroundColor Red $DeploymentIssue
                     break
                 }
                 #TODO  if( $FileContent -contains $HardCodedEnvironmentString)
                  get-content $outputFile | select-string -Pattern "DECLARE" -AllMatches |select-string -Pattern "@EmailSubject" -AllMatches | Foreach { 
                    [string]  $CurrentSubject = $_
                      $EmailSubjectinFileLine=  $CurrentSubject.SubString($CurrentSubject.IndexOf("=")+1, $CurrentSubject.Length-($CurrentSubject.IndexOf("=")+1)).Replace("'","").Trim() 
                      if ( ($EmailSubjectinFileLine.CompareTo($EmailSubject) -eq  0 ) -or ($EmailSubject -eq $EmailSubjectinFileLine)  ){ $EmailSubjectMatches = 1
                      } else{
                        $DeploymentIssue = "FileName & Subject line mismatch `n$EmailSubject`n$EmailSubjectinFileLine do not match.`nPlease return JIRA $JIRANumber to DEV Team" 
                        Write-Host -ForegroundColor Red $DeploymentIssue
                      break}
                      }
                      if ( $EmailSubjectMatches -ne 1){ 
                       Write-Host "Issue in file $outputFile`n$DeploymentIssue"
                       break} #No point proceeding with other TASERS

                    # Deploy TASERs in File
                  try{ $DeployResult = 0
                       Write-Host "Deploying $FilewithPath"
                      if ($ReportSubscriptionSKeyLines.Count -gt 1 ){
                        $DeployResult = Invoke-DbaQuery -SqlInstance $SqlServer -Database $DatabaseName -File $outputFile -ErrorVariable DeployError -MessagesToOutput }
                      else{
                        $DeployResult = Invoke-DbaQuery -SqlInstance $SqlServer -Database $DatabaseName -Query $CleanFileContent -ErrorAction Stop -ErrorVariable DeployError
                      }
                      #$DeployResult = Invoke-DbaSqlQuery -SqlInstance $SqlServer -Database $DatabaseName -File $outputFile -ErrorVariable DeployError -MessagesToOutput 
                      #Invoke-DbaSqlQuery -SqlInstance $SqlServer -Database $DatabaseName -Query $FileContent -ErrorVariable DeployError -MessagesToOutput 
                   }catch{
                      Write-Host -ForegroundColor Red "TASER Deployment Error"
                      $error
                      $DeployError
                      $InfoVar
                      $error.Clear()
                   }

                   for ($i=0; $i -le $ReportSubscriptionSKeyLines.Count-1 ; $i++) {
                          $TASERObj = New-Object -TypeName psobject 
                         [string] $ReportSubscriptionSKeyLine = $ReportSubscriptionSKeyLines[$i]

                          #$ReportSubscriptionSKeyDeclaration =  $ReportSubscriptionSKeyLine.Substring(0, $ReportSubscriptionSKeyLine.IndexOf("--")-1)
                          if ($ReportSubscriptionSKeyLine.Contains("--")){
                              $ReportSubscriptionSKeyDeclaration =  $ReportSubscriptionSKeyLine.Substring(0, $ReportSubscriptionSKeyLine.IndexOf("--"))
                          }elseif($ReportSubscriptionSKeyLine.Contains("/*")){$ReportSubscriptionSKeyDeclaration = $ReportSubscriptionSKeyLine.Substring(0, $ReportSubscriptionSKeyLine.IndexOf("/*")) 
                          } else{$ReportSubscriptionSKeyDeclaration = $ReportSubscriptionSKeyLine}

                          $SubNumber = $ReportSubscriptionSKeyDeclaration.Replace("DECLARE", "").Replace("@ReportSubscriptionSKey", "").Replace("INT", "").Replace("=","").Replace(" ","").Replace("`t","")
                          if ($SubNumber.ToUpper().Contains("NULL")  ){
                              $NewSubNumberSQL = "SELECT top 1 ReportSubscriptionSKey,EmailSubject, ReportOutputName `nfrom LinkReports.dbo.ReportSubscriptions WHERE EmailSubject = '$EmailSubject' AND  SVNRevisionNo is NULL `nORDER BY ReportSubscriptionSkey DESC"

                              try{
                                  $NewSubNumber = Invoke-DbaQuery -SqlInstance $SqlServer -Database $DatabaseName -Query $NewSubNumberSQL -InformationVariable VarInfo -MessagesToOutput  -OutVariable VarOut -ErrorVariable ErrorMsg -WarningVariable WarningMsg 
                                  Write-Host "New TASER created: " $NewSubNumber.Item(0) : $NewSubNumber.Item(1) 
                                  $MyTestSub = $NewSubNumber.Item(0)
                                  #$EnabledSQL = "SELECt Enabled FROM LinkReports.dbo.ReportSubscriptions WHERE ReportSubscriptionSKey = $MyTestSub" 
                                  $NewSubDetailsSQL = "SELECT Enabled, CASE WHEN ISNULL(FileoutputDir,'') = '' THEN 'Email' ELSE 'File' END As FileDestination FROM LinkReports.dbo.ReportSubscriptions WHERE ReportSubscriptionSKey = $MyTestSub" 
                                  }catch{
                                      Write-Host "Error getting new Subscription number"
                                      $VarInfo 
                                      $VarOut
                                      $ErrorMsg
                                      $WarningMsg 
                                  }
                          }
                           else { Write-Host "Updated $SubNumber" 
                                  $Enabled = 0
                                  $MyTestSub = $SubNumber  
                                  #$EnabledSQL = "SELECt Enabled FROM LinkReports.dbo.ReportSubscriptions WHERE ReportSubscriptionSKey = $MyTestSub" 
                                  $NewSubDetailsSQL = "SELECT Enabled, CASE WHEN ISNULL(FileoutputDir,'') = '' THEN 'Email' ELSE 'File' END As FileDestination FROM LinkReports.dbo.ReportSubscriptions WHERE ReportSubscriptionSKey = $MyTestSub" 

                                  #$Enabled =  Invoke-DbaQuery -SqlInstance $SqlServer  -Database "LinkReports" -Query $EnabledSQL -Verbose -MessagesToOutput  
                                  $NewSub = Invoke-DbaQuery -SqlInstance $SqlServer  -Database $DatabaseName -Query $NewSubDetailsSQL -Verbose -MessagesToOutput
                                  $Enabled = $NewSub.Enabled
                                  $TASERDestination = $NewSub.FileDestination
                                 }

                          #$EnabledSQL = "SELECt Enabled FROM LinkReports.dbo.ReportSubscriptions WHERE ReportSubscriptionSKey = $MyTestSub" 
                          $NewSubDetailsSQL = "SELECT Enabled, CASE WHEN ISNULL(FileoutputDir,'') = '' THEN 'Email' ELSE 'File' END As FileDestination, FileoutputDir  FROM LinkReports.dbo.ReportSubscriptions WHERE ReportSubscriptionSKey = $MyTestSub" 
                          $NewSub = Invoke-DbaQuery -SqlInstance $SqlServer  -Database $DatabaseName -Query $NewSubDetailsSQL -Verbose -MessagesToOutput

                          #$Enabled =  Invoke-DbaQuery -SqlInstance $SqlServer  -Database "LinkReports" -Query $EnabledSQL -Verbose -MessagesToOutput  
                          $Enabled = $NewSub.Enabled
                          $TASERDestination = $NewSub.FileDestination    
                          $FileoutputDir =  $NewSub.FileoutputDir
                          ################If File we need to check folder Permissions
                          if($TASERDestination.Equals('File')){ 
                               $TestOption  =  -($TestOption )  
                          #      $ServiceAccount = 'APAC\SQL_LGHBDB02_svc'
                          #      $permission = (Get-Acl $FileoutputDir  -ErrorAction SilentlyContinue).Access | ?{$_.IdentityReference -match $ServiceAccount} | Select IdentityReference,FileSystemRights
                          #      if(!$permission){Write-Host "No permissions for $ServiceAccount on $FileoutputDir"}
                           }    

                          $TASERObj | Add-Member -MemberType NoteProperty -Name RevisionNo -Value   $RevisionToGet                         
                          $TASERObj | Add-Member -MemberType NoteProperty -Name ReportSubSkey -Value   $MyTestSub                         
                          $TASERObj | Add-Member -MemberType NoteProperty -Name Enabled -Value  $Enabled
                          $TASERObj | Add-Member -MemberType NoteProperty -Name EmailSubject -Value   $EmailSubjectinFileLine
                          $TASERObj | Add-Member -MemberType NoteProperty -Name FileName -Value  $outputFile

                          #$TASERSKeys += $MyTestSub
                          $TASERSKeys.Add( $MyTestSub)
                          $UpdateSVNDetailsSQL = "UPDATE LinkReports.dbo.ReportSubscriptions SET SVNRevisionNo = $RevisionToGet, SVNCommitDate = '" + $SVNCommitDate.Substring(0,23).Replace("T"," ") + "' , SVNCommitUser = '$SVNCommitUser' WHERE ReportSubscriptionSKey = $MyTestSub"
                          try{
                               $result = Invoke-DbaQuery -SqlInstance $SqlServer  -Database "LinkReports" -Query $UpdateSVNDetailsSQL -Verbose -MessagesToOutput  
                              }catch{
                              Write-Host "Issue" 
                              $error
                              $error.Clear()
                              }

                          # Test all ReportSubscriptionSkeys in file
                          $ExecSPSQL = 
                          "DECLARE @ReportSubSKeyList varchar(8000) = '$MyTestSub'
                           DECLARE @UseTestOption int = $TestOption
                           DECLARE @RC int
                           EXECUTE @RC = [dbo].[RunTaserSubscriptionList]  @ReportSubSKeyList, @UseTestOption
                           SELECT @RC"
        
                          if ($TestOption -ne 0){
                              $CheckLogSQL = "SELECT top 1 * FROM LinkReports.dbo.ReportSubscriptionsTestLog `nWHERE ReportSubscriptionSKey = $MyTestSub AND StartTime >= '$RunDate' `nORDER BY Starttime DESC"
                          }else{
                              $CheckLogSQL = "SELECT top 1 * FROM LinkReports.dbo.ReportSubscriptionsLog `nWHERE ReportSubscriptionSKey = $MyTestSub AND StartTime >= '$RunDate' `nORDER BY Starttime DESC"
                          }
                          if ($Enabled){
                            try{
                                  $RunDate = Get-Date -Format 'yyyy-MM-dd hh:mm:ss'
                                  $result = Invoke-DbaQuery -SqlInstance $SqlServer -Database "LinkReports" -Query $ExecSPSQL -Verbose -MessagesToOutput  -ErrorVariable Errvar
                                  #Wait a bit 
                                  Start-Sleep -Seconds 15
                                   $TASERRunResult = Invoke-DbaQuery -SqlInstance $SqlServer -Database "LinkReports" -Query $CheckLogSQL -Verbose -MessagesToOutput  
                                   $TASERObj | Add-Member -MemberType NoteProperty -Name TestReturnedValue -Value  $TASERRunResult.ReturnedValue
                                   $TASERObj | Add-Member -MemberType NoteProperty -Name TestResult -Value  $TASERRunResult.Result
                                  if (!$TASERRunResult ){
                                      Write-Host "No Log"
                                    }else{
                                      switch($TASERRunResult.ReturnedValue)  {
                                       1 {Write-Host "Successfully tested $MyTestSub";break}
                                      -1 {Write-Host "Test execution for $MyTestSub is Still running";break }
                                 default {Write-Host "Post Deployment Test of $MyTestSub Failed with error below";$TASERRunResult.Result;break}
                                         } #End of switch   
                                 } #End of TASERRunResult test
                              }catch{ Write-Host "Error in testing $MyTestSub"
                                    $error
                                    $Errvar
                                    $error.Clear()
                             } 
                          } #Only Test Subs that are enabled
                         else { Write-Host "Not testing $MyTestSub"
                            $TASERObj | Add-Member -MemberType NoteProperty -Name TestReturnedValue -Value 0
                            $TASERObj | Add-Member -MemberType NoteProperty -Name TestResult -Value ''
                          }
                         [void] $TASERObjs.Add($TASERObj)
                     } #End of For each Sub
                     if ( $EmailSubjectMatches -ne 1){ 
                       Write-Host "Issue in file $outputFile`n$DeploymentIssue"
                       break} #No point proceeding with other TASERS
                   }


#  $TimeSpent = New-TimeSpan -Minutes  30
#  Add-JiraIssueWorklog -Issue "INFO-29237" -Comment "Pre Deployment checks " -DateStarted ($DS) -TimeSpent $TimeSpent 
 
## Test
$A=  Invoke-DbaQuery -SqlInstance lghbdvdb06 -Database LinkReports -Query "SELECT ReportSubscriptionSkey,ReturnedValue, Result FROM  LinkReports.dbo.ReportSubscriptionsTestLog"
# $A[1].Result
$A.Result
$A.Count
$RevisionFileList.Count
Write-Host "Total TASERS Deployed "  $TASERObjs.Count  " and Tested " $TASERObjs.Where({$_.Enabled}).Count
$TASERObjs
$TASERObjs.Count
$TASERObjs.Where({$_.Enabled -eq $True })| Select ReportSubSkey, FileName
$TASERObjs.Where({$_.Enabled -eq $False })| Select ReportSubSkey, FileName
$TASERObjs| Select ReportSubSkey, Enabled, TestReturnedValue, FileName
$TASERObjs.Where({$_.RevisionNo -eq 22056}) | Select ReportSubSkey, Enabled, TestReturnedValue, FileName
$TASERObjs.Where({$_.TestReturnedValue -ne 1 -and $_.Enabled }) | Select RevisionNo,ReportSubSkey, TestReturnedValue, FileName
$TASERObjs |  Select RevisionNo, ReportSubSkey, EmailSubject   
<#
#$TASERObjs|  Select RevisionNo, ReportSubSkey, EmailSubject  | Format-Jira | Add-JiraIssueComment -Issue IT-51371

$JIRATable =  $TASERObjs|  Format-Jira RevisionNo, ReportSubSkey, EmailSubject 
$JIRAComment = "Deployed TASErs for Revision`n"  +$JIRATable 
Add-JiraIssueComment  -Comment  $JIRAComment -Issue IT-51371

<#

$TASERObjs
$CheckTASERLogSQL = "SELECT * FROM LinkReports.dbo.ReportSubscriptionsLog WHERE ReportSubscriptionSKey IN (" + $MyTestSub -join "," + " ) AND StartTime >= '$RunDate' ORDER BY Starttime DESC"
$TASERRunResult = Invoke-DbaSqlQuery -SqlInstance $SqlServer -Database "LinkReports" -Query $CheckTASERLogSQL -Verbose -MessagesToOutput                   
$CheckTASERLogSQL

Get-Command -Module JiraPS
Get-JiraIssueComment $JIRANumber
"7264 "

#Random Trials

$TASERObjs
$T = $TASERObjs | Format-Table 
$T.GetType() 
$TASERObjs.GetType()

$S = $TASERObjs | foreach {Format-Jira  -InputObject $_ }  | out-string

Format-Jira  -InputObject $TASERObj

$S.GetType() 
$S

$MyTestJira = Get-JiraIssue -Key "IT-50593"

Add-JiraIssueComment -Issue  $MyTestJira -Comment $S

#> 
#>
