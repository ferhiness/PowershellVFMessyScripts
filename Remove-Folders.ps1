# Execute by running :      & "C:\Program Files\AAS\PowerShell\Remove-Folders.ps1" -parentPath "C:\Temp\deleteme\"
# $parentPath = "\\lghbdb03\d$\SQL_DATA\Snapshot_Data\REST_AWS_Extracts\LTF_ODS_Extracts\Backup"		
param (
	[string] $parentPath,
	[string] $MaxLoops = 200000
)

$LoopCount = 0;

"Deleting sub-items in path: $parentPath ..."
try{
    $objectsToDelete = (get-childitem -LiteralPath $parentPath -recurse -ErrorAction SilentlyContinue )
    "Total Items found to Delete " + $objectsToDelete.Count
}
catch{
        exit -9999
    }
	#| Sort-Object LastWriteTime | where-object {$_.Name -like '*.txt'}  |  
	
if ($objectsToDelete.Count -eq 0) {
	"Nothing to delete in folder $parentPath"
}else{

	#$objectsToDelete

	$objectsToDelete | foreach-object  { 
		$LoopCount = $LoopCount + 1
		$currentObject = $_
		# "-----------------------------------------------------------------";
        If ($currentObject.Attributes -eq 'Directory')
        {
            $currentObject.FullName +  " Is a directory"
            }
		"Deleting file " + $currentObject.FullName
		try{
			if (test-path $currentObject.FullName){
				Remove-Item -path $currentObject.FullName -recurse -Force:$true -Confirm:$false #| Out-Null
			}
		}catch{
			#kludgy but works
            exit -9999
		}
	}	
}
