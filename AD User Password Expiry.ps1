$AccountListQuery = "SELECT * FROM [Security].[DomainAccounts] WHERE AccountName  LIKE 'APAC\%'"

$AccountListQuery = "SELECT * FROM [Security].[DomainAccounts_Original] WHERE AccountName  LIKE 'APAC\%'"

$Accounts = Invoke-DbaQuery -SqlInstance LGHBDB12 -Database 'UserAccounts' -Query $AccountListQuery
# $Account = $Accounts[0]
$AccountDetails = New-Object -TypeName 'System.Collections.ArrayList';

foreach ($Account in $Accounts){
  $DomainAccount = $Account.AccountName.Split("\")[1]
  $Acc = Get-ADUser -Identity $DomainAccount  -properties *  -ErrorAction SilentlyContinue


  $AccountExpirationDate = $Acc.AccountExpirationDate  #Get-ADUser -Identity $DomainAccount  -properties *  -ErrorAction SilentlyContinue | Select AccountExpirationDate
  $AE = $Acc.accountExpires

  If (( $AE -eq 0) -or ( $AE -gt [DateTime]::MaxValue.Ticks))
  {
    $AcctExpires = "NULL"
  }Else
  { #$Date = [DateTime] $AE
    #$AcctExpires = [DateTim] ($Date.AddYears(1600).ToLocalTime()).GetType() 
    $AcctExpires = $Acc.AccountExpirationDate
  }

  if($Acc.Manager)
  {$ManagerEmail= (Get-AdUser (Get-aduser $DomainAccount -properties manager).manager -properties emailaddress).EmailAddress
  }
  #$HasManager = if ((Get-aduser $DomainAccount -properties manager).Manager) {"Manager exists"} else {"No manager"}
  Write-Host  $DomainAccount  $AccountExpirationDate.AccountExpirationDate $ManagerEmail
  $obj=new-object PSObject -Property @{AccountName=$Account.AccountName ;AccountOwner=$ManagerEmail;Password=$Account.Password; ServerRestriction=$Account.ServerRestriction; AccountExpirationDate=$AcctExpires} 
   $AccountDetails.Add($obj)
  # $SQlUpdate = "UPDATE [Security].[DomainAccounts2] SET AccountExpirationDate = '"+$AccountExpirationDate.AccountExpirationDate+ "', AccountOwner= '"+ $ManagerEmail + "' WHERE AccountName = '" + $Account.AccountName+ "'"

}

#Get-ADUser -Identity svc_LGHBDVDB24 -properties * | select Displayname, Givenname, Surname, Enabled, EmployeeNumber, EmailAddress, Department, StreetAddress, Title, Country, Office, employeeType, SID, @{Name="ManagerEmail";Expression={(get-aduser -property emailaddress $_.manager).emailaddress}}


$AccountDetails |Where{$_.AccountExpirationDate -ne 'NULL'} |
 ForEach-Object {
     $SQlUpdate = "UPDATE [Security].[DomainAccounts2] SET AccountExpirationDate = '"+$_.AccountExpirationDate + "' , AccountOwner= '" + $_.AccountOwner + "' WHERE AccountName = '" + $_.AccountName+ "'"
      $SQlUpdate
      Invoke-DbaQuery -SqlInstance LGHBDB12 -Database 'UserAccounts' -Query  $SQlUpdate
}


 Get-ADUser -Identity sql_TaserSSRSUAT_svc -Properties * | Select AccountExpirationDate
 $AE = (Get-ADUser -Identity sql_TaserSSRSUAT_svc -Properties AccountExpires).AccountExpires
If (( $AE -eq 0) -or ( $AE -gt [DateTime]::MaxValue.Ticks))
{
    $AcctExpires = "Never"
}
Else
{
    $Date = [DateTime] $AE
    $AcctExpires = [DateTime] ($Date.AddYears(1600).ToLocalTime())
}
"Account Expires $AcctExpires"

 #| Select AccountExpires

# $AccountDetails[0]

 $AccountDetails |  ForEach-Object {
    if ($_.AccountExpirationDate){
     $SQlUpdate = "UPDATE [Security].[DomainAccounts2] SET AccountExpirationDate = '"+ $_.AccountExpirationDate + "' WHERE AccountName = '" + $_.AccountName+ "'"
      $SQlUpdate
     }else {   $SQlUpdate = "UPDATE [Security].[DomainAccounts2] SET AccountExpirationDate = "+ $_.AccountExpirationDate + " WHERE AccountName = '" + $_.AccountName+ "'" } 
      Invoke-DbaQuery -SqlInstance LGHBDB12 -Database 'UserAccounts' -Query  $SQlUpdate

}