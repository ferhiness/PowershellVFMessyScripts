﻿
  $username = "warehouse"
  $password = "ware^house"
  $data_source = "TSTDEMO"
  $connection_string = "User Id=$username;Password=$password;Data Source=$data_source"
  
  Register-DataConnectionString -Name Oracle_pdbrepo -ProviderName System.Data.OracleClient -ConnectionString $connection_string 
  Register-DataConnectionString -Name lgds4-scan -ProviderName System.Data.OracleClient -ConnectionString $connection_string 
  
  $sql =  "select sysdate from dual"
  $ds2 = Invoke-DataQuery -FileOrName Oracle_pdbrepo -Query  $sql

  SELECT 'SELECT ' || owner || ' ,' || OBJECT_NAME || ', COUNT(*) As estimated_size, ' || ', ' || DATA_OBJECT_ID || ' As orig_db_id, '' As description from ' || owner || '.' || OBJECT_NAME
FROM all_objects  o
JOIN dba_tables t  on o.OWNER = t.
where owner = 'ATU_DATA' AND OBJECT_NAME IN
('ADD001'
, 'CON100'
, 'COR040'
, 'PEN013'
, 'PLA019'
, 'TRU009'
, 'COR031'
, 'COM010'
, 'CLM001'
, 'ATO093'
, 'EMP251'
, 'MAS006'
, 'FRQ001'
, 'INV031'
, 'FLA011'
, 'EMP250'
, 'ATO900'
, 'BAS011'
, 'ACC002'
, 'ATO010'
, 'COR033'
, 'PLA078'
, 'RET025'
, 'PLA037'
, 'PER050'
, 'PLA015'
, 'ATO071'
, 'DIV011'
, 'EXT001'
, 'LIS014'
, 'MAS040'
, 'EMP210'
, 'EMP131'
, 'PLA025'
, 'PLA001'
, 'PLA096'
, 'PLA122'
, 'REF018'
, 'RET011'
, 'REF031'
, 'TRU018'
, 'PLA110'
, 'PLA039'
, 'PLA080'
, 'PLA090'
, 'PLA011'
, 'PLA030'
, 'MEM740'
, 'BAS001'
, 'ADV105'
, 'ATO031'
, 'CLM041'
, 'COR013'
, 'MAS045'
, 'MAS070'
, 'LOC001'
, 'MAS011'
, 'MAS030'
, 'MAS035'
, 'INS011'
, 'INS027'
, 'INV011'
, 'MAS005'
, 'ADV101'
, 'EMP120'
, 'PLA027'
, 'PLA029'
, 'PLA120'
, 'SUR003'
, 'TRU020'
, 'TRU005'
);





SELECT * FROM ATU_DATA.TRN512  where rowNum <= 20 ;

SELECT owner, table_name , 'SELECT ' || owner || ' ,' || table_name || ', COUNT(*) As estimated_size, ', *
FROM dba_tables where owner = 'ATU_DATA' AND TABLE_NAME IN
('ADD001'
, 'CON100'
, 'COR040'
, 'PEN013'
, 'PLA019'
, 'TRU009'
, 'COR031'
, 'COM010'
, 'CLM001'
, 'ATO093'
, 'EMP251'
, 'MAS006'
, 'FRQ001'
, 'INV031'
, 'FLA011'
, 'EMP250'
, 'ATO900'
, 'BAS011'
, 'ACC002'
, 'ATO010'
, 'COR033'
, 'PLA078'
, 'RET025'
, 'PLA037'
, 'PER050'
, 'PLA015'
, 'ATO071'
, 'DIV011'
, 'EXT001'
, 'LIS014'
, 'MAS040'
, 'EMP210'
, 'EMP131'
, 'PLA025'
, 'PLA001'
, 'PLA096'
, 'PLA122'
, 'REF018'
, 'RET011'
, 'REF031'
, 'TRU018'
, 'PLA110'
, 'PLA039'
, 'PLA080'
, 'PLA090'
, 'PLA011'
, 'PLA030'
, 'MEM740'
, 'BAS001'
, 'ADV105'
, 'ATO031'
, 'CLM041'
, 'COR013'
, 'MAS045'
, 'MAS070'
, 'LOC001'
, 'MAS011'
, 'MAS030'
, 'MAS035'
, 'INS011'
, 'INS027'
, 'INV011'
, 'MAS005'
, 'ADV101'
, 'EMP120'
, 'PLA027'
, 'PLA029'
, 'PLA120'
, 'SUR003'
, 'TRU020'
, 'TRU005'
);