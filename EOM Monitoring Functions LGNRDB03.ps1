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
             Write-Host "The session for user"  $Session.login_name
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
              $SessionInfo | Add-Member -MemberType NoteProperty -Name GivenName    -Value  $GN                         
              $SessionInfo | Add-Member -MemberType NoteProperty -Name ADUserName   -Value  $ADUserName 
              $SessionInfo | Add-Member -MemberType NoteProperty -Name EmailSubject -Value  $EmailSubject                         
              $SessionInfo | Add-Member -MemberType NoteProperty -Name EmailAddress -Value  $EmailAddress
              $SessionInfo | Add-Member -MemberType NoteProperty -Name EmailBody    -Value  $EmailBody
              $SessionsUserInfo.Add( $SessionInfo)
         }
              return $SessionsUserInfo
            }
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
        $From = 'info2_requests@aas.com.au'
        $To = 'vanessa.fernandes@aas.com.au' #$SessionUser.EmailAddress
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
Contact-SessionUser -SessionUser $Sessionuser -WhatIf


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

$SId = $Session.session_id
         
Terminate-Session -SqlInstance LGHBDVDB05 -sessionID $SId  -WhatIf
