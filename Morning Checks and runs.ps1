#####################################Morning Checks & runs #######################################

# 1. Rerun Failed TASERs
$TASERRerunList = Invoke-DbaQuery -SqlInstance prdlgdwrs1 -Database ReportServer -Query 'EXEC RerunFailedTASER'
#$RASERRerunList2nd = Invoke-DbaQuery -SqlInstance prdlgdwrs1 -Database ReportServer -Query 'EXEC RerunFailedTASER'
$RASERRerunList2nd.Column1
$TASERRerunList.Column1
$Path = '\\aaspafp01\public\a5. Resource Planning\6a Operations\Reporting\'
[bool]([System.Uri]$path).IsUnc
Test-Path $Path
#2. Rerun Failed Jobs if any

#3. Monitor for illegal Service account usage

Start-Job -Name 'IllegalAdhoc'  -ScriptBlock { 

Function Alert-AdhocServiceaccountQueryRuns {
    [CmdletBinding(SupportsShouldProcess = $True)]  
   Param(
       [Parameter(ValueFromPipeline,Mandatory)]  #ByPropertyName
          [Alias('ComputerName')]
        [string] $SqlInstance
    )
    begin{}
    process{
    $SQLGetAdhocUnauthorizedQueries = "select s.login_name,s.session_id, s.host_name As SourcePC, s.database_name QueryDatabase, collection_time As SessionDateTime, sql_text As Queryrun
                                        FROM [WarehouseTemp].dbo.monitor_jobsession s
                                        JOIN DBA_Metrics.[dbo].[RG_ExceptionList] E on (ExceptionType = 'Domain Service Account' OR  AccountID = 'ADS_Production' ) 
		                                        AND s.login_name = E.AccountID
                                        WHERE collection_time BETWEEN DATEADD(MI,-1,GETDATE()) AND GETDATE()
                                        --AND E.AccountID LIKE '%ADS%'
                                        AND s.[program_name] LIKE '%Microsoft SQL Server Management Studio - Query%'
                                        "
    $IllegalQueries = Invoke-DbaQuery -SqlInstance $SqlInstance -Database DBA_Metrics -Query  $SQLGetAdhocUnauthorizedQueries
  if($IllegalQueries )
  {
     $EmailBody = $IllegalQueries| Select login_name, session_id, SourcePC, QueryDatabase, SessionDateTime | ConvertTo-Html
      $smtpserver= 'smtp.linkgroup.corp'     
        $From = 'session_monitor@aas.com.au'
        $To = 'link.group.sql.server.dba@linkgroup.com'
        $BCC = 'vanessa.fernandes@aas.com.au'
        $smtp= 'smtp.linkgroup.corp' 
        $email = New-Object System.Net.Mail.MailMessage  
        $email.IsBodyHtml = $true
        $email.From = $From
        $email.To.Add( $To)
        $Email.Bcc.Add($BCC)
        $email.Subject = 'Adhoc Queries run as Service account detected'
        $email.Body =  $EmailBody 
        $smtp = new-object Net.Mail.SmtpClient($smtpserver) 
        $smtp.Send($email) 
     }
    }
    end{}

}

  $timeout2 = new-timespan -Minutes 3000
  $sw2 = [diagnostics.stopwatch]::StartNew()
  while ($sw2.elapsed -lt   $timeout2){
  Alert-AdhocServiceaccountQueryRuns -SqlInstance LGNRDB03 

   Start-Sleep -Seconds 30
  }

  }

  Get-Job -Id  20
  Stop-Job -Id 20
  #$session | Remove-PSSession

  Get-PSSession -ComputerName $env:COMPUTERNAME
 

#4. Monitor LGNRDB03 activity & kill adhoc sessions

#(New-TimeSpan –End “DATE TIME IN FUTURE”).TotalSeconds | Sleep;
$TimeNow= Get-Date 
$TimeNow.Day


Start-Job -Name 'Monitor_LGNRDB03'  -ScriptBlock { 

Function Get-ActiveSqlSessions {
   [CmdletBinding(SupportsShouldProcess = $True )]          
     Param(
         [Parameter(ValueFromPipeline)]  #ByPropertyName
          [Alias('ComputerName')]
        [string] $SqlInstance)
        if ($PSCmdlet.ShouldProcess($SqlInstance)){
           $ActiveSessions = Invoke-DbaQuery -SqlInstance $SqlInstance -Database WarehouseTemp -Query 'EXEC GetSessions2'
           Write-Verbose "Total sessions retrieved from $Sqlinstance : $($ActiveSessions.Count)" 
           return $ActiveSessions
        }
}

Function Get-SessionUserInfo{
   [CmdletBinding()]  
   Param(
        [Parameter(Mandatory=$True)]
        [Object]$Session
    )
    begin{}
    process{Write-Verbose "The session for user  $($Session.login_name) "  
          $SessionInfo = New-Object -TypeName psobject  
          if ($Session.login_name.Contains('\') )
           { $ADUserDomain =  $Session.login_name.Split("\")[0]
             $ADUserName =  $Session.login_name.Split("\")[1]
             $AD =  Get-ADUser -Identity   $ADUserName -Properties emailaddress
             $EmailAddress =  $AD.EmailAddress
             $GN =  $AD.GivenName
             $QuerySource = $Session.Source
             $EmailSubject = "Your $QuerySource on Warehouse prod"
             $AlternateSite =  if ($QuerySource.Equals('Report')) {'Please use  http://prdlgdwrs1/Reports'}
                                elseif ($QuerySource.Equals('Query')) {'Please run your query from PRDLGDWRODB1'}
             $EmailBody = "Hi $GN,`nCan you please run you $QuerySource  on DR instead.
             `n $AlternateSite
             `nKindest regards,`nVanessa"
              $SessionInfo | Add-Member -MemberType NoteProperty -Name GivenName -Value  $GN                         
              $SessionInfo | Add-Member -MemberType NoteProperty -Name ADUserName -Value   $ADUserName 
              $SessionInfo | Add-Member -MemberType NoteProperty -Name EmailSubject -Value $EmailSubject                         
              $SessionInfo | Add-Member -MemberType NoteProperty -Name EmailAddress -Value $EmailAddress
              $SessionInfo | Add-Member -MemberType NoteProperty -Name EmailBody -Value    $EmailBody
              return $SessionInfo
            }
    }
    end{}
}

Function Get-SessionsUserInfo{
   [CmdletBinding()]  
   Param(
        [Parameter(Mandatory=$True)]
        [Object[]]$Sessions
    )
    begin{}
    process{
        $SessionsUserInfo =  New-Object -TypeName 'System.Collections.ArrayList';
         foreach ($session in $sessions){
         $SessionID = $session.session_id
             Write-Host "The session $SessionID for user"  $Session.login_name
          $SessionInfo = New-Object -TypeName psobject  
           $GN = ""
           $ADUserName = $Session.login_name
           $QuerySource = $Session.Source
           $EmailSubject = "Your $QuerySource on Warehouse prod"
           $AlternateSite =  if ($QuerySource.Equals('Report')) {'Please use  http://prdlgdwrs1/Reports'}
                             elseif ($QuerySource.Equals('Query')) {'Please run your query from PRDLGDWRODB1'}

           $EmailBody = "Hi $GN,`nCan you please run you $QuerySource  on DR instead.
             `n $AlternateSite
             `nKindest regards,`nVanessa
             
             `nFor SessionID $SessionID"

          if ($Session.login_name.Contains('\') )
           { $ADUserDomain =  $Session.login_name.Split("\")[0]
             $ADUserName =  $Session.login_name.Split("\")[1]
             $AD =  Get-ADUser -Identity   $ADUserName -Properties emailaddress
             $EmailAddress =  $AD.EmailAddress
             $GN =  $AD.GivenName
          }
              $SessionInfo | Add-Member -MemberType NoteProperty -Name GivenName    -Value  $GN                         
              $SessionInfo | Add-Member -MemberType NoteProperty -Name ADUserName   -Value  $ADUserName 
              $SessionInfo | Add-Member -MemberType NoteProperty -Name EmailSubject -Value  $EmailSubject                         
              $SessionInfo | Add-Member -MemberType NoteProperty -Name EmailAddress -Value  $EmailAddress
              $SessionInfo | Add-Member -MemberType NoteProperty -Name EmailBody    -Value  $EmailBody
              $SessionsUserInfo.Add( $SessionInfo)
              return $SessionsUserInfo
            }
    }
    end{}
}

Function Alert-AdhocServiceaccountQueryRuns {
    [CmdletBinding(SupportsShouldProcess = $True)]  
   Param(
       [Parameter(ValueFromPipeline,Mandatory)]  #ByPropertyName
          [Alias('ComputerName')]
        [string] $SqlInstance
    )
    begin{}
    process{
    $SQLGetAdhocUnauthorizedQueries = "select s.host_name As SourcePC, s.database_name QueryDatabase, collection_time As SessionDateTime, sql_text As Queryrun
                                        FROM [WarehouseTemp].dbo.monitor_jobsession s
                                        JOIN DBA_Metrics.[dbo].[RG_ExceptionList] E on (ExceptionType = 'Domain Service Account' OR  AccountID = 'ADS_Production' ) 
		                                        AND s.login_name = E.AccountID
                                        WHERE collection_time BETWEEN DATEADD(MI,-5,GETDATE()) AND GETDATE()
                                        AND E.AccountID LIKE '%ADS%'
                                        AND s.[program_name] LIKE '%Microsoft SQL Server Management Studio - Query%'
                                        "
    $IllegalQueries = Invoke-DbaQuery -SqlInstance $SqlInstance -Database DBA_Metrics -Query  $SQLGetAdhocUnauthorizedQueries

     $EmailBody = $IllegalQueries| Select  SourcePC, QueryDatabase, SessionDateTime | ConvertTo-Html


      $smtpserver= 'smtp.linkgroup.corp'     
        $From = 'session_monitor@aas.com.au'
        $To = 'vanessa.fernandes@aaas.com.au'
        $BCC = 'vanessa.fernandes@aas.com.au'
        $smtp= 'smtp.linkgroup.corp' 
        $email = New-Object System.Net.Mail.MailMessage  
        $email.IsBodyHtml = $true
        $email.From = $From
        $email.To.Add( $To)
        $Email.Bcc.Add($BCC)
        $email.Subject = 'Adhoc Queries run as Service account detected'
        $email.Body =  $EmailBody 
        $smtp = new-object Net.Mail.SmtpClient($smtpserver) 
        $smtp.Send($email) 


    }
    end{}

}

#Get-SessionUserInfo -Session $Session

Function Contact-SessionUser {
  [CmdletBinding(SupportsShouldProcess = $True)]  
   Param(
        [Parameter(Mandatory=$True)]
        [Object]$SessionUser
    )
    begin{}
    process{
    if ($PSCmdlet.ShouldProcess($SessionUser.EmailAddress,"User "+$SessionUser.ADUserName +" will be contacted via email "))
    {
      $smtpserver= 'smtp.linkgroup.corp'     
        $From = 'info_requests@aas.com.au'
        $To = $SessionUser.EmailAddress
        $BCC = 'vanessa.fernandes@aas.com.au'
        $smtp= 'smtp.linkgroup.corp' 
        $email = New-Object System.Net.Mail.MailMessage  
        $email.From = $From
        $email.To.Add( $To)
        $Email.Bcc.Add($BCC)
        $email.Subject = $SessionUser.EmailSubject
        $email.Body = $SessionUser.EmailBody
        $smtp = new-object Net.Mail.SmtpClient($smtpserver) 
        $smtp.Send($email) 
       }
    }
    end{}
}


Function Terminate-Session{
 [CmdletBinding(SupportsShouldProcess = $True )]          
     Param(
        [Parameter(ValueFromPipeline,Mandatory)]  #ByPropertyName
          [Alias('ComputerName')]
        [string] $SqlInstance,
         [Parameter(ValueFromPipeline,Mandatory)] 
         [string] $sessionID

         )
         begin{}
         process{
          if($PSCmdlet.ShouldProcess($SqlInstance, "Terminating User's SQLSession $sessionID")){
            Write-Host "Attempting to kill SQL session $sessionID on $SqlInstance"
            $KillQuery = "kill $sessionID"
            $KillResult = Invoke-DbaQuery -SqlInstance $SqlInstance -Database master -Query $KillQuery
            return $KillResult 
          }
         }
         end{}
}
#TAKE THIS OUT


  $timeout = new-timespan -Minutes 800
  $sw = [diagnostics.stopwatch]::StartNew()
  while ($sw.elapsed -lt $timeout){
    $now = Get-Date
    Write-Host $now

        $S = Get-ActiveSqlSessions -SqlInstance LGNRDB03 -Verbose
        if ($S ){
            foreach ($session in $S){
            $SU = Get-SessionUserInfo -Session $session 
            Write-Verbose "$($SU.EmailAddress)  for session $($session.session_id)" -Verbose
            Contact-SessionUser -SessionUser $SU 
            $SId = $Session.session_id
            Terminate-Session -SqlInstance LGNRDB03 -sessionID $SId 
            }
        }
    Start-Sleep -Seconds 120
  }
 }

 

 Get-Job -Id 18 | Receive-Job
 #Stop-Job -id 20
 
$Job = Get-Job -Id 7
$Job.Command
#Get-PSSession | Where-Object State -Like Closed | Remove-PSSession

Get-ADuser -Identity 'sql_LGNRDB02_svc' -Properties *
Get-ADUser -Server 'aas.priv' -Identity 'rptcrnusr' -Properties * | Select AccountExpirationDate, Accountexpires

