param (
    [string]$webserviceparams  ,
    [string]$Path = "C:\Temp\ScrathArea\DS\SGX\",
    [string]$fileName ,
    [string]$format = "CSV"
 )

 $baseurl = "https://globalhistorical.xignite.com/v3/" 
 $methodName = "GetGlobalHistoricalQuotesRange"
 $finalURL = $baseurl +   "xGlobalHistorical." + $format + "/" + $methodName + "?" + $parameters

#$url = "https://globalhistorical.xignite.com/v3/xGlobalHistorical.csv/GetGlobalHistoricalQuotesRange?IdentifierType=ISIN&Identifier=GB0000566504&IdentifierAsOfDate=&AdjustmentMethod=All&StartDate=11/13/2017&EndDate=11/12/2018"

$downloadfile =  $Path +  $fileName + "." + $format

$web = New-Object Net.WebClient
$web | Get-Member
#$web.DownloadString($url)
#$web.DownloadFile($url, $fileName)
Try {
    $web.DownloadFile($finalURL , $downloadfile )
    } 
Catch {
    Write-Warning "$($error[0])"
    }


