
$MainFilesPath = 'C:\Temp\SVN\DT02\'
$TmpFilesPath = 'C:\Temp\SVN\DT02\DT02tmp\'

$MergePath = 'C:\Temp\SVN\DT02Completed\'


Get-ChildItem $MainFilesPath -Filter *.sql |
    ForEach-Object {
    $BaseName = $_.BaseName
    $MainFile = $_.FullName
    $tmpFileName = "tmp$BaseName"
    $MergedFileNAme = "$MergePath\$BaseName.sql"

    $Contents = 
    "
    /******************************* $BaseName **********************************/
    
    "  
    $Contents = $Contents + (Get-Content -Raw $MainFile) 
    $Contents = $Contents + 
   "
    /******************************* $tmpFileName *******************************/
   "
   $Contents = $Contents +  (Get-Content -Raw "$TmpFilesPath\$BaseName.sql") `
  
    $Contents > "$MergePath\$BaseName.sql"
    $Contents  | Set-Content -Path $MergedFileNAme -Force
 #  Write-Host $Contents
   $Contents =""
    }

   
   