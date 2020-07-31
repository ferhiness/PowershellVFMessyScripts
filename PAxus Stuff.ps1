$QueryRoles = "select  GETDATE() As [DateCollected], 'OneSource' As ApplicationName, @@SERVERNAME As [Database Instance],
		m.[name] as Login_Name , r.name as role_name
--r.name as role_name, m.name as member_name 
from sys.database_role_members rm 
inner join sys.database_principals r on rm.role_principal_id = r.principal_id
inner join sys.database_principals m on rm.member_principal_id = m.principal_id
--WHERE m.[name] = 'apac\wallast'
"

$InstanceList = 'LGNRDB15','LGNRDB15\SQL02'
$DBList = 'Paxus_WO_Live','AccountsPro'

$DataPaxus = Invoke-DbaQuery -SqlInstance LGNRDB15 -Database Paxus_WO_Live  -Query $QueryRoles  -ErrorVariable DeployError -MessagesToOutput   
$DataOneSource = Invoke-DbaQuery -SqlInstance LGNRDB15 -Database PROactiveRecs  -Query $QueryRoles  -ErrorVariable DeployError -MessagesToOutput   

$Row  = $null

$UserObjs = New-Object -TypeName 'System.Collections.ArrayList';
$Data= $DataPaxus

Foreach ($Row in $Data ) {
   $RowDetails =  New-Object -TypeName psobject 
   $User =  $Row.Login_Name
   if ($User.Contains("\")){
        $UserDomain =   $User.Split("\").Item(0)
        $Username = $User.Split("\").Item(1)
   }
   
   
   #$TmpUser  = New-Object -TypeName psobject  
   
   #$ADDetails = Get-ADuser -Identity $Username -Properties Manager
$ADDetails = $null
   
$ADDetails = Get-ADuser -Identity $Username -Properties Manager -ErrorAction SilentlyContinue
if ($ADDetails -ne $null) {
    $ADType = 'User'
}else{
    $ADDetails = Get-ADGroup -Identity $Username -ErrorAction SilentlyContinue
    if ($ADDetails -ne $null){
         $ADType = 'AD Group'
    }
}

#$ADDetails

   $FullName = $ADDetails.Name

   $Manager = $ADDetails.Manager.Split(",").Item(0).Replace('CN=','')
   Write-Host "   $User  $Manager  $ADType "

   $RowDetails | Add-Member -MemberType NoteProperty -Name DateCollected -Value   $Row.DateCollected
   $RowDetails | Add-Member -MemberType NoteProperty -Name ApplicationName -Value   $Row.ApplicationName
   $RowDetails | Add-Member -MemberType NoteProperty -Name Login_Name -Value   $Row.Login_Name
   $RowDetails | Add-Member -MemberType NoteProperty -Name FullName -Value   $FullName 
   $RowDetails | Add-Member -MemberType NoteProperty -Name ManagerName -Value   $Manager
   $RowDetails | Add-Member -MemberType NoteProperty -Name ADType -Value   $ADType
   $RowDetails | Add-Member -MemberType NoteProperty -Name role_name -Value   $Row.role_name

#   $Row | Add-Member -MemberType NoteProperty -Name FullName -Value   $ADDetails.Name
#   $Row | Add-Member -MemberType NoteProperty -Name ManagerName -Value $Manager
    [void] $UserObjs.Add($RowDetails )
}

$UserObjs | Select-Object -Property DateCollected, ApplicationName, Login_Name, FullName, ManagerName , ADType, role_name | Out-GridView 

Set-ItemProperty -InputObject $Row -Name ManagerName  -Value 'Blah'
