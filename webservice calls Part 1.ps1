$url = "https://globalhistorical.xignite.com/v3/xGlobalHistorical.csv/GetGlobalHistoricalQuotesRange?IdentifierType=ISIN&Identifier=GB0000566504&IdentifierAsOfDate=&AdjustmentMethod=All&StartDate=11/13/2017&EndDate=11/12/2018"

$fileName = "C:\Temp\ScrathArea\DS\TESTSHAREDATA1.csv"

$web = New-Object Net.WebClient
$web | Get-Member
#$web.DownloadString($url)
Try {
    $web.DownloadFile($url, $fileName)
    } 
Catch {
    Write-Warning "$($error[0])"
    }
