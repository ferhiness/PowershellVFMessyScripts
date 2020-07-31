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


##Database Stuff
$SQLCheckIfExists = "SELECT COUNT(*) FROM Test.[StagingReference].ASXCompanyNameCodeChanges WHERE AsOfDate = '"
$SQLInsert = "INSERT INTO Test.[StagingReference].ASXCompanyNameCodeChanges (AsOfDate, OLDCode,OLDCompanyName, Newcode, NewCompanyName )
 VALUES "
$SQLFinalQuery 
$SQLInstanceName = "SQLCLUSTER7.miracle.local\Jaguar"
$DBNAme = "Test"

##Webpage stuff
$WebPageURL = "https://www.asx.com.au/prices/asx-code-and-company-name-changes-2018.htm"
$HTML = Invoke-webrequest -Uri $WebPageURL

$parsedHTML = $HTML.ParsedHtml
$tables = $parsedHTML.IHTMLDocument3_getElementsByTagName('table') 

$TableHTML =  $tables[0].innerHTML

$parsedHTML.GetType()
$table = $tables[0]
$rows = @($table.Rows)
foreach($row in $rows)
{ $cells = @($row.Cells)
  #$cells.tagName
  #$row.innerHTML
  if ($cells.tagName -eq "TD"  ){
  $Data =  ""
  for($counter = 0; $counter -lt $cells.Count; $counter++)
  {  if ($counter -eq 0 )
       {  $Datefield = $cells[$counter].innerText.trim() + " 2018"
          $Datefield = $Datefield.Trim().Replace(" ", "-")
          $Data = $Data + "'" + $Datefield  +  "'," 
          $SQLCheckIfExists = $SQLCheckIfExists + $Datefield + "'"
       }
       else{
         $Data = $Data + "'" + $cells[$counter].innerText  +  "',"
       }    
  }  
    $SQLFinalQuery = $SQLInsert + "(" +   $Data.Trim(",") + ")"
    $SQLFinalQuery
    
    Invoke-Sqlcmd2 -ServerInstance "SQLCLUSTER7.miracle.local\Jaguar" -Database "Test" -Query $SQLFinalQuery
   
  } 
  
}


