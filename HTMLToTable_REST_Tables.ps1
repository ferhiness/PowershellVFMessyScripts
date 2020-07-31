$BaseUrl = 'http://aaspire-launch-tst.apac.linkgroup.corp/DataDictionary-Nightly/tables/'

$TableName = 'ACC011'
$WebPageURL = "$BaseUrl/$TableName.html"

$HTML = Invoke-webrequest -Uri $WebPageURL

$parsedHTML = $HTML.ParsedHtml
$tables = $parsedHTML.IHTMLDocument3_getElementsByTagName('table') 

#$tables.GetType()
$TableHTML =  $tables[2].innerHTML

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


