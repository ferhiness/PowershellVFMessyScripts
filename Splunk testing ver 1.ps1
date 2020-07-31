#$httpBody = '{{"body": "email body", "Client": "Acme", "subject": "Some subject", "email_to": "vanessa.fernandes@aas.com.au"}}'

#Invoke-WebRequest -Uri 'https://splunk-hec-au-e-svc.linkgroup.corp:8088/services/collector/event' - 


$response = ""
 $formatteddate = "{0:MM/dd/yyyy hh:mm:sstt zzz}" -f (Get-Date)
 $arraySeverity = 'INFO','WARN','ERROR'
 $severity = $arraySeverity[(Get-Random -Maximum ([array]$arraySeverity).count)]
 
 $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
 $headers.Add("Authorization", 'Splunk 653C164D-0AFB-4DFC-ADE0-D9084B03490F')
 
 $body = '{
         "host":"' + $env:computername + '",
         "sourcetype":"testevents",
         "source":"Geoff''s PowerShell Script",
         "event":{
             "message":"Something Happened on host ' + $env:computername + '",
             "severity":"' + $severity + '",
             "user": "'+ $env:username + '",
             "date":"' + $formatteddate + '"
             }
         }'
 
 $splunkserver = "https://splunk-hec-au-e-svc.linkgroup.corp:8088/services/collector/event"
 $response = Invoke-RestMethod -Uri $splunkserver -Method Post -Headers $headers -Body $body
 "Code:'" + $response.code + "' text:'"+ $response.text + "'" 
