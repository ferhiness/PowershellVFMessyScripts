Import-Module ActiveDirectory
Get-ADDomain

$APACGroupsList  =  New-Object -TypeName 'System.Collections.ArrayList';
$APACGroupsList.Add("AAS-SYD- WEB APP Admin")
$APACGroupsList.Add("campbse")
$APACGroupsList.Add("FA-SYD-WEB APP Admin Group")
$APACGroupsList.Add("IT.BusinessSupport")
$APACGroupsList.Add("PROD.Services")
$APACGroupsList.Add("PRODPSServices")
$APACGroupsList.Add("roberda")

foreach($groupName in $APACGroupsList){
    try{
        $Group = Get-ADGroup -Identity $groupName.Trim()
        if($Group){
         try{
            $Members = Get-ADGroupMember  -Identity $GroupName.Trim() -Recursive
            Write-Host $GroupName  " has " $Members.Count 
            if($Members.Count -gt 0){
                $Members | Select    Name,ObjectClass,distinguishedName, SamAccountName | Tee-Object "C:\Temp\ScrathArea\DS\ADStuff\$GroupName.txt" -Append
            }
            }catch{
                Write-Error "$groupName not accessible"
         }
        }
        }catch{
            try{
              $User = Get-ADUser $groupName.Trim()
              if ($User){ Write-Host $groupName " is a " $User.ObjectClass }
            }catch{
                Write-Error "$groupName not accessible"  | Tee-Object "C:\Temp\ScrathArea\DS\ADStuff\$GroupName.txt" -Append
            }
        }
}





$APACGroupsList  =  New-Object -TypeName 'System.Collections.ArrayList';

$APACGroupsList.Add("MIRACLE\Domain Admins")
$APACGroupsList.Add("MIRACLE\miraqleiisdb1")
$APACGroupsList.Add("MIRACLE\PROD.Mirlin")
$APACGroupsList.Add("MIRACLE\UAT.PSService")
$APACGroupsList.Add("OCMIRLIN3\Administrator")
$APACGroupsList.Add("OC-SYD-APP-PS10\Administrator")
$APACGroupsList.Add("OC-SYD-APP-PS10\fujadmin")
$APACGroupsList.Add("OC-SYD-APP-PS5\Administrator")
$APACGroupsList.Add("OC-SYD-APP-PS6\Administrator")
$APACGroupsList.Add("OC-SYD-APP-PS9\Administrator")
$APACGroupsList.Add("OC-SYD-WEB-PS14\Administrator")
$APACGroupsList.Add("OC-SYD-WEB-PS15\Administrator")
$APACGroupsList.Add("OC-SYD-WEB-PS16\Administrator")
$APACGroupsList.Add("OC-SYD-WEB-PS17\Administrator")
$APACGroupsList.Add("OC-SYD-WEB-PS17\fujadmin")
$APACGroupsList.Add("OC-SYD-WEB-PS18\Administrator")
$APACGroupsList.Add("OC-SYD-WEB-PS18\fujadmin")
$APACGroupsList.Add("OC-SYD-WEB-PS19\Administrator")
$APACGroupsList.Add("OC-SYD-WEB-PS19\fujadmin")
$APACGroupsList.Add("OC-SYD-WEB-PS8\Administrator")
$APACGroupsList.Add("OC-SYD-WEB-PS8\fujadmin")
$APACGroupsList.Add("OC-SYD-WEB-PS9\Administrator")
$APACGroupsList.Add("OC-SYD-WEB-PS9\fujadmin")
$APACGroupsList.Add("ORIENTCAPITAL\Domain Admins")
$APACGroupsList.Add("ORIENTCAPITAL\IT.BusinessSupport")
$APACGroupsList.Add("ORIENTCAPITAL\IT.DBAdmins")
$APACGroupsList.Add("ORIENTCAPITAL\OC-SYD-APP Admin Group")
$APACGroupsList.Add("ORIENTCAPITAL\OC-SYD-WEB Admin Group")

