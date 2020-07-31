PARAM
(
    [Parameter(Mandatory = $true)]
    [String]$HostName = (gc Env:\COMPUTERNAME),

    [Parameter(Mandatory = $true)]
    [String]$JobName = [String]::Empty
);

if([String]::IsNullOrEmpty($JobName))
{
    Write-Host "`nNo job name provided.  Provide a job name using the -JobName parameter.`n";
    #Exit;
}

# Load SMO and instantiate the server object
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") |Out-Null;
[Microsoft.SqlServer.Management.Smo.Server]$sqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server $HostName;


if([String]::IsNullOrEmpty($sqlServer.Urn))
{
    Write-Host "`nThe hostname provided is not a valid SQL Server instance.  Did you mistype the alias or forget to add the instance name?`n";
    #Exit;
}

[Microsoft.SqlServer.Management.Smo.Agent.Job]$job = ($sqlServer.JobServer.Jobs | ? { $_.Name -eq $JobName });

if($job -eq $null)
{
    Write-Host "`nNo such job on the server.`n";
    #Exit;
}

# Job is Found so invoke it
#$job.Start();