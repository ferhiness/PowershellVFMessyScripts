$ServerList = 'SQLCLUSTER4',	'LMSNRDB01',	'OC-SYD-SQL-DR3',	'vic01vdbp072',	'EMPNRNBC01',	'OC-SYD-WEB-PS21',	'SQLCLUSTER2',	'DSNRDB04',	'LGHBDB17',	'LGHBDB22',	'EMPNRDB07',	'OC-SYD-SQL-DR2',	'DSNRDB02',	'AASNRDB06',	'OC-SYD-SQL-DR4',	'EMPNRDB01',	'SQLCLUSTER5',	'EMPNRAP01',	'EMPNRAP07',	'DSHBDB02',	'OC-SYD-INF-MS5',	'LGNRDB16',	'DSHBDB04',	'LGNRDB22',	'LGHBDB19',	'LGNRBF001',	'EMPNRAP08',	'LGHBDB07',	'DSNRDB03',	'AASSYDBCL01',	'EMPNRAP10',	'LGNRPDB001',	'SQLCLUSTER1',	'OC-SYD-WEB-PS20',	'LGHBDB18',	'AASSYDBCL02',	'LGHBDB21',	'EMPNRDB11',	'DSHBDB03',	'SQLCLUSTER6',	'EMPNRDB10',	'vic02vdbp072',	'EMPNREDQDB01'

#'AASHBDB01',	'AASPAVC01',	'AASSYDBCL01',	'AASSYDBCL02\SQL2000',	'LMSGEOWEB01',	'LMSIDCTSR01',	'AASNRDB06',	'AASNRDB08',	'AASNRDB08\SQL02',	'AASNRDB09',	'AASNRDB09\SQL02',	'AASHBDB08',	'AASHBDB08\SQL02',	'AASHBDB09',	'AASHBDB09\SQL02',	'AASNRDB09\ERPLN',	'AASHBDB09\ERPLN',	'AASNRDB12',	'AASNRDB15',	'AASHBDB15',	'AASNRDB16',	'EMPNRAP01',	'EMPNRAP02',	'EMPNRAP04',	'EMPNRAP05',	'EMPNRDB01',	'EMPNRDB02',	'EMPNRDB02\SQL2K14',	'EMPNRDB03',	'EMPNRDB04',	'EMPNRDB05',	'EMPNRDB06',	'LGHBDB02',	'LGHBDB03',	'LGHBDB05',	'LGHBDB06',	'LGHBDB08',	'LGHBSQL01',	'LGHBSQL01\PRD01',	'LGHBSQL01\PRD02',	'LGHBSQL02',	'LGNRDB02',	'LGNRDB03',	'LGNRDB04',	'LGNRDB05',	'LGNRDB06',	'LGNRDB07',	'LGNRDB08',	'LGNRDB09',	'LGNRSQL01',	'LGNRSQL01\PRD01',	'LGNRSQL01\PRD02',	'LGNRSQL02',	'LDCNRDB01',	'LGNRDB10',	'LGHBDB10',	'EMPNRDB07',	'EMPNRDB08\SQL2014',	'EMPNRDB08',	'MOSSYAP02',	'LGNRDB11',	'SBCW21',	'LGNRDB15\SQL01',	'LGNRDB15\SQL02',	'LGNRDB15',	'LGHBDB20',	'LGNRDB16',	'LGNRDB18',	'LGNRDB19',	'LGNRDB20',	'LMSHBDB01',	'LGNPVDBZ010',	'EMPNRDB09',	'EMPNRAP11',	'LGHBDB04',	'EMPNRDB07\VISUALSPT1',	'EMPNRDB07\VISUALSPT2',	'SQLCLUSTER4\AAS',	'EMPNRAP07\SQLEXPRESS',	'DSHBDB04\DOLPHIN',	'LGHBDB18',	'DSNRDB04\DOLPHIN',	'SQLCLUSTER5\DOLPHIN',	'EMPNRAP08\SQLEXPRESS',	'DSNRDB03\LINK',	'LGHBDB07',	'SQLCLUSTER6\LINK',	'EMPNRAP10',	'OC-SYD-SQL-DR2\MAMMOTH',	'OC-SYD-SQL-DR3\JAGUAR',	'EMPNRDB10',	'VIC01VDBP072',	'EMPNRNBC01',	'OC-SYD-SQL-DR4\AAS',	'VIC02VDBP072',	'EMPNRDB11',	'OC-SYD-SQL-DR4\LINK',	'LGNRDB22',	'OC-SYD-WEB-PS20',	'EMPNREDQDB01',	'DSNRDB02\JAGUAR',	'LGHBDB22',	'OC-SYD-INF-MS5',	'LGHBDB17',	'DSHBDB02\JAGUAR',	'LGNRPDB001\SHAREPOINT',	'SQLCLUSTER2\MAMMOTH',	'LGNRPDB001',	'LGHBDB21',	'DSHBDB03\LINK',	'SQLCLUSTER1',	'LGHBDB19',	'OC-SYD-WEB-PS21',	'LMSNRDB01',	'AASNRDB06\SQLEXPRESS',	'EMPNRDB07\VISUALSPT3',	'LGNRBF001',

$Server = 'OC-SYD-SQL-DR2'
$ServerSizeList = New-Object -TypeName 'System.Collections.ArrayList';
$ErrorServerList = New-Object -TypeName 'System.Collections.ArrayList';

foreach($Server in $ServerList){
  #$ServerSizeData = New-Object -TypeName psobject 
  # 
  try{
    $ServerSizeData = Get-DbaDatabaseFreespace -sqlserver $server  -WarningVariable vwarn

    #| Select ComputerName, SqlInstance, Database, FileGroup,FileType, FileSize 
    }catch{
      $Error
      $vwarn
      [void] $ErrorServerList.Add($ServerSizeDataError)
      $Error.clear()
    }
    if ($Error -or $vwarn ){
    $ServerSizeDataError = New-Object -TypeName psobject 
    $ServerSizeDataError | Add-Member -MemberType NoteProperty -Name ComputerName -Value   $server
    $ServerSizeDataError | Add-Member -MemberType NoteProperty -Name ErrorData -Value   $Error
    $ServerSizeDataError | Add-Member -MemberType NoteProperty -Name Warning -Value   $vwarn
    [void] $ErrorServerList.Add($ServerSizeDataError)
    $vwarn.Clear()
    $Error.clear()
    }
    [void] $ServerSizeList.Add($ServerSizeData)
     
}

$ServerSizeData

$ServerSizeList |Format-Table
$ServerSizeList | ConvertTo-DbaDataTable 
$ErrorServerList |Format-Table
Write-DbaDataTable -SqlInstance 'AASHBDB32' -Database DBA_Metrics -InputObject $ServerSizeList -Table ServerDatabaseSizeList -AutoCreateTable


#Get-DbaDatabaseFreespace -sqlserver $server | Select ComputerName, SqlInstance, Database, FileGroup,FileType, FileSize | Format-Table

$E = $Error.Item(4).GetType()
$Error.Clear()