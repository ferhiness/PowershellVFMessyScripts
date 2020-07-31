
Start-Job -ScriptBlock { 
  $timeout = new-timespan -Minutes 300
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
    Start-Sleep -Seconds 300
  }
 }


