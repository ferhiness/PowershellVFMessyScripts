Cd "C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy"

Connect-AzureRmAccount

$ContainerName = 'prodg7maskedbackup'
$ContainerURL = 'https://sqlmiodspoc.blob.core.windows.net/prodg7maskedbackup'

$saaccountKey1 = 'TDAzx28MLDwcyZmS9VgejX0QFgTIKpBYn1aNtNjMwD1DtithIS2A3UPrl0pb6ydWtR/1rhhM2KKlV/PH3DbLtQ=='



#dir d:\SQL_DATA\SQLData_2\Backup\PRODG7\

#dir d:\SQL_DATA\SQLData_2\Backup\PRODG7\

#### Method New -- Looping #####

Cd "C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy"
$BackupfilesetCOunt = 20
$FileCounter = 1
$AzCopyResults = New-Object -TypeName 'System.Collections.ArrayList';

for ($FileCounter = 1;  $FileCounter -lt $BackupfilesetCOunt  ; $FileCounter++  ){
    $BackupFilename = "LGHBDB03_ODSaaspirePRODG7_Masked_MI_$FileCounter.bak"
    Write-Host "Copying $BackupFilename ..."
    $Result = .\AzCopy.exe /Source:"\\lghbdb17\d$\SQL_DATA\SQLData_2\Backup\PRODG7\" /Dest:https://sqlmiodspoc.blob.core.windows.net/prodg7maskedbackup /DestKey:TDAzx28MLDwcyZmS9VgejX0QFgTIKpBYn1aNtNjMwD1DtithIS2A3UPrl0pb6ydWtR/1rhhM2KKlV/PH3DbLtQ== /Pattern:LGHBDB03_ODSaaspirePRODG7_Masked_MI*
    $AzCopyResults.Add( $Result)
}



.\AzCopy.exe /Source:"\\lghbdb17\d$\SQL_DATA\SQLData_2\Backup\PRODo\" /Dest:https://sqlmiodspoc.blob.core.windows.net/prodobackup /DestKey:TDAzx28MLDwcyZmS9VgejX0QFgTIKpBYn1aNtNjMwD1DtithIS2A3UPrl0pb6ydWtR/1rhhM2KKlV/PH3DbLtQ== /Pattern:ODSaaspirePRODO_MI_*.bak

<#[2019/03/30 01:01:24] Transfer summary:
-----------------
Total files transferred: 25
Transfer successfully:   25
Transfer skipped:        0
Transfer failed:         0
Elapsed time:            00.00:40:36#>




#  -- Method Old --
Cd "C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy"

.\AzCopy.exe /Source:"\\lghbdb17\d$\SQL_DATA\SQLData_2\Backup\PRODG7\" /Dest:https://sqlmiodspoc.blob.core.windows.net/prodg7maskedbackup /DestKey:TDAzx28MLDwcyZmS9VgejX0QFgTIKpBYn1aNtNjMwD1DtithIS2A3UPrl0pb6ydWtR/1rhhM2KKlV/PH3DbLtQ== /Pattern:LGHBDB03_ODSaaspirePRODG7_Masked_MI*
.\AzCopy.exe /Source:"\\lghbdb17\d$\SQL_DATA\SQLData_2\Backup\PRODG7\" /Dest:https://sqlmiodspoc.blob.core.windows.net/prodg7maskedbackup /DestKey:TDAzx28MLDwcyZmS9VgejX0QFgTIKpBYn1aNtNjMwD1DtithIS2A3UPrl0pb6ydWtR/1rhhM2KKlV/PH3DbLtQ== /Pattern:LGHBDB03_ODSaaspirePRODG7_Masked_MI_1.bak
.\AzCopy.exe /Source:"\\lghbdb17\d$\SQL_DATA\SQLData_2\Backup\PRODG7\" /Dest:https://sqlmiodspoc.blob.core.windows.net/prodg7maskedbackup /DestKey:TDAzx28MLDwcyZmS9VgejX0QFgTIKpBYn1aNtNjMwD1DtithIS2A3UPrl0pb6ydWtR/1rhhM2KKlV/PH3DbLtQ== /Pattern:LGHBDB03_ODSaaspirePRODG7_Masked_MI_2.bak
.\AzCopy.exe /Source:"\\lghbdb17\d$\SQL_DATA\SQLData_2\Backup\PRODG7\" /Dest:https://sqlmiodspoc.blob.core.windows.net/prodg7maskedbackup /DestKey:TDAzx28MLDwcyZmS9VgejX0QFgTIKpBYn1aNtNjMwD1DtithIS2A3UPrl0pb6ydWtR/1rhhM2KKlV/PH3DbLtQ== /Pattern:LGHBDB03_ODSaaspirePRODG7_Masked_MI_3.bak
.\AzCopy.exe /Source:"\\lghbdb17\d$\SQL_DATA\SQLData_2\Backup\PRODG7\" /Dest:https://sqlmiodspoc.blob.core.windows.net/prodg7maskedbackup /DestKey:TDAzx28MLDwcyZmS9VgejX0QFgTIKpBYn1aNtNjMwD1DtithIS2A3UPrl0pb6ydWtR/1rhhM2KKlV/PH3DbLtQ== /Pattern:LGHBDB03_ODSaaspirePRODG7_Masked_MI_4.bak
.\AzCopy.exe /Source:"\\lghbdb17\d$\SQL_DATA\SQLData_2\Backup\PRODG7\" /Dest:https://sqlmiodspoc.blob.core.windows.net/prodg7maskedbackup /DestKey:TDAzx28MLDwcyZmS9VgejX0QFgTIKpBYn1aNtNjMwD1DtithIS2A3UPrl0pb6ydWtR/1rhhM2KKlV/PH3DbLtQ== /Pattern:LGHBDB03_ODSaaspirePRODG7_Masked_MI_5.bak
.\AzCopy.exe /Source:"\\lghbdb17\d$\SQL_DATA\SQLData_2\Backup\PRODG7\" /Dest:https://sqlmiodspoc.blob.core.windows.net/prodg7maskedbackup /DestKey:TDAzx28MLDwcyZmS9VgejX0QFgTIKpBYn1aNtNjMwD1DtithIS2A3UPrl0pb6ydWtR/1rhhM2KKlV/PH3DbLtQ== /Pattern:LGHBDB03_ODSaaspirePRODG7_Masked_MI_6.bak
.\AzCopy.exe /Source:"\\lghbdb17\d$\SQL_DATA\SQLData_2\Backup\PRODG7\" /Dest:https://sqlmiodspoc.blob.core.windows.net/prodg7maskedbackup /DestKey:TDAzx28MLDwcyZmS9VgejX0QFgTIKpBYn1aNtNjMwD1DtithIS2A3UPrl0pb6ydWtR/1rhhM2KKlV/PH3DbLtQ== /Pattern:LGHBDB03_ODSaaspirePRODG7_Masked_MI_7.bak
.\AzCopy.exe /Source:"\\lghbdb17\d$\SQL_DATA\SQLData_2\Backup\PRODG7\" /Dest:https://sqlmiodspoc.blob.core.windows.net/prodg7maskedbackup /DestKey:TDAzx28MLDwcyZmS9VgejX0QFgTIKpBYn1aNtNjMwD1DtithIS2A3UPrl0pb6ydWtR/1rhhM2KKlV/PH3DbLtQ== /Pattern:LGHBDB03_ODSaaspirePRODG7_Masked_MI_8.bak
.\AzCopy.exe /Source:"\\lghbdb17\d$\SQL_DATA\SQLData_2\Backup\PRODG7\" /Dest:https://sqlmiodspoc.blob.core.windows.net/prodg7maskedbackup /DestKey:TDAzx28MLDwcyZmS9VgejX0QFgTIKpBYn1aNtNjMwD1DtithIS2A3UPrl0pb6ydWtR/1rhhM2KKlV/PH3DbLtQ== /Pattern:LGHBDB03_ODSaaspirePRODG7_Masked_MI_9.bak
.\AzCopy.exe /Source:"\\lghbdb17\d$\SQL_DATA\SQLData_2\Backup\PRODG7\" /Dest:https://sqlmiodspoc.blob.core.windows.net/prodg7maskedbackup /DestKey:TDAzx28MLDwcyZmS9VgejX0QFgTIKpBYn1aNtNjMwD1DtithIS2A3UPrl0pb6ydWtR/1rhhM2KKlV/PH3DbLtQ== /Pattern:LGHBDB03_ODSaaspirePRODG7_Masked_MI_10.bak
.\AzCopy.exe /Source:"\\lghbdb17\d$\SQL_DATA\SQLData_2\Backup\PRODG7\" /Dest:https://sqlmiodspoc.blob.core.windows.net/prodg7maskedbackup /DestKey:TDAzx28MLDwcyZmS9VgejX0QFgTIKpBYn1aNtNjMwD1DtithIS2A3UPrl0pb6ydWtR/1rhhM2KKlV/PH3DbLtQ== /Pattern:LGHBDB03_ODSaaspirePRODG7_Masked_MI_11.bak
.\AzCopy.exe /Source:"\\lghbdb17\d$\SQL_DATA\SQLData_2\Backup\PRODG7\" /Dest:https://sqlmiodspoc.blob.core.windows.net/prodg7maskedbackup /DestKey:TDAzx28MLDwcyZmS9VgejX0QFgTIKpBYn1aNtNjMwD1DtithIS2A3UPrl0pb6ydWtR/1rhhM2KKlV/PH3DbLtQ== /Pattern:LGHBDB03_ODSaaspirePRODG7_Masked_MI_12.bak
.\AzCopy.exe /Source:"\\lghbdb17\d$\SQL_DATA\SQLData_2\Backup\PRODG7\" /Dest:https://sqlmiodspoc.blob.core.windows.net/prodg7maskedbackup /DestKey:TDAzx28MLDwcyZmS9VgejX0QFgTIKpBYn1aNtNjMwD1DtithIS2A3UPrl0pb6ydWtR/1rhhM2KKlV/PH3DbLtQ== /Pattern:LGHBDB03_ODSaaspirePRODG7_Masked_MI_13.bak
.\AzCopy.exe /Source:"\\lghbdb17\d$\SQL_DATA\SQLData_2\Backup\PRODG7\" /Dest:https://sqlmiodspoc.blob.core.windows.net/prodg7maskedbackup /DestKey:TDAzx28MLDwcyZmS9VgejX0QFgTIKpBYn1aNtNjMwD1DtithIS2A3UPrl0pb6ydWtR/1rhhM2KKlV/PH3DbLtQ== /Pattern:LGHBDB03_ODSaaspirePRODG7_Masked_MI_14.bak
.\AzCopy.exe /Source:"\\lghbdb17\d$\SQL_DATA\SQLData_2\Backup\PRODG7\" /Dest:https://sqlmiodspoc.blob.core.windows.net/prodg7maskedbackup /DestKey:TDAzx28MLDwcyZmS9VgejX0QFgTIKpBYn1aNtNjMwD1DtithIS2A3UPrl0pb6ydWtR/1rhhM2KKlV/PH3DbLtQ== /Pattern:LGHBDB03_ODSaaspirePRODG7_Masked_MI_15.bak
.\AzCopy.exe /Source:"\\lghbdb17\d$\SQL_DATA\SQLData_2\Backup\PRODG7\" /Dest:https://sqlmiodspoc.blob.core.windows.net/prodg7maskedbackup /DestKey:TDAzx28MLDwcyZmS9VgejX0QFgTIKpBYn1aNtNjMwD1DtithIS2A3UPrl0pb6ydWtR/1rhhM2KKlV/PH3DbLtQ== /Pattern:LGHBDB03_ODSaaspirePRODG7_Masked_MI_16.bak
.\AzCopy.exe /Source:"\\lghbdb17\d$\SQL_DATA\SQLData_2\Backup\PRODG7\" /Dest:https://sqlmiodspoc.blob.core.windows.net/prodg7maskedbackup /DestKey:TDAzx28MLDwcyZmS9VgejX0QFgTIKpBYn1aNtNjMwD1DtithIS2A3UPrl0pb6ydWtR/1rhhM2KKlV/PH3DbLtQ== /Pattern:LGHBDB03_ODSaaspirePRODG7_Masked_MI_17.bak
.\AzCopy.exe /Source:"\\lghbdb17\d$\SQL_DATA\SQLData_2\Backup\PRODG7\" /Dest:https://sqlmiodspoc.blob.core.windows.net/prodg7maskedbackup /DestKey:TDAzx28MLDwcyZmS9VgejX0QFgTIKpBYn1aNtNjMwD1DtithIS2A3UPrl0pb6ydWtR/1rhhM2KKlV/PH3DbLtQ== /Pattern:LGHBDB03_ODSaaspirePRODG7_Masked_MI_18.bak
.\AzCopy.exe /Source:"\\lghbdb17\d$\SQL_DATA\SQLData_2\Backup\PRODG7\" /Dest:https://sqlmiodspoc.blob.core.windows.net/prodg7maskedbackup /DestKey:TDAzx28MLDwcyZmS9VgejX0QFgTIKpBYn1aNtNjMwD1DtithIS2A3UPrl0pb6ydWtR/1rhhM2KKlV/PH3DbLtQ== /Pattern:LGHBDB03_ODSaaspirePRODG7_Masked_MI_19.bak
.\AzCopy.exe /Source:"\\lghbdb17\d$\SQL_DATA\SQLData_2\Backup\PRODG7\" /Dest:https://sqlmiodspoc.blob.core.windows.net/prodg7maskedbackup /DestKey:TDAzx28MLDwcyZmS9VgejX0QFgTIKpBYn1aNtNjMwD1DtithIS2A3UPrl0pb6ydWtR/1rhhM2KKlV/PH3DbLtQ== /Pattern:LGHBDB03_ODSaaspirePRODG7_Masked_MI_20.bak
<#
[2019/03/28 20:37:14] Transfer summary:
-----------------
Total files transferred: 1
Transfer successfully:   1
Transfer skipped:        0
Transfer failed:         0
Elapsed time:            00.00:04:56
[2019/03/28 20:41:21] Transfer summary:
-----------------
Total files transferred: 1
Transfer successfully:   1
Transfer skipped:        0
Transfer failed:         0
Elapsed time:            00.00:04:05
[2019/03/28 20:46:28] Transfer summary:
-----------------
Total files transferred: 1
Transfer successfully:   1
Transfer skipped:        0
Transfer failed:         0
Elapsed time:            00.00:05:06
[2019/03/28 20:52:13] Transfer summary:
-----------------
Total files transferred: 1
Transfer successfully:   1
Transfer skipped:        0
Transfer failed:         0
Elapsed time:            00.00:05:44
[2019/03/28 20:56:31] Transfer summary:
-----------------
Total files transferred: 1
Transfer successfully:   1
Transfer skipped:        0
Transfer failed:         0
Elapsed time:            00.00:04:17
[2019/03/28 21:00:41] Transfer summary:
-----------------
Total files transferred: 1
Transfer successfully:   1
Transfer skipped:        0
Transfer failed:         0
Elapsed time:            00.00:04:10
[2019/03/28 21:07:42] Transfer summary:
-----------------
Total files transferred: 1
Transfer successfully:   1
Transfer skipped:        0
Transfer failed:         0
Elapsed time:            00.00:04:49
[2019/03/28 21:12:06] Transfer summary:
-----------------
Total files transferred: 1
Transfer successfully:   1
Transfer skipped:        0
Transfer failed:         0
Elapsed time:            00.00:04:23
[2019/03/28 21:17:49] Transfer summary:
-----------------
Total files transferred: 1
Transfer successfully:   1
Transfer skipped:        0
Transfer failed:         0
Elapsed time:            00.00:05:42
[2019/03/28 21:23:04] Transfer summary:
-----------------
Total files transferred: 1
Transfer successfully:   1
Transfer skipped:        0
Transfer failed:         0
Elapsed time:            00.00:05:13
[2019/03/28 21:27:11] Transfer summary:
-----------------
Total files transferred: 1
Transfer successfully:   1
Transfer skipped:        0
Transfer failed:         0
Elapsed time:            00.00:04:07
[2019/03/28 21:32:09] Transfer summary:
-----------------
Total files transferred: 1
Transfer successfully:   1
Transfer skipped:        0
Transfer failed:         0
Elapsed time:            00.00:04:57
[2019/03/28 21:35:57] Transfer summary:
-----------------
Total files transferred: 1
Transfer successfully:   1
Transfer skipped:        0
Transfer failed:         0
Elapsed time:            00.00:03:46
[2019/03/28 21:40:29] Transfer summary:
-----------------
Total files transferred: 1
Transfer successfully:   1
Transfer skipped:        0
Transfer failed:         0
Elapsed time:            00.00:04:31
[2019/03/28 21:46:24] Transfer summary:
-----------------
Total files transferred: 1
Transfer successfully:   1
Transfer skipped:        0
Transfer failed:         0
Elapsed time:            00.00:05:54
[2019/03/28 21:51:45] Transfer summary:
-----------------
Total files transferred: 1
Transfer successfully:   1
Transfer skipped:        0
Transfer failed:         0
Elapsed time:            00.00:05:20
[2019/03/28 21:56:26] Transfer summary:
-----------------
Total files transferred: 1
Transfer successfully:   1
Transfer skipped:        0
Transfer failed:         0
Elapsed time:            00.00:04:40
[2019/03/28 22:01:30] Transfer summary:
-----------------
Total files transferred: 1
Transfer successfully:   1
Transfer skipped:        0
Transfer failed:         0
Elapsed time:            00.00:05:03
#>

