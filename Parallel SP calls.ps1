##############################################################

$startTime =  Get-Date 

#Get current day of week, based on converted start time 
$currentDayOfWeek = [Int]($startTime).DayOfWeek 
Write-Output "Current day of week: $currentDayOfWeek." | timestamp 

$startTime.DayOfWeek
#[Int] ($startTime.AddDays(2)).DayOfWeek 
#############################################################


#This script creates a number of connections (one per entry in $Commands) 
# to a SQL Server instance ($Server) and database ($DBName)
#Driver variables


#Set Initial collections and objects    
$Server= "LGHBDVDB15" ; #Server to connect to
$DBName = "Linkreports" ; #Database to connect to
$SPCall = 'USE [LinkReports]
GO

DECLARE @RC int
DECLARE @ReportSubscriptionSKey int = <<>SubNo>
DECLARE @UseTestOption smallint = 0
DECLARE @Retval int
DECLARE @ExceptionString nvarchar(4000)
DECLARE @ReportServerEnvironmentCode varchar(20)

EXECUTE @RC = [dbo].[RunTaserSubscriptions] 
   @ReportSubscriptionSKey
  ,@UseTestOption
  ,@Retval OUTPUT
  ,@ExceptionString OUTPUT
  ,@ReportServerEnvironmentCode OUTPUT
GO
'

$SQLGetSubs = "SELECT * FROM LinkReports.dbo.ReportSubscriptions
WHERE ReportSubscriptionSkey IN  (9399,4894,1932,4893,-6662, 6661, 7215, 6738, 1825, 4892)"



$TaserList = Invoke-DbaQuery -SqlInstance $Server -Database $DBName -Query $SQLGetSubs 
#$Taser = $TaserList[0]
$Commands =  New-Object -TypeName 'System.Collections.ArrayList';

foreach ($Taser in $TaserList){
$Commands.Add($SPCall.Replace('<<>SubNo>', $Taser.ReportSubscriptionSKey))
}

#$ProcedureCall = $Commands[0]
workflow Test-Workflow
{
    #Run commands in parallel.
    Parallel
    {
        Get-Process
        Get-Service
    }

    ForEach -Parallel ($ProcedureCall in $Commands)
    {
      Invoke-DbaQuery -SqlInstance $Server -Database $DBName -Query $ProcedureCall
    }

}


#$Commands += "EXEC sp_LogMe 'a'"
#$Commands += "EXEC sp_LogMe 'b'"

$Commands.Count
#ForEach -Parallel 

#Loop through commands array, create script block for establishing SMO connection/query
#Start-Job for each script block
foreach ($sql in $Commands ) {

# All of that extra information after "Smo" tells it to load just v12 (for when you have multiple
#   versions of SQL installed.)  Note: V13 is 2016.
 $cmdstr =@"
`Add-Type -AssemblyName "Microsoft.SqlServer.Smo,Version=$(13).0.0.0,Culture=neutral,PublicKeyToken=89845dcd8080cc91"
`[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
`$SqlConn = New-Object Microsoft.SqlServer.Management.Smo.Server ("$Server")
`$SqlConn.Databases["$DBName"].ExecuteNonQuery("$sql")
"@

#Uncomment the next like to print the command string for debugging
# $cmdstr
#Execute script block in jobs to run the command asyncronously
$cmd = [ScriptBlock]::Create($cmdstr)
Start-Job -ScriptBlock $cmd
}
