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

$JobCheckQuery = "DECLARE @JobName Varchar(100) = 'SNMPTestJob'
SELECT (
SELECT host = @@SERVERNAME 
	, sourcetype = 'hec:test' 
	, [source] = 'SQL Agent Job'
	, [event] = (
			SELECT 
						 [messageType] = 'AlertNotification',
						 [message]='Job failing test VF',
						 [description] ='Job name: '+ sysjobs.[name] + ' Step:'+ sysjobhistory.step_name +
										':'+sysjobhistory.[message]
										 ,
						 statusChange= 'Escalated',
						 severity='High',
						 [user]= case 
										when left(sysjobhistory.message,16) = 'Executed as user' 
											then substring(sysjobhistory.message,19,charindex('.',sysjobhistory.message,1) - 18)
										when sysjobhistory.message like '%invoked by%'
											then substring(sysjobhistory.message,charindex('invoked by ',sysjobhistory.message) + 11,charindex('.',substring(sysjobhistory.message,charindex('invoked by ',sysjobhistory.message) + 11,99)) - 1)
										else ''
									end,
						 [date]=sysjobhistory.run_date
			--DISTINCT GETDATE() as ts, name, start_execution_date, stop_execution_date, message, server
			FROM   msdb.dbo.sysjobs
			INNER JOIN msdb.dbo.sysjobactivity  ON msdb.dbo.sysjobs.job_id = msdb.dbo.sysjobactivity.job_id
			INNER JOIN msdb.dbo.sysjobhistory  ON sysjobactivity.job_id = sysjobhistory.job_id AND sysjobactivity.job_history_id = sysjobhistory.instance_id
			WHERE sysjobs.[name] = 'SNMPTestJob' --@JobName 
			AND sysjobactivity.start_execution_date > DATEADD(HH, -1, GETDATE()) AND
			(stop_execution_date > dateadd(hh, -1, getdate()) OR start_execution_date > dateadd(hh, -1, getdate()))
			AND message LIKE 'The job failed%'
			FOR JSON PATH, INCLUDE_NULL_VALUES )
FOR JSON PATH, INCLUDE_NULL_VALUES 
) As JobData
"

$body  = (Invoke-DbaQuery -SqlInstance LGHBDB17 -Database msdb -Query $JobCheckQuery).JobData
#$body = $body.'JSON_F52E2B61-18A1-11d1-B105-00805F49916B'
#$body  = $body.JobData
$response = Invoke-RestMethod "https://${server}:8088/services/collector/event" -Method 'POST' -Headers $headers -Body $body -Verbose
$response | ConvertTo-Json



########################################Other tests

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

