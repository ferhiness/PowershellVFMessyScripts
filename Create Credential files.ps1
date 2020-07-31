$SNOWCredentialsFile = 'C:\Temp\SNOWCredentials.xml'

# if the file does not exist Create it by asking for credentails
$SNOWCredentials = Get-Credential -Message "Enter SNOW login credentials"
$SNOWCredentials | EXPORT-CLIXML $SNOWCredentialsFile -Force

# if exists The read the file
$SNOWCredentials = IMPORT-CLIXML $SNOWCredentialsFile

# test that your password is the same in caseu updated network password recently
#$SNOWUsername = $SNOWCredentials.UserName
#$SNOWPassword = $SNOWCredentials.GetNetworkCredential().Password


## Now try connecting to Service Now

$HeaderAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $SNOWUsername, $SNOWPassword)))
$SNOWSessionHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$SNOWSessionHeader.Add('Authorization',('Basic {0}' -f $HeaderAuth))
$SNOWSessionHeader.Add('Accept','application/json')
$Type = "application/json"


$IncidentListURL = $SNOWURL+"api/now/table/incident"
Try 
{
$IncidentListJSON = Invoke-RestMethod -Method GET -Uri $IncidentListURL -TimeoutSec 100 -Headers $SNOWSessionHeader -ContentType $Type
$IncidentList = $IncidentListJSON.result
}
Catch 
{
Write-Host $_.Exception.ToString()
$error[0] | Format-List -Force
}



# the path to stored credential
$Servername = "LGHBDVDB05"
$Domain = "APAC"
$Username = "fernava"
$credPath = "C:\VF Queries\Queries\DBA Stuff\Credentials\Cred_$Username_$Servername.xml"
$Password = Input-String "Password for " + $Servername

$PWSQL = ConvertTo-SecureString -String $password -AsPlainText -Force
$SQLCredential = New-Object System.Management.Automation.PSCredential($username,$PWSQL) 


# check for stored credential
if ( Test-Path $credPath ) {
    #crendetial is stored, load it 
    $cred = Import-CliXml -Path $credPath
} else {
    # no stored credential: create store, get credential and save it
    $parent = split-path $credpath -parent
    if ( -not test-Path $parent) {
        New-Item -ItemType Directory -Force -Path $parent
    }
    $cred = get-credential
    $cred | Export-CliXml -Path $credPath
}
