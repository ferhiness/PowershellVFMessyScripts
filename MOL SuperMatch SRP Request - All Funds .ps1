
$sender = 'info_requests@aas.com.au'
$Fromdate = '2019-08-25'
$Todate = '2019-08-26'
$ToAddresses = 'bmcneil@linkgroup.com','operationssupportteam@aas.com.au','sue.pearce@linkgroup.com','mrea@linkgroup.com','Rahul.Mewada@linkgroup.com','hannayappa@linkgroup.com'
$BCCAdfress = 'vanessa.fernandes@aas.com.au'
$Subject = "MOL SuperMatch SRP Request - All Funds "

$SQL = "EXEC  GetMOLSuperMatchSRPRequestDate @fromDAte = '$Fromdate', @ToDate = '$Todate'"

$FileDateStamp = $Todate.Replace('-','')
$DirectoryToSaveTo="C:\Temp"
$filename =  "$DirectoryToSaveTo\MOL SuperMatch SRP Request - All Funds_$FileDateStamp.csv"


If (Test-Path $Filename){

	Remove-Item $Filename
}


$smtpserver= 'smtp.linkgroup.corp' 


$Data = Invoke-DbaQuery -SqlInstance PRDLGDWRODB1 -Database ODSMemberCentre -Query $SQl

$Data | Export-Csv -Path $filename 


$email = New-Object System.Net.Mail.MailMessage  
#$email.To.Add($ToAddresses)
$ToAddresses | ForEach  {$email.To.Add($_)}

$email.BCC.Add('vanessa.fernandes@aas.com.au')
$email.From = $sender
$email.Subject = $Subject 
$email.Body = "MOL SuperMatch SRP Request for All Funds

Report Subscription ID: 8950

Regards
Information Delivery
"

$emailAttach = New-Object System.Net.Mail.Attachment $Filename
$email.Attachments.Add($emailAttach)  
$email.Headers.Add("Disposition-Notification-To","vanessa.fernandes@aas.com.au")


$smtp = new-object Net.Mail.SmtpClient($smtpserver) 

$smtp.Send($email) 



