New-JiraSession

$CDCJIRA = "IT-52536"

$CDCJIRAIssue =  Get-JiraIssue -Key $CDCJIRA 

$CDCJIRAIssue
$Test1 = $CDCJIRAIssue.worklog.worklogs | Where-Object {$_.author -like '*fernava*' }
#$A = [datetime] $Test1[0].started.GetType( )

$LastEntryDate = [datetime] ($CDCJIRAIssue.worklog.worklogs | Where-Object {$_.author -like '*fernava*' } | Measure-Object -Maximum started | Select-Object Maximum).Maximum

#$Logs =  $CDCJIRAIssue.worklog.worklogs | Where-Object {$_.started -ge '2019-03-18T05:00:00.000+1100' }

$Logs =  $CDCJIRAIssue.worklog.worklogs | Where-Object {[datetime] $_.started -ge $LastEntryDate  }

$log =  $Logs[0]

foreach($log in $logs){
 $Comment = $log.comment
 $TimeSpent = New-TimeSpan -Seconds ($log.timeSpentSeconds)

 $DS = $log.started
 Add-JiraIssueWorklog -Issue $CDCJIRAIssue -Comment "Deployed and tested TASERs " -DateStarted ($DS) -TimeSpent $TimeSpent 
}