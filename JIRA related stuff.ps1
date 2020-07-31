Install-Module JiraPS

Set-JiraConfigServer "https://jira/"

New-JiraSession

Get-Command -Module JiraPS

$JIRAIssue = Get-JiraIssue -Key "IT-50593"
#$JIRAIssue.comment.Add("Test comment",)
#Get-Help Get-JiraIssueComment 
#Get-Help Add-JiraIssueComment 
#Get-Help Add-JiraIssueWorklog
Get-JiraIssueComment -Issue "IT-50593"
Add-JiraIssueComment -Issue  "IT-50593" -Comment "This is a test comment"
$DS = GET-Date -Format O
Add-JiraIssueWorklog -Issue "IT-50593" -Comment "Adding a test log" -DateStarted ($DS) -TimeSpent "00:01"

# Add-JiraIssueWorklog -Issue "IT-50595" -Comment "AASMA Manual file processing" -TimeSpent "0.5"
# Add-JiraIssueWorklog : Cannot process argument transformation on parameter 'TimeSpent'. Cannot convert value "0.5" to 
# type "System.TimeSpan". Error: "String was not recognized as a valid TimeSpan."
# At line:1 char:91
#
#
$JIRAIssue.Key
$logs = $JIRAIssue.worklog.worklogs
$logs[0]

$JIRATable =  $TASERObjs|  Format-Jira RevisionNo, ReportSubSkey, EmailSubject 
$JIRAComment = "Deployed TASErs for Revision`n"  +$JIRATable 
Add-JiraIssueComment  -Comment  $JIRAComment -Issue IT-51371

