$TableListQuery = "SELECT DISTINCT TABLE_NAME FROM WarehouseREST.dbo.OracleTableStrs20191210 ORDER BY TABLE_NAME" 
$Filename = "C:\Temp\ScrathArea\AWS\AAS2Schema.xlsx"


$TableList = Invoke-DbaQuery -SqlInstance LGNRDB03 -Database WarehouseREST -Query $TableListQuery 
$TableList.Count

$TableList | Export-Excel -Path $Filename -WorksheetName 'Table List'  -TitleBackgroundColor Blue -TitleFillPattern Solid 

foreach($Table in $TableList.TABLE_NAME ){
    $SchemaQuery = "SELECT O.TABLE_NAME, O.COLUMN_NAME, S.COLUMN_ID, ISNULL( S.DataType ,O.DATA_TYPE ) DATA_TYPE, ISNULL(S.max_length, O.DATA_LENGTH) max_length
		            ,ISNULL(S.[precision], O.data_precision ) [precision], CASE WHEN S.is_nullable IS NULL THEN  O.nullable ELSE CONVERT(NVarchar, S.is_nullable) END nullable , S.collation_name
		            , O.comments
		            , CASE WHEN S.object_id IS NULL THEN 'Y' END As MissingODS , CASE WHEN R.object_id IS NULL THEN 'N' ELSE 'Y' END As RESTReceives
                    FROM WarehouseREST.dbo.OracleTableStrs20191210 O
                    LEFT JOIN WarehouseREST.dbo.SQLTableStrs20191211 S on O.TABLE_NAME = S.TableName AND O.COLUMN_NAME = S.ColumnName
                    LEFT JOIN WarehouseREST.dbo.RESTTableStrs20191211 R on O.TABLE_NAME = R.TableName AND O.COLUMN_NAME = R.ColumnName
                    WHERE O.TABLE_NAME = '$Table'
                    ORDER BY O.TABLE_NAME, ISNULL(S.COLUMN_ID, 99)
                    "

   $SchemaResult = Invoke-DbaQuery -SqlInstance LGNRDB03 -Database WarehouseREST -Query $SchemaQuery

   if ($SchemaResult) {
    $SchemaResult | Export-Excel -Path $Filename -WorksheetName $Table  -TitleBackgroundColor Blue -TitleFillPattern Solid  -BoldTopRow  -AutoSize -ExcludeProperty ItemArray, RowError, RowState, Table, HasErrors -KillExcel
    }else{Write-Error 'No data to export'}
}

