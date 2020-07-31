
$From = 'info_requests@aas.com.au'
$To = 'vanessa.fernandes@aas.com.au'
$smtp= 'smtp.linkgroup.corp' 

$email = New-Object System.Net.Mail.MailMessage  

#$email.CC.Add('REST_Client_Partnership@aas.com.au')
#$email.CC.Add('HESTASuperFundMemberServices@aas.com.au')
#$email.CC.Add('MTAASuperServices@aas.com.au')
#$email.CC.Add('NTRUST_Reports@aas.com.au')
#$email.CC.Add('NSW_Business_Adherence@aas.com.au')
#$email.CC.Add('multifundspensionsadmin@aas.com.au')
#$email.CC.Add('AustralianSuperInsurance@superpartners.com.au')
#$email.CC.Add('austsafecpteam@aas.com.au')
#$email.CC.Add('CLUBPLUS_Reports@aas.com.au')
#$email.CC.Add('FundAccountants_AASIndustry@linkgroup.com')
#$email.CC.Add('ITProductionControl@superpartners.com.au')
#$email.CC.Add('MIC.Team@aas.com.au')
#$email.CC.Add('vanessa.fernandes@aas.com.au')
$email.CC.Add('LGS_Administration@aas.com.au')

$email.From = $From
$email.Subject = "TASER Issues"
$email.Body = 'Hi All,

Due to an issue with the TASER system, SSRS reports will be delayed.
As soon as the issue is resolved, we will start sending out TASERs.

'

$email.Headers.Add("Disposition-Notification-To","vanessa.fernandes@aas.com.au")
$email.Priority = 'High'
$smtp = new-object Net.Mail.SmtpClient($smtp) 
$smtp.Send($email) 
