param ( [string]$ReleaseID 
            , [string]$ConfigServer
            , [string]$SVNRepo = "https://sc.apac.linkgroup.corp/svn/dmr/trunk/TASER/TASER SQL Scripts"
            , [string]$SVNRepoRoot = "https://sc.apac.linkgroup.corp/svn/dmr"

)

# S:\IT Strategy\BIDelivery\Releases\WarehouseV4\4.04.23VF\SQL


function Get-SVNObjects {

	param ( [string]$ReleaseID
            , [string]$ExportToFolder
            , [string]$SVNRepo = "https://sc.apac.linkgroup.corp/svn/dmr/trunk/TASER/TASER SQL Scripts"
            , [string]$SVNRepoRoot = "https://sc.apac.linkgroup.corp/svn/dmr"
            , [string]$FromDate = "2018-07-24"
            , [string]$ToDate = "2018-07-26"
            , [string]$TargetDB
            , [string]$LogPath='D:\LogFiles\$($TheSourceSystem)\'
            , [switch]$DoMerge=$true
            , [switch]$DoDirectLoad=$false
            , [int]$BCPBatchSize=1000 )

    #Destroy the release folder
    #rmdir $ExportToFolder -Recurse -Force | Out-Null
    #Create the release folder
    mkdir "$ExportToFolder" -Force | Out-Null

    $svnchanges = (([xml] (svn log $SVNRepo --xml --verbose --limit 100 --revision "{$FromDate}:{$ToDate}" )).log.logentry | ? { $_.msg -match "(.*)$ReleaseID(.*)" })
    
    # $svnchanges
    
    $svnchanges | ForEach-Object {
       
       # svn export -r 15856 "https://sc.apac.linkgroup.corp/svn/dmr/trunk/TASER/TASER SQL Scripts/TASER_Transfer In by Transfer Type and From Fund - PRODA1.sql" "$ExportToFolder" --force 
       "Revision $($_.revision) of file $($SVNRepoRoot)$($_.paths.path."#text") " 

       svn export -r $_.revision "$($SVNRepoRoot)$($_.paths.path."#text")" "$ExportToFolder" --force 

    }

}


function Get-SVNObjectsByRevision {

	param ( [string]$ReleaseID
            , [string] $RevisionNo = 21182
            , [string]$ExportToFolder
            , [string]$SVNRepo = "https://sc.apac.linkgroup.corp/svn/dmr/trunk/TASER/TASER SQL Scripts"
            , [string]$SVNRepoRoot = "https://sc.apac.linkgroup.corp/svn/dmr"
            , [string]$FromDate = "2018-07-24"
            , [string]$ToDate = "2018-07-26"
            , [string]$TargetDB
            , [string]$LogPath='D:\LogFiles\$($TheSourceSystem)\'
            , [switch]$DoMerge=$true
            , [switch]$DoDirectLoad=$false
            , [int]$BCPBatchSize=1000 )

    #Destroy the release folder
    #rmdir $ExportToFolder -Recurse -Force | Out-Null
    #Create the release folder
    mkdir "$ExportToFolder" -Force | Out-Null

    $svnchanges = (([xml] (svn log $SVNRepo --xml --verbose --limit 100 --revision "{$FromDate}:{$ToDate}" )).log.logentry | ? { $_.msg -match "(.*)$ReleaseID(.*)" })
    
    # $svnchanges
    
    $svnchanges | ForEach-Object {
       
       # svn export -r 15856 "https://sc.apac.linkgroup.corp/svn/dmr/trunk/TASER/TASER SQL Scripts/TASER_Transfer In by Transfer Type and From Fund - PRODA1.sql" "$ExportToFolder" --force 
       if ($_.revision = $RevisionNo){
       "Revision $($_.revision) of file $($SVNRepoRoot)$($_.paths.path."#text") " 

       svn export -r $_.revision "$($SVNRepoRoot)$($_.paths.path."#text")" "$ExportToFolder" --force 
       }
    }

}


# Get-SVNObjects -ReleaseID $ReleaseID #-SVNRepo

#Get-SVNObjects -ReleaseID $ReleaseID -ExportToFolder "\\aukbmedc01\group\shared\IT Strategy\BIDelivery\Releases\WarehouseV4\$ReleaseID\SQL\Data" # "C:\Temp\Releases\$ReleaseID\"
Get-SVNObjectsByRevision -RevisionNo 21195 -ReleaseID $ReleaseID -ExportToFolder "C:\Temp\Releases\WarehouseV4\$ReleaseID\TASERSQL\" # "C:\Temp\Releases\$ReleaseID\"

