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
$headers.Add("Content-Type", "text/plain")
$severity = 'Debug'

#$body = "{`"event`": `"This is a test to index1`"}"
$body = '{
         "host":"' + $env:computername + '",
         "sourcetype":"hec:test",
         "source":"via Powershell",
         "event":{
             "message":"Test sent from VF ' + $env:computername + '",
             "severity":"' + $severity + '",
             "user": "'+ $env:username + '",
             "date":"' + $formatteddate + '"
             }
         }'

$response = Invoke-RestMethod "https://${server}:8088/services/collector/event" -Method 'POST' -Headers $headers -Body $body
$response | ConvertTo-Json