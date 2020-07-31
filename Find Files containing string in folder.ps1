
$ArchiveLocation = '\\aaspafp01\public\PEGA Suspense Extracts Archive'

$searchWords = ',"413720360",'	,',"413720368",'	,',"413722577",'	,',"413722600",'	,',"413729148",'	,',"413731346",'	

Foreach ($sw in $searchWords)
{
    Get-Childitem -Path $ArchiveLocation -Recurse -include "*.csv" | 
    Select-String -Pattern "$sw" | 
    Select Path,LineNumber,@{n='SearchWord';e={$sw}}
}


###################################
# Find files containing more than 1 subdirectory

Get-ChildItem 'C:\Program Files\WindowsPowerShell\Modules' -Directory `
| Select-Object @{n='FullName';e={$_.FullName}},@{n='SubFolderCount';e={(Get-ChildItem $_.FullName  -Directory).Count}} `


