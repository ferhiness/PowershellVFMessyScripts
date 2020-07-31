$Fund = 'AustralianSuper' #AustralianSuper (Darren.Tansey@aas.com.au)
$PlanIds = "'BF,BG'" #'BF,BG'
$Region = 'SOUTH'
$RecipientName = 'Darren'


$Fund = 'REST' #AustralianSuper (Peter)
$PlanIds = "'RS'" #'BF,BG'
$Region = 'REST'
$RecipientName = 'Peter'

$DirectoryToSaveTo="C:\Temp"
$Filename="$DirectoryToSaveTo\$Fund-OpenClaimsData.xlsx"

 
If (Test-Path $Filename){

	Remove-Item $Filename
}

$From = 'vanessa.fernandes@aas.com.au'
$To = 'vanessa.fernandes@aas.com.au'
$smtpserver= 'smtp.linkgroup.corp' 

$Query = "EXEC dbo.spGetOpenClaimsData @Plan=N$PlanIds, @Region=N'$Region',@IncludeAaspireData=0"

$Data = Invoke-DbaQuery -SqlInstance PRDLGDWDB1 -Database Staging -Query $Query

#Find-Module -Name ImportExcel | Install-Module

#Import-Module -Name ImportExcel
#$Data | ConvertTo-Csv 

#GEt-Command -Module ImportExcel
$Data | Export-Excel -Path $Filename -AutoSize -TitleBackgroundColor Blue -BoldTopRow  -KillExcel
#Set-Format -Range 'A1:BR1' 

#sendemail($From, $To , $Fund, , $smtp, $DirectoryToSaveTo )

$email = New-Object System.Net.Mail.MailMessage  

$email.From = 'vanessa.fernandes@aas.com.au'##$From

$email.BCC.Add( $To)
#$email.To.Add('Patrick.Flynn@aas.com.au')
#$email.CC.Add('pmah@empirics.com.au')
#$email.CC.Add('Briallen.Britt@aas.com.au')


if ($Fund.Contains('REST')) {
 $email.To.Add('Peter.Blomfield@linkgroup.com')
 #$email.To.Add('Colette.Mamo@aas.com.au')
 #$email.To.Add('Katie-Lee.Bilbija@aas.com.au')
}
if ($Fund.Contains('AustralianSuper')) {
 $email.To.Add('Darren.Tansey@aas.com.au')
}

$email.Subject = "$Fund Open Claims Report"
#$email.Body = '
##Hi,
#Open Claims Data is attached. 
#Please note this is a manual run. The issue still remains unresolved & needs to be escalated to Peter Mah.
#It has been assigned to Briallen Britt to be resolved. 
#I have now been informaed that it has now been raised as a P1 issue assigned to Bree Britt on 24th July 2019.
#We were informed that this would be addressed in 2 - 3  weeks time.
#It is now a month. Can someone please update Peter & Darren on the status of thier requests?
#
#Kindest regards,
#Vanessa Fernandes
#'
$email.Body = "
Hi $RecipientName,
Open Claims Data for $Fund is attached. 
The task has already been assigned to Bree Britt from Peter Mahs team on 24th July 2019.
This is a one off manual run.

Kindest regards,
Vanessa Fernandes
"

$emailAttach = New-Object System.Net.Mail.Attachment $Filename
$email.Attachments.Add($emailAttach)  
#$email.DeliveryNotificationOptions  = "OnFailure"
$email.Headers.Add("Disposition-Notification-To","vanessa.fernandes@aas.com.au")
$email.Priority = 'High'
$smtp = new-object Net.Mail.SmtpClient($smtpserver) 

$smtp.Send($email) 

#sendEmail -emailFrom $From -emailTo $To  -subject "$Fund Details" -body "Data Attached " -smtpServer $smtp -filePath $Filename



##########################Function Version


function Generate-OpenClaimsReport {
 param( [string]$Fund, [string]$PlanIds,[string]$Region, [string]$DirectoryToSaveTo )
 
if( !(Test-Path $DirectoryToSaveTo)){ New-Item -ItemType Directory -Path $DirectoryToSaveTo}
$Filename="$DirectoryToSaveTo\$Fund-OpenClaimsData.xlsx"

$From = 'info_requests@aas.com.au'
$To = 'vanessa.fernandes@aas.com.au'
$To2 = 'Patrick.Flynn@aas.com.au'
$smtp= 'smtp.linkgroup.corp' 

$Query = "EXEC dbo.spGetOpenClaimsData @Plan=N$PlanIds, @Region=N'$Region',@IncludeAaspireData=0"

$Data = Invoke-DbaQuery -SqlInstance PRDLGDWDB1 -Database Staging -Query $Query
if ($Data) {
    $Data | Export-Excel -Path $Filename -AutoSize -TitleBackgroundColor Blue -BoldTopRow 
}else{Write-Error 'No data to export'}

$email = New-Object System.Net.Mail.MailMessage  

$email.From = $From
$email.To.Add( $To)
#$email.To.Add( $To2)
$email.Subject = "$Fund Open Claims Report"
#$email.Body = '
#Hi,
#
#Open Claims Data is attached. 
#Australian Super -  Darren.Tansey@aas.com.au, 
#REST - Peter.Blomfield@linkgroup.com;Colette.Mamo@aas.com.au;Katie-Lee.Bilbija@aas.com.au
#'

$emailAttach = New-Object System.Net.Mail.Attachment $Filename

$email.Attachments.Add($emailAttach)  

$smtp = new-object Net.Mail.SmtpClient($smtpserver) 

$smtp.Send($email) 

}

Generate-OpenClaimsReport -Fund "REST" -PlanIds "'RS'" -Region "REST" -DirectoryToSaveTo "c:\Temp"
Generate-OpenClaimsReport -Fund "REST" -PlanIds "RS" -Region "REST" -DirectoryToSaveTo "c:\Temp"










Function sendEmail([string]$emailFrom, [string]$emailTo, [string]$subject,[string]$body,[string]$smtpServer,[string]$filePath) 
{ 
#initate message 
$email = New-Object System.Net.Mail.MailMessage  
$email.From = $emailFrom 
$email.To.Add($emailTo) 
$email.Subject = $subject 
$email.Body = $body 
# initiate email attachment  
$emailAttach = New-Object System.Net.Mail.Attachment $filePath 
$email.Attachments.Add($emailAttach)  
#initiate sending email  
$smtp = new-object Net.Mail.SmtpClient($smtpServer) 
$smtp.Send($email) 
} 