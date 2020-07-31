# Comparing rowcounts between local database & Azure

$LocalServer = "LGHBDVDB05"
$LocalDBName = "ODSPega"

$dblogin = "pegaods"
$password = "KdiP2goDBA8rRZ9wk0XK"
$AzureServer = "db-au-e-pega-ods-dev-server.database.windows.net,10000"
$AzureDBName = "db-au-pega-ods-dev-database"
$AzureConnectionString = "Server=$AzureServer;Initial Catalog=$AzureDBName;Persist Security Info=False;User ID=$dblogin;Password=$password;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=60;"  
$AzConnection=New-Object System.Data.SqlClient.SqlConnection($AzureConnectionString)  
$AzConnection.Open()  

$sql = "select schema_name(schema_id) +'.'+ t.name as TableName ,p.Rows as Rows
        from sys.tables t
        join (select * from sys.partitions where index_id in (0,1)) p on t.object_id = p.object_id
        order by TableName"
 
$local = Invoke-Sqlcmd2  -ServerInstance $LocalServer -Database $LocalDBName -Query $sql

$azure = Invoke-Sqlcmd2  -SQLConnection $AzConnection -Query $sql
#Invoke-Sqlcmd -ServerInstance $AzureServer -Database $AzureDBName -Query $sql -Username $cred.UserName -Password $cred.GetNetworkCredential().Password

$matches = @()

foreach($i in $local){

$matches += New-Object psobject -Property @{'TableName'=$i.TableName;'LocalRows'=$i.Rows;'AzureRows'=($azure | Where-Object {$_.TableName -eq $i.TableName}).Rows}

}


$matches | Where-Object {$_.LocalRows -ne $_.AzureRows}
