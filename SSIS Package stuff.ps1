#Invoke-Sqlcmd2 -ServerInstance “LGHBDVDB06” -Query “SELECT GETDATE()”
$SQLInstance = "LGHBDVDB14"
$Packagename = "WarehouseSuspenseDelivery"

$Packages =  Invoke-Sqlcmd2  -ServerInstance $SQLInstance -Query "WITH cte AS (
                                                                        SELECT    cast(foldername as varchar(max)) as folderpath, folderid
                                                                        FROM    msdb..sysssispackagefolders
                                                                        WHERE    parentfolderid = '00000000-0000-0000-0000-000000000000'
                                                                        UNION    ALL
                                                                        SELECT    cast(c.folderpath + '\' + f.foldername  as varchar(max)), f.folderid
                                                                        FROM    msdb..sysssispackagefolders f
                                                                        INNER    JOIN cte c        ON    c.folderid = f.parentfolderid
                                                                    )
                                                                    SELECT    c.folderpath,p.name,CAST(CAST(packagedata AS VARBINARY(MAX)) AS VARCHAR(MAX)) as pkg
                                                                    FROM    cte c
                                                                    INNER    JOIN msdb..sysssispackages p    ON    c.folderid = p.folderid
                                                                    WHERE    c.folderpath NOT LIKE 'Data Collector%' "

Foreach ($pkg in $Packages)
{
    $pkgName = $Pkg.name
    
    $Path = $pkg.folderpath
    
    if ( $pkgName.Contains($Packagename) ) {
      Write-Host "Exporting " $pkgName

    $folderPath = $Pkg.folderpath
    $fullfolderPath = "c:\temp\$folderPath\"
    if(!(test-path -path $fullfolderPath))
    {
        mkdir $fullfolderPath | Out-Null
    }
    $pkg.pkg | Out-File -Force -encoding ascii -FilePath "$fullfolderPath\$pkgName.dtsx"
    }
    
    
}
