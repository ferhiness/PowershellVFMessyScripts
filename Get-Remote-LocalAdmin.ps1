<#
.SYNOPSIS
Get listing of local admins from a list of servers
.DESCRIPTION
This script will get a listing of local admins from a list of servers
.NOTES  
.USAGE
./Get-Remote-LocalAdmin.ps1
#>
$PSScriptRoot = "C:\VF Queries\Queries\DBA Stuff\Powewrshell\Server"
$ServerList = Get-Content $PSScriptRoot\Serverlist.txt	

$LogFile = "LocalAdminReport_$((Get-Date).ToString('yyyyddmm-hhmm')).txt"

if (!(Test-Path "$PSScriptRoot\$LogFile"))
{
   New-Item -path "$PSScriptRoot\$LogFile" -type "file"

   }


function get-localadmin {  
param ($strcomputer)  
  
$admins = Gwmi win32_groupuser –computer $strcomputer   
$admins = $admins |? {$_.groupcomponent –like '*"Administrators"'}  

  
$admins |% {  
$_.partcomponent –match “.+Domain\=(.+)\,Name\=(.+)$” > $nul  
$matches[1].trim('"') + “\” + $matches[2].trim('"')  
}  
}


foreach ($Server in $ServerList) {


Write-Output "Local Admin Report from $Server" | Tee-Object $PSScriptRoot\$LogFile -Append

get-localadmin "$Server" | Tee-Object $PSScriptRoot\$LogFile -Append

}


Get-ADGroupMember -identity "Administrator" -Recursive | Get-ADUser -Property DisplayName | Select Name,ObjectClass,DisplayName﻿

$A = get-localadmin "$Server" 

