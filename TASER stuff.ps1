$SQLGetTASERList = "
SELECT * FROM [dbo].[GetTaserSubscriptions] (
   GETDATE()
  ,GETDATE()
  ,'ODS'
  ,'MidnightA')
  WHERE SQLQuery IS NOT NULL AND SQLQuery <> ''
"
$TASERSQLTest = 'select * from LinkReports.dbo.ReportSubscriptions where ReportSubscriptionSkey =  5022'
$TASERList = Invoke-DbaQuery -SqlInstance LGHBDB02 -Database LinkReports -Query  $TASERSQLTest

$DirectoryToSaveTo="C:\Temp\TASER\"

$TASERList = Invoke-DbaQuery -SqlInstance LGHBDB02 -Database LinkReports -Query  $SQLGetTASERList
$TASER = $TASERList[0]

foreach ($TASER in $TASERList){
    $SQLGetTASERQuery = $TASER.SQLQuery
    $ReportOutputName = $TASER.ReportOutputName
    #$ReportoutputPath = $TASER.FileOutputDir
    $RecipientList = $TASER.EmailAddress 
    if ($TASER.CCList) {$CCList = $TASER.CCList}
    $SQLDataBase = $TASER.SQLDatabase
    $SQLServer = $TASER.SQLServer
    $SenderAddress = $TASER.SenderAddress
    $ReportSubscriptionSKey = $TASER.ReportSubscriptionSKey
    $ReplyToAddress = 'vanessa.fernandes@aas.com.au'
    $EmailMessage = 'Doe to issues with TASEr server, SSRS based TASERs will be delayed. your report for ' +  $TASER.EmailSubject + ' is attached.'
    $Filename = $DirectoryToSaveTo + $ReportOutputName + '.xlsx'

    $Data = Invoke-DbaQuery -SqlInstance $SQLServer -Database $SQLDataBase -Query $SQLGetTASERQuery

    $Data | Export-Excel -Path $Filename -AutoSize -TitleBackgroundColor Blue -BoldTopRow  -KillExcel

    $email.From = 'Issue_info_requests@aas.com.au'
    $email.Subject = $TASER.EmailSubject

    $email = New-Object System.Net.Mail.MailMessage  
    $email.To.Add('vanessa.fernandes@aas.com.au' )
    $email.Body = $EmailMessage
    $email.Sender = $SenderAddress
    $email.ReplyTo = $ReplyToAddress
    
    $emailAttach = New-Object System.Net.Mail.Attachment $Filename

    $email.Attachments.Add($emailAttach)  
    #$email.DeliveryNotificationOptions  = "OnFailure"
    $email.Headers.Add("Disposition-Notification-To","vanessa.fernandes@aas.com.au")
    $email.Priority = 'High'
    $smtp = new-object Net.Mail.SmtpClient($smtp) 
    $smtp.Send($email) 

}

