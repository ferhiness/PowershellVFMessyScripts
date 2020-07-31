#Connect-PSSession -ComputerName 
# Demo of using the SQLServer Provide to grab SMO objects from diff SQl servers.. Note this does not seem to wotk on Managed Instances or on Azure servers

Import-Module sqlServer
get-PSDrive

cd SQLSeRVER:
dir
cd SQL
cd SQLSERVER:\SQL\LGNRDB03
cd default

cd SQLSERVER:\SQL\LGNRDB03\default
dir Databases\ODSBIX\Tables


cd SQLSERVER:\SQL\LGNRDB03\default\Databases 
WarehouseREST | Format-List *
dir

cd Databases\ODSBIX\Tables
dir | Measure-Object

dir | foreach { $_.Script()  | Add-Content -Path "C:\Temp\ScrathArea\Script\BIX\$($_.Schema)_$($_.Name)_$(Get-date -f 'yyyyMMdd').sql"}

cd SQLSERVER:\SQL\LGNRDB03\default\Databases
dir | foreach {$_.Name | Write-Host " $_.Name  $_.Status" }


<#
cd SQLSERVER:\SQL
dir
cd au-e-sqlmi-aaspireods-dev.f429637c13ca.database.windows.net
cd AUAZEDVDB006
cd localhost
#>

