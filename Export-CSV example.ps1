
$Data =  Invoke-DbaQuery -SqlInstance LGNRSQL01 -Database emessagingrev -Query "DECLARE @fromdate DATETIME= '2020-02-27'
DECLARE @todate DATETIME='2020-02-27 23:59:59.000'
SELECT 
	doc_instance_id as [Electronic Unique ID]
	,outbound_message_status as [Status]
	,sentFrom as [From]
	,sentTo as [To]
	,date_last_updated as [Date] 
FROM outbound_message  
WHERE 1=1 
and date_last_updated>=@fromdate
and date_last_updated<=@todate
and date_last_updated!=date_created"

$Data |  Export-Csv -Path '\\aukbmedc01\Group\Shared\IT Strategy\BIDelivery\Vanessa\2020027.csv' -Delimiter ','  -NoTypeInformation 

#Skip Header Row not doe work
$Data | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1 | Set-Content -Path  '\\aukbmedc01\Group\Shared\IT Strategy\BIDelivery\Vanessa\2020027_1.csv' 
