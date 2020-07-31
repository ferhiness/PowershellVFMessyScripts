$TASERObjs = @()
#region  Function Declarations
$RevisionToGet = 22149 #21927  
$JIRANumber = "INFO-22073"
$SqlServer = "LGHBDVDB06"
$DatabaseName = "LinkReports"
$TestOption = 2



#region Initialize & Get-Revision Details 
$PATH = "C:\SVN\TASER SQl Scripts"
cd $PATH
#Update svn 
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

Write-Host "Number of Files in Revision " $RevisionToGet " :"   $RevisionFileList.Count $SVNCommitUser " " $SVNCommitDate # Is it more than 1 file
[string] $TASERSKeyList = ""

#$TASERSKeys =  @()
$TASERSKeys = New-Object -TypeName 'System.Collections.ArrayList';

$RevisionFileList | 
ForEach-Object { $outputFile = Split-Path $_ -leaf                                   
                  [string] $FileContent = get-content $outputFile -Raw
                  $CleanFileContent =  $FileContent.Replace("GO", "") 
                  
                  #For each file get the ReportSubscription Skeys & EmailSubject
                  $FilewithPath = $PATH + "\" + $outputFile
                  $EmailSubject =  $outputFile.Replace("TASER_", "").Replace(".sql","").Trim()
                  $EmailSubjectMatches = 0
                  #Assume for now that there are more than one TASER per file
                  #This will be changed
                  $ReportSubscriptionSKeyLines = @()
                  $EmailSubjectinFileLine
                  #$ReportSubscriptionSKeyLines.Count
                  get-content $outputFile | select-string -Pattern "DECLARE" -AllMatches |select-string -Pattern "@ReportSubscriptionSKey" -AllMatches | Foreach { 
                     $ReportSubscriptionSKeyLines += $_
                     }

                  get-content $outputFile | select-string -Pattern "DECLARE" -AllMatches |select-string -Pattern "@EmailSubject" -AllMatches | Foreach { 
                    [string]  $CurrentSubject = $_
                      $EmailSubjectinFileLine=  $CurrentSubject.SubString($CurrentSubject.IndexOf("=")+1, $CurrentSubject.Length-($CurrentSubject.IndexOf("=")+1)).Replace("'","").Trim() 
                      if ($EmailSubjectinFileLine.CompareTo($EmailSubject) -eq  0){ $EmailSubjectMatches = 1
                      } else{
                       Write-Host "FileName $EmailSubject & Subject line do not match" 
                      break}
                          
                      }
                      if ( $EmailSubjectMatches -ne 1){  break}
                     
                    
                    # Deploy TASERs in File

                  try{
                      $DeployResult = 0
                      Write-Host "Deploying $FilewithPath"
                      if ($ReportSubscriptionSKeyLines.Count -gt 1 ){
                      $DeployResult = Invoke-DbaSqlQuery -SqlInstance $SqlServer -Database $DatabaseName -File $outputFile -ErrorVariable DeployError -MessagesToOutput }
                      else{
                      $DeployResult = Invoke-DbaSqlQuery -SqlInstance $SqlServer -Database $DatabaseName -Query $CleanFileContent -ErrorAction Stop -ErrorVariable DeployError
                      }
                      #$DeployResult = Invoke-DbaSqlQuery -SqlInstance $SqlServer -Database $DatabaseName -File $outputFile -ErrorVariable DeployError -MessagesToOutput 
                      #Invoke-DbaSqlQuery -SqlInstance $SqlServer -Database $DatabaseName -Query $FileContent -ErrorVariable DeployError -MessagesToOutput 
                       
                   }catch{
                      Write-Host "TASER Deployment Error"
                      $error
                      $DeployError
                      $InfoVar
                      $error.Clear()
                   }
                   

                   for ($i=0; $i -le $ReportSubscriptionSKeyLines.Count-1 ; $i++) {
                          $TASERObj = New-Object -TypeName psobject 
                         [string] $ReportSubscriptionSKeyLine = $ReportSubscriptionSKeyLines[$i]
                          #$ReportSubscriptionSKeyLine.GetType()
                          #$ReportSubscriptionSKeyDeclaration =  $ReportSubscriptionSKeyLine.Substring(0, $ReportSubscriptionSKeyLine.IndexOf("--")-1)
                          if ($ReportSubscriptionSKeyLine.Contains("--")){
                              $ReportSubscriptionSKeyDeclaration =  $ReportSubscriptionSKeyLine.Substring(0, $ReportSubscriptionSKeyLine.IndexOf("--"))
                          }else{$ReportSubscriptionSKeyDeclaration = $ReportSubscriptionSKeyLine}

                          $SubNumber = $ReportSubscriptionSKeyDeclaration.Replace("DECLARE", "").Replace("@ReportSubscriptionSKey", "").Replace("INT", "").Replace("=","").Replace(" ","").Replace("`t","")
                          $TASERObj | Add-Member -MemberType NoteProperty -Name RevisionNo -Value   $RevisionToGet                         
                          $TASERObj | Add-Member -MemberType NoteProperty -Name ReportSubSkey -Value   $SubNumber                         
                          $TASERObj | Add-Member -MemberType NoteProperty -Name EmailSubject -Value   $EmailSubjectinFileLine
                          $TASERObj | Add-Member -MemberType NoteProperty -Name FileName -Value  $outputFile
                          $TASERObjs += $TASERObj
                          
                          if ($SubNumber.ToUpper().Contains("NULL")  ){
                              $NewSubNumberSQL = "SELECT top 1 ReportSubscriptionSKey,EmailSubject, ReportOutputName `nfrom LinkReports.dbo.ReportSubscriptions WHERE EmailSubject = '$EmailSubject' AND  SVNRevisionNo is NULL `nORDER BY ReportSubscriptionSkey DESC"
                              
                              try{
                                  $NewSubNumber = Invoke-DbaSqlQuery -SqlInstance $SqlServer -Database $DatabaseName -Query $NewSubNumberSQL -InformationVariable VarInfo -MessagesToOutput  -OutVariable VarOut -ErrorVariable ErrorMsg -WarningVariable WarningMsg 
                                  Write-Host "New TASER created: " $NewSubNumber.Item(0) : $NewSubNumber.Item(1) 
                                  $MyTestSub = $NewSubNumber.Item(0)
                                  }catch{
                                      Write-Host "Error getting new Subscription number"
                                      $VarInfo 
                                      $VarOut
                                      $ErrorMsg
                                      $WarningMsg 
                                  }
                              
                          }
                           else { Write-Host "Updated $SubNumber" 
                                  $MyTestSub = $SubNumber  
                                 }
                          # Update the SVN Revision details in ReportSubscriptions
                          $TASERSKeyList = $TASERSKeyList + ',' + $MyTestSub
                          #$TASERSKeys += $MyTestSub
                          $TASERSKeys.Add( $MyTestSub)

                          $UpdateSVNDetailsSQL = "UPDATE LinkReports.dbo.ReportSubscriptions SET SVNRevisionNo = $RevisionToGet, SVNCommitDate = '" + $SVNCommitDate.Substring(0,23).Replace("T"," ") + "' , SVNCommitUser = '$SVNCommitUser' WHERE ReportSubscriptionSKey = $MyTestSub"
                          try{
                               $result = Invoke-DbaSqlQuery -SqlInstance $SqlServer  -Database "LinkReports" -Query $UpdateSVNDetailsSQL -Verbose -MessagesToOutput  
                              }catch{
                              Write-Host "Issue" 
                              $error
                              $error.Clear()
                              }

                          # Test all ReportSubscriptionSkeys in file
                          $RunDate = Get-Date -Format 'yyyy-MM-dd hh:mm:ss'
                          $ExecSPSQL = "DECLARE @ReportSubSKeyList varchar(8000) = '$MyTestSub'
                                          DECLARE @UseTestOption tinyint = $TestOption
                                          DECLARE @RC int
                                          EXECUTE @RC = [dbo].[RunTaserSubscriptionList]  @ReportSubSKeyList, @UseTestOption
                                          SELECT @RC"
            
                          if ($TestOption -ne 0){
                              $CheckLogSQL = "SELECT top 1 * FROM LinkReports.dbo.ReportSubscriptionsTestLog `nWHERE ReportSubscriptionSKey = $MyTestSub AND StartTime >= '$RunDate' `nORDER BY Starttime DESC"
                          }else{
                              $CheckLogSQL = "SELECT top 1 * FROM LinkReports.dbo.ReportSubscriptionsLog `nWHERE ReportSubscriptionSKey = $MyTestSub AND StartTime >= '$RunDate' `nORDER BY Starttime DESC"
                          }
                          
                          try{
                              $result = Invoke-DbaSqlQuery -SqlInstance $SqlServer -Database "LinkReports" -Query $ExecSPSQL -Verbose -MessagesToOutput  
                            }catch{ Write-Host "Error in testing $MyTestSub"
                                    $error
                                    $error.Clear()
                            } 

                          #Wait a bit 
                          Start-Sleep -Seconds 1

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
                   }

Write-Host "Total TASERS Deployed and Tested " $TASERObjs.Count
$TASERObjs

<#
$CheckTASERLogSQL = "SELECT * FROM LinkReports.dbo.ReportSubscriptionsLog WHERE ReportSubscriptionSKey IN (" + $MyTestSub -join "," + " ) AND StartTime >= '$RunDate' ORDER BY Starttime DESC"
$TASERRunResult = Invoke-DbaSqlQuery -SqlInstance $SqlServer -Database "LinkReports" -Query $CheckTASERLogSQL -Verbose -MessagesToOutput                   
$CheckTASERLogSQL

Get-Command -Module JiraPS

Get-JiraIssueComment $JIRANumber

"7264 "
#>