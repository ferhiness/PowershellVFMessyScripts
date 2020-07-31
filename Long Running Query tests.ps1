

Get-DbaDiskSpace -ComputerName LGHBDB03 
Get-DbaDiskSpace -ComputerName LGHBVDEV077
'D:\  DATA  250.00 GB'
Get-DbaOperatingSystem -ComputerName LGHBVDEV077


Function JobStatusAccountLongRunningQuery{
         [CmdletBinding(SupportsShouldProcess = $True)]  
           Param(
               [Parameter(ValueFromPipeline,Mandatory)]  #ByPropertyName
                  [Alias('ComputerName')]
                [string] $SqlInstance
            )
            begin{}
            process{

                $QuerySQL = "SELECT s.login_name,s.session_id, s.host_name As SourcePC, s.[dd hh:mm:ss.mss],s.database_name QueryDatabase, collection_time As SessionDateTime, sql_text As Queryrun
                 ,cast(left(s.[dd hh:mm:ss.mss] ,2) as int) * 86400 +  datediff(SECOND,0,cast(right(s.[dd hh:mm:ss.mss], 12) as time)) AS TimeiSecs
                 --datediff(hour,0,cast(right(s.[dd hh:mm:ss.mss], 12) as time)) AS Timeinhrs from s where cast(left(s.[dd hh:mm:ss.mss],2) as int) * 24+ datediff(hour,0,cast(right(s.[dd hh:mm:ss.mss], 12) as time))
                 FROM [WarehouseTemp].dbo.monitor_session s
                 JOIN DBA_Metrics.[dbo].[RG_ExceptionList] E on s.login_name = E.AccountID AND E.RGGroup = 'JobStatus'
                 WHERE collection_time BETWEEN DATEADD(MI,-3,GETDATE()) AND GETDATE()
                 AND cast(left(s.[dd hh:mm:ss.mss] ,2) as int) * 86400 +  datediff(SECOND,0,cast(right(s.[dd hh:mm:ss.mss], 12) as time)) > 120
                "
                $InvalidRGExceptionUsage = Invoke-DbaQuery -SqlInstance $SqlInstance -Database DBA_Metrics -Query $QuerySQL
                if ($InvalidRGExceptionUsage){
                         $InvalidRGExceptionUsage | ForEach-Object {Write-Host "Test"}
                         {$SessionID = $_.session_id
                          $Username = $_.login_name
                          Write-Host "Killing session $SessionID"
                          }
                    }
                }

        }end{}
}
