param( 
	  [string]$InputJson
	 ,[string]$OutputJson
	 ,[string]$SourceEP
	 ,[string]$TargetEP
	 ,[string]$RenameTaskTo
	 ,[string]$TaskName
	 ,[string]$AddTables_CSV_file
	 ,[string]$NewTables_CSV_file
	 ,[string]$Owner_default = "dbo"
	 ,[switch]$Reference
	 ,[switch]$DeleteEP
	 ,[switch]$DeleteTasks
	 ,[switch]$NotSortTables
	 ,[switch]$TaskOverview
	 ,[switch]$EPOverview
	 ,[switch]$SectionOverview
	 ,[switch]$DeleteSection
	 ,[string]$SectionName
	 ,[switch]$help
	 )
$comments = 'MODIFY_REPLICATE_JSON - ' 
$csv_header = "tableName", "owner";
$help_text = @"

modify_replicate_json.ps1 - Hein van den Heuvel - Attunity - 18-Feb-2017

    This script is used to process a task JSON from one environment to be imported
    on an other environment, for example from DEV to QA to PROD. 
    
    Typically the Endpoints must NOT be carried over as existing endpoint on 
    the targetted server will be used with a different target database(server)
    and different credentials.
    
    We also expect that the endpoint name as well as the taskname will need to be
    changed according to the naming standards in place to match the new environment.
    
    This scripts can adapt the following elements in a Replication Definition
    
    - Remove Databases section ( Endpoints ) should they exist,
          failing to remove could make existing endpoint unoperational on import.
    - Sort explicit included tables by owner,name
    - Remove original UUID if present.
    - Change Task Name
    - Adaption of End-Points to provided new source and target names
    - Remove Tasks section
    - List top-level sections. Typically: 
          tasks, databases, replication_environment, notifications, error_behavior, scheduler
    - Remove specified top-level section
    - Add or Replace Explicitly selected table
    
    IF the switch "Reference" is used, then NO contents change is done.
    The purpose of this is to generate a template going through the same 
    formatting for easy comparisons with tools like WinDiff
    
    Options:
    
    -InputJson          Required input file, with single task or full Replication_Definition 
    -OutputJson         Name of output Json file formatted similar to Replicate, but not exactly the same.
    -SourceEP           New Name for Source Endpoint (aka "database") IF single task.
    -TargetEP           New Name for Target Endpoint IF single task.
    -TaskName           TaskName to act on, if not the first and only task.
    -RenameTaskTo       New Name for Task IF single task.
    -SectionName        Name of json section to act on.
    -AddTables_CSV_file Name of CSV file with tables to ADD to the current tables in task
    -NewTables_CSV_file Name of CSV file with tables to REPLACE the current tables in task with

    -- Switches -- 
	
    -Reference          Generate unchanged contents with script specifix formatting for comparisons
    -NotSortTables      Stop the script from Sorting the explicitly included table list.
    -DeleteEP           Remove the "databases" section from the InputJson
    -DeleteTasks        Remove the "tasks" section from the InputJson
    -DeleteSection      Request removal of json section identified by -SectionName
	
    -TaskOverview       List Tasks in the json file.
    -EPOverview         List Databases (End Points) section in the json file
    -SectionOverview    List the sections in the json file, useful as quick verification.
    -help               This text
	
"@

$tmp = $PSVersionTable.PSVersion.Major
if (($InputJson.toupper() -eq 'HELP') -or ($help) ) { $help_text; exit }
if ($tmp -lt 3) { "PowerShell Version is $tmp. Need version 3 or better (for -raw and convert-json)" ; exit}
if ( -not $InputJson ) { "** Must provide Input Json file as first param, or with -InputJson"; exit }

if (-not (Test-Path $InputJson)) { 
	$tmp = $InputJson + ".json"# try adding .json if not found
	if (  Test-Path $tmp) { 
		$InputJson = $tmp
		} else {
			"** Could not find Mandatory Input Json file <$InputJson>"
			exit
		}
	}
if ((Get-Item $InputJson).length -gt 2mb) { ""; "** warning Input > 2Mb, may need to adjust maxJsonLength in web.config?" }

if ($AddTables_CSV_file) {
	if ($NewTables_CSV_file) { "** Add and New Tables CSV files are mutually exclusive"; exit }
	$DriverFile = $AddTables_CSV_file
	$csv_operation = 'adding'
}
if ($NewTables_CSV_file) { $DriverFile = $NewTables_CSV_file; $csv_operation = 'replacing by'; }
if ($DriverFile) {
	if ( -not (Test-Path $DriverFile)) { "** Tables CSV File <$DriverFile> NOT found."; exit }
}

# Force non-terminating errors to be treated as terminating errors and stops execution.
#$ErrorActionPreference = 'Stop'
$DateTime = (Get-Date -Format "yyyy-MM-dd HH:mm")
$EP_to_rename = @{}   # Empty associative array


$my_json_string = Get-Content $InputJson -Raw
$my_json_string = $my_json_string -replace "^//.*\n", "" # Remove comment line(s)
$my_json_object = ConvertFrom-Json $my_json_string

if ($TaskOverview) {
	" "
	$format = '    {0,-25} {1,-25} {2,-25}'
	Write-Output ($format -f 'Task_ Name', 'Source EP', 'Target EP')
	Write-Output ($format -f '--------------------', '--------------------', '--------------------')
	foreach ($task in $my_json_object."cmd.replication_definition".tasks) {
		Write-Output ($format -f $task.task.name, $task.source.rep_source.source_name, $task.task.target_names[0])
	}
}

if ($EPOverview) {

	$uses = @{}
	foreach ($task in $my_json_object."cmd.replication_definition".tasks) {
		$uses[ $task.source.rep_source.source_name ] += ', ' + $task.task.name
		$uses[ $task.task.target_names[0] ] += ', ' + $task.task.name
	}

	" "
	$format = '    {0,-25} {1,-6} {2,-3} {3,-12} {4,-40}'
	Write-Output ($format -f 'EndPoint Name', 'Role', 'Lic', 'Type', 'Used By...')
	Write-Output ($format -f '--------------------', '------', '---', '--------', '------------','----------------------------------------')
	foreach ($ep in $my_json_object."cmd.replication_definition".databases) {
		if( $ep.is_licensed ) {$licensed = 'Yes'} else {$licensed = 'No'}
		$type = ($ep.type_id -replace '_COMPONENT_TYPE','') + '         ' # RMS    
		$used_by = $uses[ $ep.name ] -replace "^, ",""
		Write-Output ($format -f $ep.name, $ep.role, $licensed, $type.substring(0,12), $used_by)
	}
}

if ($SectionOverview) { # Section Overview requested?
	" "
	if ($SectionName -eq '') { # NO Optional name to drill deeper?
		$my_json_object."cmd.replication_definition".PSObject.Properties.name
	} else {
		$my_json_object."cmd.replication_definition".$SectionName.PSObject.Properties.name
	}
}

if ($SectionOverview -or $TaskOverview -or $EPOverview) { " "; exit}

if (-not $OutputJson) { "*** Must provide Output JSON file name as second parameter or with -OutputJson"; exit }

if ($Reference) {
	$TaskName = "N.A."
	$comments += "REFERENCE-RUN "
	Write-Output "-- No changes, generating Reference file for change comparisons"
} else { # Not generating a Reference

	if ($DeleteSection) {
		if ($SectionName -eq '') {
			"** Must have section name to Delete. Use -SectionOverview for list"
		} else {
			$comments += "DELETE:$SectionName "  
			"-- $SectionName removed from $InputJson, output into $OutputJson"
			$my_json_object."cmd.replication_definition".PSObject.Properties.Remove($SectionName)
			$my_json_object."cmd.replication_definition".$SectionName.PSObject.Properties.name
		}
	}
	if ($DeleteTasks) {
		$comments += 'DELETE-TASK ' 
		"-- All tasks removed from $InputJson, output into $OutputJson"
		$my_json_object."cmd.replication_definition".PSObject.Properties.Remove('tasks')
	} else { 
	  $count = $my_json_object."cmd.replication_definition".tasks.count
	  $single_task = $TargetEP + $SourceEP + $RenameTaskTo + $DriverFile +$TaskName
	  if ($count -eq 1 -or $single_task -ne '') {
		if ($count -eq 1) { # Just one? Fine.
			$task = $my_json_object."cmd.replication_definition".tasks[0]
		} else {
			if ($TaskName -eq '') {
				"** Input file <$InputJson> has $count tasks. Please provide task name"
				exit
			} else {
				foreach ($task in $my_json_object."cmd.replication_definition".tasks) {
					if ($TaskName -eq $task.task.name) { break }
				}
			}
		}
		if ($TaskName -eq '') {
			$TaskName = $task.task.name
		} else {
			if ($TaskName -ne $task.task.name) { "** Task <$TaskName> NOT found in $InputJson"; exit}
		}

		# Better safe than sorry
		#
		$task.task_settings.common_settings.Psobject.Properties.Remove('task_uuid')

		if ($RenameTaskTo -ne '') { $task.task.name = $RenameTaskTo }
		#$task.task.description = "Attunity Replication for $TaskName`n"

		if ($SourceEP -ne '') {
			$EP_to_rename.($task.task.source_name) = $SourceEP
			$task.task.source_name  = "$SourceEP"
			$task.source.rep_source.source_name  = "$SourceEP"
			$task.source.rep_source.database_name  = "$SourceEP"
			$task.source.source_tables.name  = "$SourceEP"
		}

		if ($TargetEP -ne '') {
			$EP_to_rename.($task.targets[0].rep_target.target_name) = $TargetEP
			$task.targets[0].rep_target.target_name = "$TargetEP"
			$task.targets[0].rep_target.database_name = "$TargetEP"
			$task.task.target_names = @( "$TargetEP" )  # Array
		}

		#
		# Change/Add Explicitly selected tables array?
		#
		if ($DriverFile) { # Read Driver File; Filter; Convert; Trust-but-verify the order
			# Really should get ready to sort all the way : TASK + OWNER + TABLE + COLUMN
			#
			$csv_object = Get-Content $DriverFile | Where-Object {$_ -match "^\w+"} | ConvertFrom-Csv -header $csv_header | Sort-Object -Property TableName
			$csv_length = $csv_object.length  # Powershell created string instead of array for one-liners.
			if (-not $csv_length ) {"** no (or just 1) useable lines from CSV file $DriverFile"; $csv_object; exit}
			# Even a bare-bones new task will have "source_tables", but not "explicit_included_tables"
			# So let's check for that.
			#
			#			"task":	{...
			#			"source":	{
			#				"source_tables":	{
			#					"explicit_included_tables":	[{
			#debug- $task.source.source_tables.name
			$tables = @{}
			$explicit = $task.source.source_tables.explicit_included_tables
			if ($explicit -eq $null) {
				$count = "no"
			} else {
				$count = $explicit.count
				if ($count) {
					foreach ($table in $explicit) { # Create an associative-array of existing tables
						$tables[$table.owner + '.' + $table.name] = 1
					}
				}	
			}
			Write-output "-- Found $count Tables in $TaskName, $csv_operation $csv_length Tables."
			
			if ($NewTables_CSV_file -ne '') {
				$task.source.source_tables.PSObject.Properties.Remove('explicit_included_tables')
			}

			foreach ($csv in $csv_object ) {
		#debug		if ($i++ -ge 10) {break}
				$table  = $csv.tablename  # Parse out an Owner?
				if ($table -match "^\w+\.\w+$") {
					$owner = $table -replace "\.\w+$",""
					$table = $table -replace "^\w+\.",""
				}
				if (-not $owner) { $owner  = $csv.owner }
				if (-not $owner) { $owner  = $Owner_default }
				if ($tables[$owner + '.' + $table]) {
					$exist++;
				} else {			# "New Table $owner $table"
					$tables[$owner + '.' + $table] = 1 # Now it exists
					$prop = @{name=$table; owner=$owner} 
					if ($task.source.source_tables.explicit_included_tables -eq $null) { # First table evva?
						$task.source.source_tables | Add-Member explicit_included_tables @((New-Object pscustomobject -Property $prop))
					} else { # Have one more tables already 
						$task.source.source_tables.explicit_included_tables += New-Object pscustomobject -Property $prop # Add new table
					}
				}
			} # csv loop
			if ($exist) { write-output "-- $exist Tables out of $csv_length already existed"}
		} # DriverFile with tables to add or replace?

		#
		# Sort an report on tables.
		#
		$explicit = $task.source.source_tables.explicit_included_tables
		if ( $explicit -eq $null ) {
			"-- $TaskName - No Explicit_included_tables section"
		} else {
			$tmp = 'sorted.'
			if ( $NotSortTables) { # Sort Tables?
				$tmp = 'NOT sorted.'
			} else {
				$task.source.source_tables.explicit_included_tables = $explicit | Sort-Object name
			}
			$count = $explicit.count
			"-- $TaskName - $count Explicit_included_tables $tmp"
		}
	  } # Single Task?
	} # DeleteTasks ?

	#
	# Database aka EndPoint section
	#
	if ($my_json_object."cmd.replication_definition".databases -eq $null) {
		"No End-Points defined in $InputJson"
	} else {
		if ($DeleteEP) {
			$comments += 'DELETE-ENDPOINTS ' 
			"-- All End Points removed from $InputJson, output into $OutputJson"
			$my_json_object."cmd.replication_definition".PSObject.Properties.Remove('databases')
		} else {
			if ($EP_to_rename.count -gt 0) {
				foreach ($ep_name in $EP_to_rename.keys) {
					foreach ($ep in $my_json_object."cmd.replication_definition".databases) {
						if ($ep_name -eq $ep.name) {
							$ep.name = $EP_to_rename[$ep_name]
							$ep.db_settings.password = 'Not Valid'
							$ep_name = ''
							break
						} 
					} # each database_name
				if ($ep_name -ne '') { "-- Could not find old EP $ep_name in databases." }
				} # each EP to renames
			} # Any EP to rename?
		} # Keep databases section?
	} # Was there a databases section?
} # Reference?

# 136-spaces,  8 tabs;  127 spaces= 7 tabs; 110=7,  83=6
# `r = CR
# `n = LF

#
# To convert back to JSON it is critical to request to go deep, to get the whole structure.
# After we get the string, we massage it a lot to look more like the Replicate Export format.
# Notably we want it to
# *  Be Unix style LF lines terminators, not windows default CR-LF
# *  Use TABS rather than spaces.
# * Glue certain multilineconstructs like },<CR><LF>{ into a single line
# note: "emptyStringValue" may have a space between quotes which we must not convert, that why the script looks for <tab>spaces<quote> or <colon>spaces<quote>
#
$new_json_string = "// $comments OldName=$TaskName input=$InputJson Time:$DateTime `n"
$new_json_string += ConvertTo-Json $my_json_object -depth 99 
#$new_json_string | out-file -FilePath $OutputJson -encoding ASCII
#exit
$new_json_string = $new_json_string  -replace "},\r\n +{", "}, {"  -replace "\[\r\n +{", "[{" -replace "}\r\n +]", "}]" -replace "`r`n","`n"
$new_json_string = $new_json_string -replace "`n {136}","`n`t`t`t`t`t`t`t`t" -replace "`n {127}","`n`t`t`t`t`t`t`t" -replace "`n {110}","`n`t`t`t`t`t`t`t" -replace "`n {83}","`n`t`t`t`t`t`t"
$new_json_string  -replace "`": +","`":`t"  -replace "\t +`"","`t`t`""  -replace " {8}", "`t" -replace "\\u0027","'" | out-file -FilePath $OutputJson -encoding ASCII  # "

$cmds = Get-Command -Module dbatools
$cmds.count
Update-Module dbatools
