function QueryRdpConnections {
$ErrorActionPreference= 'silentlycontinue'
# Import the Active Directory module for the Get-ADComputer CmdLet 
Import-Module ActiveDirectory 

#Query Active Directory for computers running a Server operating system 
$Servers = Get-ADComputer -Filter {OperatingSystem -like "*server*" -and Enabled -eq 'true'} 

ForEach ($Server in $Servers) { 
    $ServerName = $Server.Name 
    

# Run the qwinsta.exe and parse the output 
$queryResults = (qwinsta /SERVER:$ServerName | foreach { (($_.trim() -replace "\s+",","))} | ConvertFrom-Csv)

# Pull the session information from each instance 
ForEach ($queryResult in $queryResults) { 
$RDPUser = $queryResult.USERNAME
$sessionType = $queryResult.SESSIONNAME 


# We only want to display where a "person" is logged in. Otherwise unused sessions show up as USERNAME as a number 
If (($RDPUser -match "fernava") -and ($RDPUser -ne $NULL)) {  

Write-Host $ServerName logged in by $RDPUser on $sessionType 
            }
        }
    }
}

QueryRdpConnections
