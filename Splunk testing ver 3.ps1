add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Ssl3, [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12
$token = '52345db6-f430-4c3a-afae-3b61958970fe'
$server = 'splunk-hec-au-e-svc.linkgroup.corp'
$formatteddate = Get-Date -format o

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Splunk $token")
$headers.Add("Content-Type","application/json")
$headers.Add("Content-Type", "text/plain")
$severity = 'Debug'

#$body = "{`"event`": `"This is a test to index1`"}"
$body = '{
         "host":"' + $env:computername + '",
         "sourcetype":"hec:test",
         "source":"via Powershell",
         "event":{
             "messageType": "AlertNotification",
             "message":"Job failing test VF ' + $env:computername + '",
             "description": "Job name: SSIS Server Maintenance Job User: ##MS_SSISServerCleanupJobLogin## ",
             "statusChange": "Escalated",
             "severity":"' + $severity + '",
             "user": "'+ $env:username + '",
             "date":"' + $formatteddate + '",
             "monitoredEntity": {
                  "cir": "Root[].[Cluster][[Name]=lghbdb17].[SqlServer][[Name]=sql2017].[SqlProcess][[LoginTime]=27/11/2019 11:22:08;[SessionId]=64]",
                  "name": "lghbdb17",
                  "machineName": "lghbdb17",
                  "sqlInstance": {
                    "name": "sql2017",
                    "displayName": "sql2017",
                    "alias": "PROD-0001-2017"
                  }
                },
             "detailsUrl": "http://lghbdb12:8088/Alerts/lghbdb12/Details/333800?asOfTicks=637277899819547000&context=true"
             }
         }'
$response = Invoke-RestMethod "https://${server}:8088/services/collector/event" -Method 'POST' -Headers $headers -Body $body -Verbose
$response | ConvertTo-Json


