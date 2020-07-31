# From https://www.mssqltips.com/sqlservertip/4738/powershell-commands-for-sql-server-reporting-services/
# http://redglue.eu/ssrs-report-deployment-made-easy-700-times-faster/

#Install-Module -Name ReportingServicesTools    
Get-Command -Module DbaTools 
Get-Command -Module ReportingServicesTools

Get-RsFolderContent -ReportServerUri 'http://prdlgdwrs1/ReportServer' -RsFolder '/' | where  |Select Name, TypeName, ModifiedBy, ModifiedDate

Get-RsFolderContent -ReportServerUri 'http://prdlgdwrs1/ReportServer' -RsFolder '/RESTPortal' -Recurse | Select Name, TypeName, ModifiedBy, ModifiedDate
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
