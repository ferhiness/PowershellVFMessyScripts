$BaseUrl = 'https://publicholidays.com.au/2020-dates/'

$States = 'new-south-wales','australian-capital-territory','south-australia','tasmania','northern-territory','queensland','western-australia','victoria'
$State = 'new-south-wales'
$StateUrl = "https://publicholidays.com.au/$State/2020-dates/"
$WebPageURL = "$BaseUrl"

$HTML = Invoke-webrequest -Uri $WebPageURL

$StateHTML = Invoke-webrequest -Uri $StateUrl

$parsedHTML = $HTML.ParsedHtml.body.innerHTML

$stateTables = $StateHTML.ParsedHtml.getElementsByTagName('Table')

 

#<TABLE class="publicholidays phgtable ">

$tables  = $($HTML.ParsedHtml.getElementsByTagName('Table'))

$tables[1].innerHTML
$tables[0].innerHTML


$tables = $parsedHTML.IHTMLDocument3_getElementsByTagName('table') 

#$tables.GetType()
$TableHTML =  $tables[0].innerHTML

$table = $tables[2]
$tableHeadings = ''

$rows = @($table.Rows)
 $cells = $rows[0].cells
foreach($row in $rows){
  $cells = @($row.Cells)
  if ($cells.tagName -eq "TH"  ){
      $tableHeadings = $tableHeadings + $cells[$counter].innerText 
  }

}












########################################################
# Load required functions into Memory

function Test-Url
{
  param
  (
    [Parameter(Mandatory,ValueFromPipeline)]
    [string]
    $Url
  )
  
  Add-Type -AssemblyName System.Web
  
  $check = "https://isitdown.site/api/v3/"
  $encoded = [System.Web.HttpUtility]::UrlEncode($url)
  $callUrl = "$check$encoded"
  
  Invoke-RestMethod -Uri $callUrl |
    Select-Object -Property Host, IsItDown, Response_Code
}


