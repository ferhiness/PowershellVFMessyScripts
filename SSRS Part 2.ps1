# From https://www.mssqltips.com/sqlservertip/4738/powershell-commands-for-sql-server-reporting-services/
# http://redglue.eu/ssrs-report-deployment-made-easy-700-times-faster/
Install-Module SSRSAdmin
#Install-Module -Name ReportingServicesTools    
#Get-Command -Module ReportingServicesTools
#Get-Help Write-RsFolderContent #Uploads all items in a folder on disk to a report server
Get-Help Out-RsFolderContent 
#data source configuration

$ExportFolderLocation = '\\aukbmedc01\Group\Shared\IT Strategy\BIDelivery\SSRS'
$ReportServerUri = 'http://prdlgdwrs1/ReportServer'

$ReportServerContent = Get-RsFolderContent -ReportServerUri $ReportServerUri -RsFolder '/' -Recurse

Out-RsFolderContent -ReportServerUri $ReportServerUri -Destination $ExportFolderLocation -RsFolder '/' -Recurse



#Trials are below
$ReportServerContent.Count
$RTest  = $ReportServerContent[2164]

$ReportDataSources = Get-RsItemDataSource -RsItem $RTest.Path -ReportServerUri $ReportServerUri  
$DS = $ReportDataSources[1]
$DS.Item

Get-RsItemReference -Path $RTest.Path -ReportServerUri  $ReportServerUri 

 #Get-RsItemReference -Path $RTest.Path -ReportServerUri $ReportServerUri 

#Get-Help Write-RsFolderContent #Uploads all items in a folder on disk to a report server

$ReportServerContent | Select Name, TypeName, ModifiedBy, ModifiedDate
#$ReportServerContent.Count

#$item = $ReportServerContent[0]
foreach ($item in $ReportServerContent){

  if($item.TypeName -eq 'Folder'  ){
     [IO.FileInfo] $folder = $ExportFolderLocation + $item.Path.Replace( '/', '\')
    if (!$folder.Exists){New-Item -ItemType directory -Path $folder.FullName }
    $FolderContents =  Get-RsCatalogItems -ReportServerUri $ReportServerUri -RsFolder $item.Path -Recurse
    $FolderContents
  }
  
  #if($item.TypeName -eq 'Report'){
  #  $Report = Get-Cata
  #}

}

 

Get-RsFolderContent -ReportServerUri $ReportServerUri -RsFolder '/'  | where  | Select Name, TypeName, ModifiedBy, ModifiedDate

Get-RsFolderContent -ReportServerUri $ReportServerUri -RsFolder '/RESTPortal' -Recurse | Select Name, TypeName, ModifiedBy, ModifiedDate
 $ReportsList = Get-RsFolderContent -ReportServerUri 'http://prdlgdwrs1/ReportServer' -RsFolder '/RESTPortal' -Recurse | Select Name, TypeName, ModifiedBy, ModifiedDate
 $ReportsList
 $ReportToGet = $ReportsList[0]
 

$reports = Get-RsCatalogItems -RsFolder '/RESTPortal' -ReportServerUri 'http://prdlgdwrs1/ReportServer' -Recurse |
             Where-Object {$_.TypeName -eq "Report"}
$report = $reports[0]

$report.GetType()

 $ReportDS = Get-RsItemDataSource -RsItem $report.Path -ReportServerUri 'http://prdlgdwrs1/ReportServer'
 $ReportDS.Item.Reference

 Get-Help  Get-RsItemDataSource #Get-RsDataSource
 
 $DS1 = Get-RsDataSource -ReportServerUri 'http://prdlgdwrs1/ReportServer' -Path '/Data Sources/Warehouse' 
 $DS1.CredentialRetrieval
