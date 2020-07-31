#$host.PrivateData.ErrorForegroundColor = 'Pink'
Connect-AzAccount -UseDeviceAuthentication

(Get-WmiObject Win32_LocalTime).weekinmonth

$Month = 03
$StartDay = 01
$EndDay = 31
$Monthname = (Get-Culture).DateTimeFormat.GetMonthName(8)

for($Day=$StartDay ; $Day -lt $EndDay; $Day++ ){
   # Write-Output $Date 
    $Date = (Get-Date -Year 2020 -Month $Month -Day $Day)
    $weekNo =  [math]::floor(($Date.day - ($Date.dayofweek)%7 + 6)/7)
    if( ([int] $Date.DayOfWeek -eq 0 ) -and ($weekNo -in (2,5) )){
        Write-Output $Date.ToLongDateString()
    }
}

$Date.DayOfWeek