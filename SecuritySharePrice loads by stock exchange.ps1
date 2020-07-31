$ExchangeCode = "SGX"
$Query = "DECLARE @ExchangeName Varchar(10) = '" +$ExchangeCode + "'

IF OBJECT_ID('TempDB..#ExchangeCoList') IS NOT NULL
	DROP TABLE #ExchangeCoList

--	SELECT OBJECT_ID('TempDB..#ExchangeCoList')

SELECT  	CO.[ID] As CompanyID, CO.[Name] CompanyName, S.ISIN, S.BalanceDate ,SecurityCode, CT.[Name] CompanyType, ExchCO.[Name] Exchange ,  S.ExchangeCompanyID 
	--SE.CompanyID, [Name], 
INTO #ExchangeCoList
FROm Company.Company CO
JOIN Company.[Security] S on CO.[ID]  = S.CompanyID
JOIN Company.CompanyType CT on CO.CompanyTypeID = CT.[ID]
--JOIN Shares.SecurityExchange SE on CO.ID = SE.CompanyID
LEFT JOIN 	Company.vCompanyUnsecure ExchCO	ON	ExchCO.ID = S.ExchangeCompanyID
WHERE CT.[Name] IN ('Client','Prospect')
AND ExchCO.[Name] = @ExchangeName
And Co.IsArchived = 0

--SELECT REPLACE(CONVERT(Varchar, GETDATE(), 102), '.', '/')

SELECt ExchangeCos.*, EarliestSharePrice,   LastSharePrice,
'IdentifierType=ISIN&Identifier=' + ISIN + '&IdentifierAsOfDate=&AdjustmentMethod=All&StartDate=2018/12/07' 
+ '&EndDate=' +  REPLACE(CONVERT(Varchar, GETDATE(), 102), '.', '/') IdentifierValues
FROm #ExchangeCoList ExchangeCos
LEFT JOIN (
	SELECT CompanyID, MIN(TimeStamp) EarliestSharePrice, MAX(TimeStamp) LastSharePrice
	FROM Price.SharePrice
	GROUP By CompanyID
) SPE on ExchangeCos.CompanyID = SPE.CompanyID
LEFT JOIN (
	SELECT SecurityExchangeID,	MIN( CONVERT(datetime, CONVERT(varchar(8), DateID), 112)) As EarliestDateID, 
								MAX(CONVERT(datetime, CONVERT(varchar(8), DateID), 112) ) As LastDateID
	FROM Shares.SecuritySharePrice
	GROUP By SecurityExchangeID
) SSP on ExchangeCos.ExchangeCompanyID = SSP.SecurityExchangeID
where ISIN IS NOT NULL  
"

 $ResultSet = Invoke-Sqlcmd2 -ServerInstance "SQLCLUSTER7.miracle.local\Jaguar" -Database "Jaguar" -Query $Query


 $Path = "C:\Temp\ScrathArea\DS\"+$ExchangeCode+ "\CSVFiles\"
 $format = "CSV"
 $pattern = '[^a-zA-Z]'

 foreach($item in $ResultSet){
    $parameters =  $item.IdentifierValues
    $CompanyName = $item.CompanyName

    #$fileName = $CompanyName.Replace(" ","")
    $fileName = $CompanyName -Replace $pattern, ''
     

     $baseurl = "https://globalhistorical.xignite.com/v3/" 
     $methodName = "GetGlobalHistoricalQuotesRange"
     $finalURL = $baseurl +   "xGlobalHistorical." + $format + "/" + $methodName + "?" + $parameters
    
    $downloadfile =  $Path +  $fileName + "." + $format
    $web = New-Object Net.WebClient
    $web | Get-Member
    #$web.DownloadString($url)
    #$web.DownloadFile($url, $fileName)
    Try {
        $web.DownloadFile($finalURL , $downloadfile ) 
        Write-Host "Created " + $downloadfile + " for " +  $CompanyName + " -  " + $finalURL
        #$filecontent = Import-Csv -Path $downloadfile | Out-DataTable
        try{
            Import-DbaCsvToSql -Csv $downloadfile -SqlInstance "SQLCLUSTER7.miracle.local\Jaguar" -Database "Test" -Schema "BulkSharepriceLoads" -Table "$ExchangeCode_$fileName"
            Write-Host "Uploaded " + $downloadfile + " to Test." +  $CompanyName
            }
            Catch {
                Write-Warning " $downloadfile $($error[0])"
            }
        } 
    Catch {
        Write-Warning "$($error[0])  $finalURL"
        }

}
