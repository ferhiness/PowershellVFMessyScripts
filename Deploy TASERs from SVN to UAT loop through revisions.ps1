
$TASERObjs = New-Object -TypeName 'System.Collections.ArrayList';

$Revisions =   22617, 22726
#PRODO  INFO-26088  22560 , 22574, 22562,22544 #,  22543,22589, 22588,   22586, 22547, 22552, 22553 
#PRODB2 INFO-26088 22604, 22509, 22558, 22559, 22512, 22513, 22514, 22526, 22605 # 22602, 22564, 22565, 22578, 22521, 22524 
#PRODA1 INFO-26088 22499  # 22554, 22502, 22584, 22593, 22498 

#PRODO   INFO-26088 22560,22574,22562,22544 #,22543,22586,22589,22607,22547,22552,22553
#PRODB2  INFO-26088 22604,22509,22558,22559,22512,22513,22514,22602,22564,22565,22617,22526,22605,22521,22524
#PRODA1	 INFO-26088 22499,22554,22502,22584,22593,22498 

$AdditionalComments = ' '

$SqlServer = "LGHBDVDB06"
$DatabaseName = "LinkReports"
$TestOption = 2
#region Initialize & Get-Revision Details 
$PATH = "C:\SVN\TASER SQl Scripts"
cd $PATH
#Update svn 
svn update 
svn info $PATH
#svn  cleanup


foreach ($RevisionToGet in  $Revisions){

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

#First check all filename match email Subject  and Fail otherwise

$RevisionFileList | 
ForEach-Object { $outputFile = Split-Path $_ -leaf                                   
                  [string] $FileContent = get-content $outputFile -Raw
                  $CleanFileContent =  $FileContent.Replace("GO", "") 
                  
                  #For each file get the ReportSubscription Skeys & EmailSubject
                  $FilewithPath = $PATH + "\" + $outputFile
                  $EmailSubject =  $outputFile -replace "TASER_", ""  -replace ".sql","" #$outputFile.Replace("TASER_", "").Replace(".sql","").Trim()
                  $EmailSubjectMatches = 0
                  #Assume for now that there are more than one TASER per file
                  #This will be changed
                  $ReportSubscriptionSKeyLines = @()
                  $EmailSubjectinFileLine
                  #$ReportSubscriptionSKeyLines.Count
                  get-content $outputFile | select-string -Pattern "DECLARE" -AllMatches |select-string -Pattern "@ReportSubscriptionSKey" -AllMatches | Foreach { 
                     $ReportSubscriptionSKeyLines += $_
                     }
                  if ($ReportSubscriptionSKeyLines.Count > 1 ){
                    $DeploymentIssue = "$outputFile contains multiple Subscriptions that need to be split "
                     Write-Host -ForegroundColor Red $DeploymentIssue
                     Write-Host "Number of subscriptions in file is "  $ReportSubscriptionSKeyLines.Count -ForegroundColor Red -BackgroundColor White
                     break
                 }
                 

                  get-content $outputFile | select-string -Pattern "DECLARE" -AllMatches |select-string -Pattern "@EmailSubject" -AllMatches | Foreach { 
                    [string]  $CurrentSubject = $_
                      $EmailSubjectinFileLine=  $CurrentSubject.SubString($CurrentSubject.IndexOf("=")+1, $CurrentSubject.Length-($CurrentSubject.IndexOf("=")+1)).Replace("'","").Trim() 
                      if ( ($EmailSubjectinFileLine.CompareTo($EmailSubject) -eq  0 ) -or ($EmailSubject -eq $EmailSubjectinFileLine)  ){ $EmailSubjectMatches = 1
                      } else{
                       Write-Host "FileName `n$EmailSubject & Subject line `n$EmailSubjectinFileLine do not match" 
                      break}
                          
                      }
                      if ( $EmailSubjectMatches -ne 1){  break} #No point proceeding with other TASERS
                     
                    
                    # Deploy TASERs in File
                  try{
                      $DeployResult = 0
                      Write-Host "Deploying $FilewithPath"
                      if ($ReportSubscriptionSKeyLines.Count -gt 1 ){
                      $DeployResult = Invoke-DbaQuery -SqlInstance $SqlServer -Database $DatabaseName -File $outputFile -ErrorVariable DeployError -MessagesToOutput }
                      else{
                      $DeployResult = Invoke-DbaQuery -SqlInstance $SqlServer -Database $DatabaseName -Query $CleanFileContent -ErrorAction Stop -ErrorVariable DeployError
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
                          $Enabled = 0
                         [string] $ReportSubscriptionSKeyLine = $ReportSubscriptionSKeyLines[$i]
                          #$ReportSubscriptionSKeyLine.GetType()
                          #$ReportSubscriptionSKeyDeclaration =  $ReportSubscriptionSKeyLine.Substring(0, $ReportSubscriptionSKeyLine.IndexOf("--")-1)
                          if ($ReportSubscriptionSKeyLine.Contains("--")){
                              $ReportSubscriptionSKeyDeclaration =  $ReportSubscriptionSKeyLine.Substring(0, $ReportSubscriptionSKeyLine.IndexOf("--"))
                          }else{$ReportSubscriptionSKeyDeclaration = $ReportSubscriptionSKeyLine}

                          $SubNumber = $ReportSubscriptionSKeyDeclaration.Replace("DECLARE", "").Replace("@ReportSubscriptionSKey", "").Replace("INT", "").Replace("=","").Replace(" ","").Replace("`t","")
                          
                          if ($SubNumber.ToUpper().Contains("NULL")  ){
                              $NewSubNumberSQL = "SELECT top 1 ReportSubscriptionSKey,EmailSubject,Enabled, ReportOutputName,CASE WHEN ISNULL(FileoutputDir,'') = '' THEN 'Email' ELSE 'File' END As FileDestination `nfrom LinkReports.dbo.ReportSubscriptions WHERE EmailSubject = '$EmailSubject' AND  SVNRevisionNo is NULL `nORDER BY ReportSubscriptionSkey DESC"
                              
                              try{
                                  $NewSubNumber = Invoke-DbaQuery -SqlInstance $SqlServer -Database $DatabaseName -Query $NewSubNumberSQL -InformationVariable VarInfo -MessagesToOutput  -OutVariable VarOut -ErrorVariable ErrorMsg -WarningVariable WarningMsg 
                                  Write-Host "New TASER created: " $NewSubNumber.ReportSubscriptionSKey : $NewSubNumber.EmailSubject  
                                  $MyTestSub = $NewSubNumber.ReportSubscriptionSKey
                                  $Enabled = $NewSubNumber.Enabled
                                  $TASERDestination = $NewSubNumber.FileDestination
                                  }catch{
                                      Write-Host "Error getting new Subscription number"
                                      $VarInfo 
                                      $VarOut
                                      $ErrorMsg
                                      $WarningMsg 
                                  }   
                          }
                           else { $MyTestSub = $SubNumber  
                                  Write-Host "Updated $SubNumber $MyTestSub" 
                                  $GetTASERSQL = "SELECt Enabled,EmailSubject,CASE WHEN ISNULL(FileoutputDir,'') = '' THEN 'Email' ELSE 'File' END As FileDestination FROM LinkReports.dbo.ReportSubscriptions WHERE ReportSubscriptionSKey = $MyTestSub"  
                                  $TASERDEtails =  Invoke-DbaQuery -SqlInstance $SqlServer  -Database "LinkReports" -Query $GetTASERSQL -Verbose -MessagesToOutput  
                                  $Enabled = $TASERDEtails.Enabled
                                  $TASERDestination = $TASERDEtails.FileDestination
                                  
                                 }
                            
                          $TASERObj | Add-Member -MemberType NoteProperty -Name RevisionNo -Value   $RevisionToGet                         
                          $TASERObj | Add-Member -MemberType NoteProperty -Name ReportSubSkey -Value   $MyTestSub                         
                          $TASERObj | Add-Member -MemberType NoteProperty -Name Enabled -Value  $Enabled
                          $TASERObj | Add-Member -MemberType NoteProperty -Name EmailSubject -Value   $EmailSubjectinFileLine
                          
                          $TASERObj | Add-Member -MemberType NoteProperty -Name FileName -Value  $outputFile
                          $TASERObj | Add-Member -MemberType NoteProperty -Name Comments -Value $AdditionalComments 
                          Write-Host "$RevisionToGet $MyTestSub $Enabled $outputFile "
                        #  $TASERSKeys.Add( $MyTestSub)

                          $UpdateSVNDetailsSQL = "UPDATE LinkReports.dbo.ReportSubscriptions SET SVNRevisionNo = $RevisionToGet, SVNCommitDate = '" + $SVNCommitDate.Substring(0,23).Replace("T"," ") + "' , SVNCommitUser = '$SVNCommitUser' WHERE ReportSubscriptionSKey = $MyTestSub"
                          try{
                               $result = Invoke-DbaQuery -SqlInstance $SqlServer  -Database "LinkReports" -Query $UpdateSVNDetailsSQL -Verbose -MessagesToOutput  
                              }catch{
                              Write-Host "Issue" 
                              $error
                              $error.Clear()
                              }

                          # Test all ReportSubscriptionSkeys in file
                          $RunDate = Get-Date -Format 'yyyy-MM-dd hh:mm:ss'
                          Write-Host "TASERDestination is $TASERDestination  "
                          if($TASERDestination.Equals('File')){ 
                             $TestOption  =  -($TestOption ) 
                             Write-Host "RunDate $RunDate Destination is File $TestOption"
                           } 

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
                          if ($Enabled){  #($Enabled.Enabled){
                            Write-Host "$MyTestSub Enabled $Enabled"
                            try{
                                  $result = Invoke-DbaQuery -SqlInstance $SqlServer -Database "LinkReports" -Query $ExecSPSQL -Verbose -MessagesToOutput  -ErrorVariable Errvar
                                  #Wait a bit 
                                  Start-Sleep -Seconds 5
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
                        
                         #$TASERObjs += $TASERObj
                         [void] $TASERObjs.Add($TASERObj)
      
                     } #End of For each Sub
                   }

}

$JIRATable =  $TASERObjs|  Format-Jira RevisionNo, ReportSubSkey, EmailSubject, Enabled #, Comments
$JIRAComment = "Deployed TASErs for Revision`n"  +$JIRATable 
 
 $TASERObjs.Count
