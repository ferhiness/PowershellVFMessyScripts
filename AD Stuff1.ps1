function Get-ADPrincipalGroupMembershipRecursive( ) {

    Param(
        [string] $dsn,
        [array]$groups = @()
    )

    $obj = Get-ADObject $dsn -Properties memberOf

    foreach( $groupDsn in $obj.memberOf ) {

        $tmpGrp = Get-ADObject $groupDsn -Properties memberOf

        if( ($groups | where { $_.DistinguishedName -eq $groupDsn }).Count -eq 0 ) {
            $groups +=  $tmpGrp           
            $groups = Get-ADPrincipalGroupMembershipRecursive $groupDsn $groups
        }
    }

    return $groups
}

# Simple Example of how to use the function
$username = "Fujadmin"
$groups   = Get-ADPrincipalGroupMembershipRecursive (Get-ADUser $username).DistinguishedName
$groups | Sort-Object -Property name | Format-Table


Get-Command -Module ActiveDirectory

Get-ADuser -Identity fernava 
Get-ADuser -Identity fernava  -Properties memberof
Get-ADuser -Identity fernava  -Properties memberof
Get-ADUser -Identity svc_ctm  -properties *

$AccountExpires.ToDateTime(1)
[DateTime]::MaxValue.Ticks



if(($AccountExpires -eq 0) -or ($AccountExpires -gt [DateTime]::MaxValue.Ticks)) {
        $AcctExpires = "Never"
    } else {
        $Date = [DateTime]$AccountExpires
        $AcctExpires = $Date.AddYears(1600).ToLocalTime()
    }

	
$AllUsers = Get-ADuser -Filter *

$GroupsVF = (Get-ADuser -Identity fernava -Properties memberof).memberof 
$GroupsAB = (Get-ADuser -Identity bajajan -Properties memberof).memberof 
$GroupsVF.Count
$GroupsAB.Count

Get-ADGroupMember -Identity 'Rsc-SvnRepo-pega-rw'  -Recursive | Get-ADUser -Property DisplayName | Select Name,ObjectClass,DisplayName

Get-ADGroupMember -Identity "ITServiceDelivery" -Recursive
Get-ADGroupMember -identity "Users_lgnrba01_Superannuation_Maritz" -Recursive | Get-ADUser -Property DisplayName | Select Name,ObjectClass,DisplayName
Get-ADGroupMember -identity "Digital_Solutions_BSD_SN" -Recursive | Get-ADUser -Property DisplayName | Select Name,ObjectClass,DisplayName
Get-ADGroupMember -identity "ITOPS_SQL_DBA_SN" -Recursive | Get-ADUser -Property DisplayName | Select Name,ObjectClass,DisplayName


$groups = Get-ADGroup -filter *
$groups.Count
$groups[0]
$groups[200]
$List = Get-ADGroupMember -identity $groups[200].Name -Recursive | Get-ADUser -Property DisplayName | Select Name,ObjectClass,SamAccountName,Enabled

Write-Host $groups[0].Name " " $List

foreach($group in $groups){
    
}





$AccountListQuery = "SELECT * FROM [Security].[DomainAccounts_Original] WHERE AccountName  LIKE 'APAC\%'"

$Accounts = Invoke-DbaQuery -SqlInstance LGHBDB12 -Database 'UserAccounts' -Query $AccountListQuery
# $Account = $Accounts[0]
$AccountDetails = New-Object -TypeName 'System.Collections.ArrayList';

foreach ($Account in $Accounts){
  $DomainAccount = $Account.AccountName.Split("\")[1]
  $AccountExpirationDate =  Get-ADUser -Identity $DomainAccount  -properties *  -ErrorAction SilentlyContinue | Select AccountExpirationDate
  Write-Host  $DomainAccount  $AccountExpirationDate.AccountExpirationDate
  $obj=new-object PSObject -Property @{AccountName=$Account.AccountName ;Password=$Account.Password; ServerRestriction=$Account.ServerRestriction; AccountExpirationDate=$AccountExpirationDate.AccountExpirationDate} 
   $AccountDetails.Add($obj)
   $SQlUpdate = "UPDATE [Security].[DomainAccounts2] SET AccountExpirationDate = '"+$AccountExpirationDate.AccountExpirationDate+ "' WHERE AccountName = '" + $Account.AccountName+ "'"

  

}
$AccountDetails | Where{$_.AccountExpirationDate} | ForEach-Object {
     $SQlUpdate = "UPDATE [Security].[DomainAccounts2] SET AccountExpirationDate = '"+$_.AccountExpirationDate + "' WHERE AccountName = '" + $_.name+ "'"
      $SQlUpdate
      Invoke-DbaQuery -SqlInstance LGHBDB12 -Database 'UserAccounts' -Query  $SQlUpdate
}


 Get-ADUser -Identity SQL_LGHBDVDB05_svc -Properties * | Select AccountExpirationDate
 $AE = (Get-ADUser -Identity SQL_LGHBDVDB05_svc -Properties AccountExpires).AccountExpires
If (( $AE -eq 0) -or ( $AE -gt [DateTime]::MaxValue.Ticks))
{
    $AcctExpires = "Never"
}
Else
{
    $Date = [DateTime] $AE
    $AcctExpires = $Date.AddYears(1600).ToLocalTime()
}
"Account Expires $AcctExpires"

 #| Select AccountExpires


