$DomainName = 'APAC'
$ComputerName = 'LGHBDB03'
$UserName = 'SQLServerMonitor'
$AdminGroup = [ADSI]"WinNT://$ComputerName/Administrators,group" 
$User = [ADSI]"WinNT://$DomainName/$UserName,user"
$AdminGroup.Add($User.Path)   
$AdminGroup.GetType()

$ComputerName = 'LGHBDB03'

$DomainName = 'APAC'
$UserName = 'SQLServerMonitor'

$ErroredComputers = New-Object -TypeName 'System.Collections.ArrayList';
$ComputersList =  Invoke-DbaQuery -SqlInstance LGHBDB12 -Database dbareports_V2 -Query "SELECT [ComputerName]  FROM [dbareports_V2].[Reporting].[ActiveComputers]"

foreach ($Computer in $ComputersList){
    $ComputerName = $Computer.ComputerName
    #Write-Host -ForegroundColor DarkYellow  " $ComputerName"

    try{
        $AdminGroup = [ADSI]"WinNT://$ComputerName/Administrators,group" 
        $User = [ADSI]"WinNT://$DomainName/$UserName,user"
        $AdminGroup.Add($User.Path)   
        #$AdminGroup.GetType()
    }catch{
         $CurrentError = New-Object -TypeName psobject 
         $CurrentError  | Add-Member -MemberType NoteProperty -Name ComputerName -Value   $ComputerName                         
         $CurrentError  | Add-Member -MemberType NoteProperty -Name ErrorMessage -Value   $_.Exception.Message  
         $ErroredComputers.Add($CurrentError) 
         Write-Output  "Error Adding $DomainName\$UserName to  $ComputerName  " 
    }
}

$ErroredComputers | Export-Excel  -Path C:\Temp\ErrorComputers.xlsx  -AutoSize -TitleBackgroundColor Blue -BoldTopRow  -KillExcel

#yHBu#Egr@bgGTRzP9x3Z


$ComputerName = "LGHBDB03"
$ComputerName = "LGMDCVC01.aas.priv"


        $AdminGroup = [ADSI]"WinNT://$ComputerName/Administrators,group" 
        $User = [ADSI]"WinNT://$DomainName/$UserName,user"
        $AdminGroup.Add($User.Path)   


##############################################################################################        
get-localadmin  LGMDCVC01.aas.priv


##############################################################################################
[Array] $servers = "vic01vdbp070","LGNRDB03","LGHBDB02", "OC-SYD-SQL-PS8", "LGHBDB17";
$service='winmgmt'
$ServerWMIStatuses = New-Object -TypeName 'System.Collections.ArrayList';

foreach($server in $servers) {
    $Status = Get-WmiObject -query "SELECT * FROM win32_service  WHERE name LIKE '$service' " -computername $server #| Format-Table
    Write-Host "$server " $Status.Name  $Status.State  $Status.Status
}


##############################################################################################
function get-localadmin {  
param ($strcomputer)  
  
$admins = Gwmi win32_groupuser –computer $strcomputer   
$admins = $admins |? {$_.groupcomponent –like '*"Administrators"'}  
  
$admins |% {  
$_.partcomponent –match “.+Domain\=(.+)\,Name\=(.+)$” > $nul  
$matches[1].trim('"') + “\” + $matches[2].trim('"')  
}  
}


###Now addd the user to SQL srver
$Query = "IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'APAC\SQLServerMonitor')
CREATE LOGIN [APAC\SQLServerMonitor] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [APAC\SQLServerMonitor]
GO
"
