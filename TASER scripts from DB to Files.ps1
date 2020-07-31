<#

    .SYNOPSIS
    Returns TASER scripts from ReportServer database as individual script files

    .DESCRIPTION
    
	
    .PARAMETER 
        $TheScriptOutputPath - paths used for output files
    .PARAMETER 
        $ReportServerDB - name of ReportServer database
    .PARAMETER 
        $RecordLimit - number of TASER records to process
    .PARAMETER 
	    $SingleFileOutput - boolean value indicating whether to produce single file (otherwise multiple files are produced)
	
    .EXAMPLE
	& P:\!Powershell\Get-TASER_ScriptsByEmailSubject_v2.ps1

	.EXAMPLE
	# powershell.exe -noprofile -noninteractive "& 'C:\Program Files\AAS\Powershell\Get-TASER_ScriptsByEmailSubject_v4.ps1' ";
	# powershell.exe -noprofile -noninteractive "& 'C:\Program Files\AAS\Powershell\Get-TASER_ScriptsByEmailSubject_v05.ps1' -ReportServer LGHBDVDB15 -ReportSubscriptionsTable Dulux_deactivation ";
	# Dulux_deactivation

    .NOTES

    CHANGE HISTORY
    AUTHOR        DATE        Description     
    Vernon Crock  2017-02-08  Initial version
    
#>

Param(  
    # [string] $TheScriptOutputPath = "D:\Data\TASER SQL Scripts\" ,
    # [string] $TheScriptOutputPath = "C:\Temp\!TASER\TestScripts\" ,

    [string] $TheScriptOutputPath = "C:\Temp\TASER SQL Scripts\",
	
	#[string] $TheScriptOutputPath = "\\lghbdvdb15\D$\ITOPS\TaserOutput3\",
	#[string] $TheScriptOutputPath = "\\lghbdvdb15\INFO-Delivery\Scripts\TASER\",

    #[string] $TheScriptOutputPath = "S:\IT Strategy\BIDelivery\Backup\TASER\20170209\" ,

	# [string] $ReportServerDB = "ReportServer"
	
	#[string] $ReportServerDB = "ReportServer", 

    [string] $ReportServerDB = "LinkReports", 
    [string] $ScriptFromReportServer = "LGHBDB02", #= "LGHBDB02", # "LGHBDVDB06",  # "LGHBDB02", 
	[string] $ReportSubscriptionsTable = "ReportSubscriptions_Fix", 
	

    [string]$configGroupName = 'TASER.ScriptGeneration',
    [string]$ConfigServer='LGHBDVDB14',	

# \\lghbdvdb15\D$\ITOPS\TaserOutput3

	[int] $RecordLimit = 20000,  #0000,
	[bool] $SingleFileOutput = $false,
    [string] $EmailSubject = $null #"AustSuper Choice - Allocated Pension" #$null # 'AustralianSuper - Accumulation' #$null
)

####################################
## Establish script parameters
####################################


Set-StrictMode -Version Latest

$ErrorActionPreference = "Stop";

####################################
## Include required modules
####################################

import-module "C:\Program Files\AAS\Powershell\Modules\DataStructures_v2.psm1"
import-module "C:\Program Files\AAS\Powershell\Modules\SQLServer\SQLServer_Base_v4.psm1"
. "C:\Program Files\AAS\Powershell\Modules\BCP\BCP_Base_v4.ps1"
# get-module | format-table -autosize
# Get-Module SQLServer_Base_v3 -ListAvailable 

# #{ReportServerDB}


[Hashtable]$global:scriptConfigs = @{} #Initialise hashtable
[Hashtable]$Configs_MASTER = @{} #Initialise hashtable
[Hashtable]$Configs = @{} #Initialise hashtable

# Retrieve database-resident configurations
Get-BCPParamsIntoHashtable -theHashtable $Configs_MASTER -GroupName $ConfigGroupName -ConfigServer $ConfigServer
# $global:scriptConfigs

"Configurations Master entry used"
"--------------------------------"
$Configs_MASTER

Get-BCPParamsIntoHashtable -theHashtable $Configs -GroupName $Configs_MASTER['GroupNameToUse'] -ConfigServer $ConfigServer

"Configurations used"
"-------------------"
$Configs

#Override params with DB-based configs
$TheScriptOutputPath = $Configs['ScriptOutputPath']
$ReportServerDB = $Configs['ReportServerDB'] 
$ScriptFromReportServer = $Configs['ScriptFromReportServer'] 
$ReportSubscriptionsTable = $Configs['ReportSubscriptionsTable'] 
#return


$script = @"

USE [LinkReports]
GO

SET IDENTITY_INSERT [dbo].[ReportSubscriptions] ON 

GO


-- *** NOTE : When changing TASER reports, only the FOLLOWING section needs to be changed

DECLARE @ReportSubscriptionSKey INT = #{ReportSubscriptionSKey} -- Set this to NULL for new TASER

DECLARE @ReportName [varchar](300) = #{ReportName}
DECLARE @ReportParams [varchar](2000) = #{ReportParams}
DECLARE @EmailAddress [varchar](400) = #{EmailAddress}
DECLARE @SenderAddress [varchar](100) = #{SenderAddress}
DECLARE @EmailSubject [varchar](100) = #{EmailSubject}
DECLARE @CCList [varchar](200) = #{CCList}
DECLARE @BCCList [varchar](200) = #{BCCList}
DECLARE @FileOutputDir [varchar](400) = #{FileOutputDir} 
DECLARE @Format [varchar](20) = #{Format}
DECLARE @EmailMessage [varchar](500) = #{EmailMessage}
DECLARE @Timeout [int] = #{Timeout}
DECLARE @Enabled [bit] = #{Enabled}
DECLARE @CreatedBy [nvarchar](50) = #{CreatedBy} -- NOTE:- Put your username here for a new TASER only
--DECLARE @CreatedDate [datetime] = 
--DECLARE @LastRunTime [datetime] = 
DECLARE @DaysOfWeek [nvarchar](50) = #{DaysOfWeek}
DECLARE @DaysOfMonth [nvarchar](100) = #{DaysOfMonth}
DECLARE @Month [nvarchar](50) = #{Month}
DECLARE @MonthlyWeek [nvarchar](50) = #{MonthlyWeek}
DECLARE @Scope [nvarchar](50) = #{Scope}
DECLARE @ParallelismThread [nvarchar](50) = #{ParallelismThread}
DECLARE @ParallelismThreadOrder [int] = #{ParallelismThreadOrder}
DECLARE @ReportOutputName [varchar](300) = #{ReportOutputName}
DECLARE @HoldEmailUnlessError [char](1) = #{HoldEmailUnlessError}
DECLARE @SQLQueryName [varchar](100) = #{SQLQueryName}
DECLARE @SQLServer [varchar](50) = #{SQLServer}
DECLARE @SQLDatabase [varchar](50) = #{SQLDatabase}
DECLARE @SQLQuery [varchar](max) = #{SQLQuery}
DECLARE @ReportServerEnvironmentCode [varchar](20) = #{ReportServerEnvironmentCode}

-- *** NOTE : When changing TASER reports, only the ABOVE section needs to be changed



-- *** NOTE : START AUTOGENERATED / TEMPLATE CODE SECTION.  NO MANUAL CHANGES SHOULD BE MADE IN THIS SECTION.
DECLARE @ReportServerEnvironmentCode [varchar](20) = NULL
SELECT  @ReportServerEnvironmentCode = ReportServerEnvironmentCode   FROM ReportServerEnvironments WHERE ReportServerName = @@SERVERNAME


IF EXISTS (SELECT * FROM [dbo].[ReportSubscriptions]
	WHERE @ReportSubscriptionSKey IS NOT NULL 
	AND ReportSubscriptionSKey = ISNULL(@ReportSubscriptionSKey,-1))
BEGIN

	UPDATE [dbo].[ReportSubscriptions]
	SET 
		[ReportName] = @ReportName
		, [ReportParams] = @ReportParams
		, [EmailAddress] = @EmailAddress
		, [SenderAddress] = @SenderAddress
		, [EmailSubject] = @EmailSubject
		, [CCList] = @CCList
		, [BCCList] = @BCCList
		, [FileOutputDir] = @FileOutputDir
		, [Format] = @Format
		, [EmailMessage] = @EmailMessage
		, [Timeout] = @Timeout
		, [Enabled] = @Enabled
		--, [CreatedBy]
		--, [CreatedDate]
		--, [LastRunTime]
		, [DaysOfWeek] = @DaysOfWeek
		, [DaysOfMonth] = @DaysOfMonth
		, [Month] = @Month
		, [MonthlyWeek] = @MonthlyWeek
		, [Scope] = @Scope
		, [ParallelismThread] = @ParallelismThread
		, [ParallelismThreadOrder] = @ParallelismThreadOrder
		, [ReportOutputName] = @ReportOutputName
		, [HoldEmailUnlessError] = @HoldEmailUnlessError
		, [SQLQueryName] = @SQLQueryName
		, [SQLServer] = @SQLServer
		, [SQLDatabase] = @SQLDatabase
		, [SQLQuery] = @SQLQuery
		, [ReportServerEnvironmentCode] = @ReportServerEnvironmentCode
	WHERE ReportSubscriptionSKey = @ReportSubscriptionSKey
END

ELSE -- TASER doesn't exist yet

BEGIN

	--Attempt to insert into ReportSubscriptions using known ReportSubscriptionSKey if provided
	BEGIN TRY
		IF (@ReportSubscriptionSKey IS NOT NULL )
		BEGIN
			INSERT [dbo].[ReportSubscriptions] (
				[ReportSubscriptionSKey]
				, [ReportName]
				, [ReportParams]
				, [EmailAddress]
				, [SenderAddress]
				, [EmailSubject]
				, [CCList]
				, [BCCList]
				, [FileOutputDir]
				, [Format]
				, [EmailMessage]
				, [Timeout]
				, [Enabled]
				, [CreatedBy]
				--, [CreatedDate]
				--, [LastRunTime]
				, [DaysOfWeek]
				, [DaysOfMonth]
				, [Month]
				, [MonthlyWeek]
				, [Scope]
				, [ParallelismThread]
				, [ParallelismThreadOrder]
				, [ReportOutputName]
				, [HoldEmailUnlessError]
				, [SQLQueryName]
				, [SQLServer]
				, [SQLDatabase]
				, [SQLQuery]
				, [ReportServerEnvironmentCode]
			)
				VALUES ( -- Example values included
				@ReportSubscriptionSKey 
				, @ReportName ---N'/Operations Reporting/Suspense Reports/Employer Suspense - Detail'
				, @ReportParams --N'PlanSKey=149,PlanSKey=139,PlanSKey=132,PlanSKey=158,PlanSKey=156'
				, @EmailAddress --N'vernon.crock@aas.com.au, patrick.flynn@aas.com.au'
				, @SenderAddress --N'info_requests@aas.com.au'
				, @EmailSubject --N'Taser Test'
				, @CCList --NULL
				, @BCCList --NULL
				, @FileOutputDir --NULL
				, @Format --N'CSV'
				, @EmailMessage --N'/Operations Reporting/Suspense Reports/Employer Suspense - Detail'
				, @Timeout --30
				, @Enabled --1

				, @CreatedBy --N'APAC\crockve'
				--, CAST(N'2010-12-10 10:05:46.017' AS DateTime)
				--, CAST(N'2017-02-05 20:27:52.687' AS DateTime)

				, @DaysOfWeek --N'|Mon|Tue|Wed|Thu|Fri|Sat|Sun|'
				, @DaysOfMonth --NULL
				, @Month --NULL
				, @MonthlyWeek --NULL
				, @Scope --N'ODS'
				, @ParallelismThread --N'FinanceB'
				, @ParallelismThreadOrder --90
				, @ReportOutputName --N'Employer Suspense - Detail'
				, @HoldEmailUnlessError --N'0'
				, @SQLQueryName --NULL
				, @SQLServer --NULL
				, @SQLDatabase --NULL
				, @SQLQuery --NULL
				, @ReportServerEnvironmentCode --N'PROD2016_SSRS'
				)
			END
			ELSE --@ReportSubscriptionSKey IS NULL 
			BEGIN
                SELECT @ReportSubscriptionSKey= MAX(ReportSubscriptionSKey) + 1 FROM dbo.ReportSubscriptions
				INSERT [dbo].[ReportSubscriptions] (
				[ReportSubscriptionSKey]
				, [ReportName]
				, [ReportParams]
				, [EmailAddress]
				, [SenderAddress]
				, [EmailSubject]
				, [CCList]
				, [BCCList]
				, [FileOutputDir]
				, [Format]
				, [EmailMessage]
				, [Timeout]
				, [Enabled]
				, [CreatedBy]
				--, [CreatedDate]
				--, [LastRunTime]
				, [DaysOfWeek]
				, [DaysOfMonth]
				, [Month]
				, [MonthlyWeek]
				, [Scope]
				, [ParallelismThread]
				, [ParallelismThreadOrder]
				, [ReportOutputName]
				, [HoldEmailUnlessError]
				, [SQLQueryName]
				, [SQLServer]
				, [SQLDatabase]
				, [SQLQuery]
				, [ReportServerEnvironmentCode]
			)
				VALUES ( -- Example values included
				@ReportSubscriptionSKey 
				, @ReportName ---N'/Operations Reporting/Suspense Reports/Employer Suspense - Detail'
				, @ReportParams --N'PlanSKey=149,PlanSKey=139,PlanSKey=132,PlanSKey=158,PlanSKey=156'
				, @EmailAddress --N'vernon.crock@aas.com.au, patrick.flynn@aas.com.au'
				, @SenderAddress --N'info_requests@aas.com.au'
				, @EmailSubject --N'Taser Test'
				, @CCList --NULL
				, @BCCList --NULL
				, @FileOutputDir --NULL
				, @Format --N'CSV'
				, @EmailMessage --N'/Operations Reporting/Suspense Reports/Employer Suspense - Detail'
				, @Timeout --30
				, @Enabled --1

				, @CreatedBy --, N'APAC\crockve'
				--, CAST(N'2010-12-10 10:05:46.017' AS DateTime)
				--, CAST(N'2017-02-05 20:27:52.687' AS DateTime)

				, @DaysOfWeek --N'|Mon|Tue|Wed|Thu|Fri|Sat|Sun|'
				, @DaysOfMonth --NULL
				, @Month --NULL
				, @MonthlyWeek --NULL
				, @Scope --N'ODS'
				, @ParallelismThread --N'FinanceB'
				, @ParallelismThreadOrder --90
				, @ReportOutputName --N'Employer Suspense - Detail'
				, @HoldEmailUnlessError --N'0'
				, @SQLQueryName --NULL
				, @SQLServer --NULL
				, @SQLDatabase --NULL
				, @SQLQuery --NULL
				, @ReportServerEnvironmentCode --N'PROD2016_SSRS'
				)
			END
	END TRY
	BEGIN CATCH
		IF (ERROR_NUMBER() = 2627)  --Violation of PRIMARY KEY constraint  OR ERROR_NUMBER() = 2601) --2601 / unique index
		BEGIN
	
		INSERT [dbo].[ReportSubscriptions] (
			/* [ReportSubscriptionSKey], */ 
            [ReportName]
            , [ReportParams]
            , [EmailAddress]
            , [SenderAddress]
            , [EmailSubject]
            , [CCList]
            , [BCCList]
            , [FileOutputDir]
            , [Format]
            , [EmailMessage]
            , [Timeout]
            , [Enabled]
            , [CreatedBy]
            -- , [CreatedDate]
            -- , [LastRunTime]
            , [DaysOfWeek]
            , [DaysOfMonth]
            , [Month]
            , [MonthlyWeek]
            , [Scope]
            , [ParallelismThread]
            , [ParallelismThreadOrder]
            , [ReportOutputName]
            , [HoldEmailUnlessError]
            , [SQLQueryName]
            , [SQLServer]
            , [SQLDatabase]
            , [SQLQuery]
            , [ReportServerEnvironmentCode]
		)
			VALUES (/* -6662, */  -- Example values included
			    @ReportName ---N'/Operations Reporting/Suspense Reports/Employer Suspense - Detail'
				, @ReportParams --N'PlanSKey=149,PlanSKey=139,PlanSKey=132,PlanSKey=158,PlanSKey=156'
				, @EmailAddress --N'vernon.crock@aas.com.au, patrick.flynn@aas.com.au'
				, @SenderAddress --N'info_requests@aas.com.au'
				, @EmailSubject --N'Taser Test'
				, @CCList --NULL
				, @BCCList --NULL
				, @FileOutputDir --NULL
				, @Format --N'CSV'
				, @EmailMessage --N'/Operations Reporting/Suspense Reports/Employer Suspense - Detail'
				, @Timeout --30
				, @Enabled --1

				, @CreatedBy --N'APAC\crockve'
				--, CAST(N'2010-12-10 10:05:46.017' AS DateTime)
				--, CAST(N'2017-02-05 20:27:52.687' AS DateTime)

				, @DaysOfWeek --N'|Mon|Tue|Wed|Thu|Fri|Sat|Sun|'
				, @DaysOfMonth --NULL
				, @Month --NULL
				, @MonthlyWeek --NULL
				, @Scope --N'ODS'
				, @ParallelismThread --N'FinanceB'
				, @ParallelismThreadOrder --90
				, @ReportOutputName --N'Employer Suspense - Detail'
				, @HoldEmailUnlessError --N'0'
				, @SQLQueryName --NULL
				, @SQLServer --NULL
				, @SQLDatabase --NULL
				, @SQLQuery --NULL
				, @ReportServerEnvironmentCode --N'PROD2016_SSRS'
			)
		
		END

		ELSE
		BEGIN
            DECLARE @Msg VARCHAR(max) = 'Error ' + CONVERT(VARCHAR, ERROR_NUMBER() )
			PRINT @Msg
		END

	END CATCH

END
GO

SET IDENTITY_INSERT [dbo].[ReportSubscriptions] OFF 

GO

-- *** NOTE : END AUTOGENERATED / TEMPLATE CODE SECTION.  NO MANUAL CHANGES SHOULD BE MADE IN THE ABOVE SECTION.


"@

#Create the log path if it doesn't already exist
mkdir $TheScriptOutputPath -force | Out-null

# PS C:\Users\Vern> $mystr = "The value of the thing = $(if($fred -eq $null){"nully"}else{$([char]39)+$bert+$([char]39)}) is this"


$QuerySQL = "select top $($RecordLimit) * from dbo.$($ReportSubscriptionsTable) /* where ReportSubscriptionSKey >= 0*/ `
	/* order by ReportSubscriptionSKey desc */ where EmailSubject IS NOT NULL
        AND $( if(!$EmailSubject) {' (1 = 1) '}else{ 'LTRIM(EmailSubject) = LTRIM(' + $([char]39) + $EmailSubject + $([char]39) + ')' }<#else#> ) 
        /* AND EmailSubject = 'AustralianSuper - Accumulation' */
        /* AND EmailSubject = 'Kinetic SS EDI_Report' */
        /* AND EmailSubject = 'Tier Employer Data' */
        /* AND EmailSubject = 'TWU-SRF710-AASPIRE' */
        /* AND EmailSubject = ' Australian Super' */
        /* AND EmailSubject = 'Master Report - Care Super Industry' */
        /* AND EmailSubject = 'Transfer In by Transfer Type and From Fund - PRODR' */
        /* AND EmailSubject = 'TASER_Transfer Out Summary by Type and ''To'' Fund - PRODR' */
		/* AND EmailSubject = 'inbound_Call_Channel_member_Data_0073' */   /* ** PROBLEMATIC due to appended SQL ** */ 
		   /* AND EmailSubject = 'Tier Employer Data' */
			 
        /* AND ReportSubscriptionSKey = 3136 */
        /* AND ReportSubscriptionSKey = 6145 */
        /* AND ReportSubscriptionSKey = 2363 */
        /* AND ReportSubscriptionSKey = 3124 --Double-quote in EmailAddress */
        /* AND ReportSubscriptionSKey = 5155 --Single-quote in EmailAddress */
        /* AND ReportSubscriptionSKey = 7041 --NULL EmailMessage */
        /* AND ReportSubscriptionSKey = 6204 --NULL ReportName, Blank ReportParams */
        /* AND ReportSubscriptionSKey = 6739 --ParallelismThreadOrder 0, SQLQueryName blank */
    order by EmailSubject asc "

$QuerySQL

# return

$TASERS=@(Invoke-Query -servername $ScriptFromReportServer -dbname $ReportServerDB -sqlquery $QuerySQL -QueryTimeout 60)

# $TASERS.GetType()
# $TASERS | gm
# return

# $TASERS=(Invoke-Query $ScriptFromReportServer LinkReports `
# 	"select top $($RecordLimit) * from dbo.ReportSubscriptions /* where ReportSubscriptionSKey >= 0*/ `
# 	/* order by ReportSubscriptionSKey desc */ where EmailSubject IS NOT NULL `
#         AND $( if(!$EmailSubject) {' (1 = 1) '}else{ 'LTRIM(EmailSubject) = LTRIM(' + $([char]39) + $EmailSubject + $([char]39) + ')' }<#else#> )  `
#         /* AND EmailSubject = 'AustralianSuper - Accumulation' */ `
#     order by EmailSubject asc " 60)

# if(!$TASERS){"No matching TASERs"; return;}else {$TASERS}

############################
# Output each TASER script
############################

$i = 0
$singlefile_content = ""
$singlefile_name = "."
$EmailSubject_prev = $null
$script_for_output = ""
$TASERS | % { 

    # Write out previous file if needed
    if ( ($i -ne 0) -and ($_.EmailSubject.ToString() -ne $EmailSubject_prev ) -and ($EmailSubject_prev -ne $null) -and (-not $SingleFileOutput )) {
        #$singlefile_name = "TASER_" + ( $_.EmailSubject.ToString() -replace "/" , "-" ) + ".sql"

    }



	#"Scripting ReportSubscriptionSKey $($_.ReportSubscriptionSKey)..."

    if ( $_.EmailSubject.ToString() -ne $EmailSubject_prev ) {
        "Scripting TASER $($i+1)/$($TASERS.Count) : $($_.EmailSubject )..."
        $script_for_output = "" # Start afresh
        $thisfile_name = "TASER_" + (((( $_.EmailSubject.ToString() -replace "/" , "-" ) -replace "\[" , "(" ) -replace "\]" , ")" )  -replace ":" , "-" ) + ".sql"
        $thisfile_name_incpath = "$($TheScriptOutputPath)\$($thisfile_name)"
        "    - output to : $thisfile_name_incpath"
    }

    # $singlefile_name = "TASER_" + ( $_.EmailSubject.ToString() -replace "

	# if (is-null($_.ReportName))   { $ReportNameText = "NULL"} else { $ReportNameText = $_.ReportName }
	# if (is-null($_.ReportParams)) { $ReportParamsText = "NULL"} else { $ReportParamsText = $_.ReportParams }
	# if (is-null($_.EmailAddress)) { $EmailAddressText = "NULL"} else { $EmailAddressText = $_.EmailAddress }
	# if (is-null($_.SenderAddress)) { $SenderAddressText = "NULL"} else { $SenderAddressText = $_.SenderAddress }
	# if (is-null($_.EmailSubject)) { EmailSubjectText = "NULL"} else { EmailSubjectText = $_.EmailSubject }
	# if (is-null($_.CCList)) { $CCListText = "NULL"} else { $CCListText = $_.CCList }
	# if (is-null($_.BCCList)) { $BCCListText = "NULL"} else { $BCCListText = $_.BCCList }
	
	$ReportNameText =  &{ if ([System.DBNull]::Value -eq $_.ReportName) { 'NULL' } else { "'$( $_.ReportName  -replace "'", "''" )'" } } #Get-SQLSafeNULLString ( $_.ReportName -replace "'", "''" )
	$ReportParamsText = &{ if ([System.DBNull]::Value -eq $_.ReportParams) { 'NULL' } else { "'$( $_.ReportParams  -replace "'", "''" )'" } }            #Get-SQLSafeNULLString ( $_.ReportParams  -replace "'", "''" )
	$EmailAddressText = &{ if ([System.DBNull]::Value -eq $_.EmailAddress) { 'NULL' } else { "'$( $_.EmailAddress -replace "'", "''" )'" } }            #Get-SQLSafeNULLString ( $_.EmailAddress -replace "'", "''" )
	$SenderAddressText = &{ if ([System.DBNull]::Value -eq $_.SenderAddress) { 'NULL' } else { "'$( $_.SenderAddress -replace "'", "''" )'" } }            #( Get-SQLSafeNULLString( $_.SenderAddress ) -replace "'", "''" )
	$EmailSubjectText = &{ if ([System.DBNull]::Value -eq $_.EmailSubject) { 'NULL' } else { "'$( $_.EmailSubject  -replace "'", "''" )'" } } #Get-SQLSafeNULLString ( $_.EmailSubject ) -replace "'", "''" )
	$CCListText = &{ if ([System.DBNull]::Value -eq $_.CCList) { 'NULL' } else { "'$( $_.CCList  -replace "'", "''"  )'" } }            #( Get-SQLSafeNULLString ( $_.CCList ) -replace "'", "''" )
	$BCCListText = &{ if ([System.DBNull]::Value -eq $_.BCCList) { 'NULL' } else { "'$( $_.BCCList -replace "'", "''" )'" } }            #( Get-SQLSafeNULLString ( $_.BCCList ) -replace "'", "''" )
    $FileOutputDirText = Get-SQLSafeNULLString ($_.FileOutputDir)
    <#
    if(-not $_.Format.Trim() -eq ""){
        $FormatText = "'" + $_.Format + "'" # non-nullable field
    }else{
        $FormatText = "''"
    }
    #>
    $FormatText = &{ if ([System.DBNull]::Value -eq $_.Format) { 'NULL' } else { "'$( $_.Format  -replace "'", "''" )'" } } #Get-SQLSafeNULLString ($_.Format)
	$EmailMessageText = &{ if ([System.DBNull]::Value -eq $_.EmailMessage) { 'NULL' } else { "'$( $_.EmailMessage -replace "'", "''" )'" } } #Get-SQLSafeNULLString ( $_.EmailMessage -replace "'", "''" )
    $TimeoutText = &{ if ([System.DBNull]::Value -eq $_.Timeout) { 'NULL' } else { "$($_.Timeout)" } }            #Get-SQLSafeNULLString ($_.Timeout)
    $EnabledText = &{ if ([System.DBNull]::Value -eq $_.Enabled) { 'NULL' } else { [int32]0+$_.Enabled } }            #Get-SQLSafeNULLString ($_.Enabled)
    <#
    If (-not $_.Enabled){
        $EnabledText = "NULL"
    }else{
        $EnabledText = $_.Enabled.ToString()
    }
    #>

    $CreatedByText = Get-SQLSafeNULLString (($_.CreatedBy -replace "'", "''" )  )

	$DaysOfWeekText = Get-SQLSafeNULLString ($_.DaysOfWeek)
	$DaysOfMonthText = Get-SQLSafeNULLString ($_.DaysOfMonth)
	$MonthText = Get-SQLSafeNULLString ($_.Month)
	$MonthlyWeekText = Get-SQLSafeNULLString ($_.MonthlyWeek)
	$ScopeText = Get-SQLSafeNULLString ($_.Scope)
	$ParallelismThreadText = Get-SQLSafeNULLString ($_.ParallelismThread)
	$ParallelismThreadOrderText = Get-SQLSafeNULLString ($_.ParallelismThreadOrder)
	$ReportOutputNameText = &{ if ([System.DBNull]::Value -eq $_.ReportOutputName) { 'NULL' } else { "'$( $_.ReportOutputName -replace "'", "''" )'" } }            #Get-SQLSafeNULLString ( $_.ReportOutputName -replace "'", "''" )
	$HoldEmailUnlessErrorText = Get-SQLSafeNULLString ($_.HoldEmailUnlessError)
	$SQLQueryNameText = Get-SQLSafeNULLString ($_.SQLQueryName)
	$SQLServerText = Get-SQLSafeNULLString ($_.SQLServer)
	$SQLDatabaseText = Get-SQLSafeNULLString ($_.SQLDatabase)
	
	$DollarCharRegex = '\$'
	$DollarCharReplacement = '`' + '$'
	# $SQLQueryText = &{ if ([System.DBNull]::Value -eq $_.SQLQuery) { 'NULL' } else { "'$($_.SQLQuery -replace "'", "''" )' " -replace $DollarCharRegex,  $DollarCharReplacement   }}           #Get-SQLSafeNULLString ($_.SQLQuery -replace "'", "''" ))
	$SQLQueryText = &{ if ([System.DBNull]::Value -eq $_.SQLQuery) { 'NULL' } else { "'$($_.SQLQuery -replace "'", "''" )' " }}           #Get-SQLSafeNULLString ($_.SQLQuery -replace "'", "''" ))
	
	$ReportServerEnvironmentCodeText = Get-SQLSafeNULLString ($_.ReportServerEnvironmentCode)

	$script_final = ( $script -replace '#{ReportSubscriptionSKey}', $_.ReportSubscriptionSKey )

	$script_final = ( $script_final -replace '#{ReportServerDB}', $ReportServerDB )


	$script_final = ( $script_final -replace '#{ReportName}', $ReportNameText )
	$script_final = ( $script_final -replace '#{ReportParams}', $ReportParamsText )
	$script_final = ( $script_final -replace '#{EmailAddress}', $EmailAddressText )
	$script_final = ( $script_final -replace '#{SenderAddress}', $SenderAddressText )
	$script_final = ( $script_final -replace '#{EmailSubject}', $EmailSubjectText )
	$script_final = ( $script_final -replace '#{CCList}', $CCListText )
	$script_final = ( $script_final -replace '#{BCCList}', $BCCListText )
	$script_final = ( $script_final -replace '#{FileOutputDir}', $FileOutputDirText )
	$script_final = ( $script_final -replace '#{Format}', $FormatText )
	$script_final = ( $script_final -replace '#{EmailMessage}', $EmailMessageText )

	$script_final = ( $script_final -replace '#{Timeout}', $TimeoutText )
	$script_final = ( $script_final -replace '#{Enabled}', $EnabledText )
    $script_final = ( $script_final -replace '#{CreatedBy}', $CreatedByText )

	$script_final = ( $script_final -replace '#{DaysOfWeek}', $DaysOfWeekText )
	$script_final = ( $script_final -replace '#{DaysOfMonth}', $DaysOfMonthText )
	$script_final = ( $script_final -replace '#{Month}', $MonthText )
	$script_final = ( $script_final -replace '#{MonthlyWeek}', $MonthlyWeekText )
	$script_final = ( $script_final -replace '#{Scope}', $ScopeText )
	$script_final = ( $script_final -replace '#{ParallelismThread}', $ParallelismThreadText )
	$script_final = ( $script_final -replace '#{ParallelismThreadOrder}', $ParallelismThreadOrderText )

	$script_final = ( $script_final -replace '#{ReportOutputName}', $ReportOutputNameText )
	$script_final = ( $script_final -replace '#{HoldEmailUnlessError}', $HoldEmailUnlessErrorText )


	$script_final = ( $script_final -replace '#{SQLQueryName}', $SQLQueryNameText )
	$script_final = ( $script_final -replace '#{SQLDatabase}', $SQLDatabaseText )
	$script_final = ( $script_final -replace '#{SQLServer}', $SQLServerText )
	$script_final = ( $script_final -replace '#{SQLQuery}', $SQLQueryText )
	$script_final = ( $script_final -replace '#{ReportServerEnvironmentCode}', $ReportServerEnvironmentCodeText )


    $script_for_output += $script_final

    #$script_for_output

<#
DECLARE @EmailAddress [varchar](400) = #{EmailAddress}
DECLARE @SenderAddress [varchar](100) = #{SenderAddress}
DECLARE @EmailSubject [varchar](100) = #{EmailSubject}
DECLARE @CCList [varchar](200) = #{CCList}
DECLARE @BCCList [varchar](200) = #{BCCList}
DECLARE @FileOutputDir [varchar](400) = #{FileOutputDir} 
DECLARE @Format [varchar](20) = #{Format}
DECLARE @EmailMessage [varchar](500) = #{EmailMessage}
DECLARE @Timeout [int] = #{Timeout}
DECLARE @Enabled [bit] = #{Enabled}
--DECLARE @CreatedBy [nvarchar](50) = 
--DECLARE @CreatedDate [datetime] = 
--DECLARE @LastRunTime [datetime] = 
DECLARE @DaysOfWeek [nvarchar](50) = #{DaysOfWeek}
DECLARE @DaysOfMonth [nvarchar](100) = #{DaysOfMonth}
DECLARE @Month [nvarchar](50) = #{Month}
DECLARE @MonthlyWeek [nvarchar](50) = #{MonthlyWeek}
DECLARE @Scope [nvarchar](50) = #{Scope}
DECLARE @ParallelismThread [nvarchar](50) = #{ParallelismThread}
DECLARE @ParallelismThreadOrder [int] = 
DECLARE @ReportOutputName [varchar](300) = #{ReportOutputName}
DECLARE @HoldEmailUnlessError [char](1) = #{HoldEmailUnlessError}
DECLARE @SQLQueryName [varchar](100) = #{SQLQueryName}
DECLARE @SQLServer [varchar](50) = #{SQLServer}
DECLARE @SQLDatabase [varchar](50) = #{SQLDatabase}
DECLARE @SQLQuery [varchar](max) = #{SQLQuery}
DECLARE @ReportServerEnvironmentCode [varchar](20) = #{ReportServerEnvironmentCode}

#>

	#if ( $_.ReportSubscriptionSKey -lt 0 ) {
	#	$script_final | Out-File "P:\!Powershell\TASEROutput\TASER_Minus_$($_.ReportSubscriptionSKey).sql" -force
	#}else{
		# P:\!Powershell\TASEROutput\
		
		If (-not $SingleFileOutput){
			# $script_final | Out-File "$($TheScriptOutputPath)\TASER_$($_.ReportSubscriptionSKey).sql" -force
            $script_for_output | Out-File $($thisfile_name_incpath) -force
		}
        else { #SingleFile
			$singlefile_content += $script_final + "`r`n`r`n"
		}

		# $script_final | Out-File "\\lgnrisi01-corp-smb\SQL_Backups\ITOps\SQLServer\Scripts\TASER\TASER_$($_.ReportSubscriptionSKey).sql" -force

	#}


    # Loop termination
    $EmailSubject_prev = $_.EmailSubject.ToString()
	$i++

}#for-each

If ( $SingleFileOutput ){
	$singlefile_outputfile = "$($TheScriptOutputPath)\TASER_combined_$(get-date -f yyyyMMdd_HHmmss).sql"
	# $singlefile_content | Out-File "$($singlefile_outputfile)" -force
    
    "Scripted to $($singlefile_outputfile)."
}else{
    #write out final file

}
"Scripting complete to $($TheScriptOutputPath)."

<#

[ReportName] = '#{ReportName}'
		, [ReportParams] = ''
		, [EmailAddress] = ''
		, [SenderAddress] = ''
		, [EmailSubject] = ''
		, [CCList] = ''
		, [BCCList] = ''
		, [FileOutputDir] = ''
		, [Format] = ''
		, [EmailMessage] = ''
		, [Timeout] = 
		, [Enabled] = 
		--, [CreatedBy]
		--, [CreatedDate]
		--, [LastRunTime]
		, [DaysOfWeek] = ''
		, [DaysOfMonth] = ''
		, [Month] = ''
		, [MonthlyWeek] = ''
		, [Scope] = ''
		, [ParallelismThread] = ''
		, [ParallelismThreadOrder] = 
		, [ReportOutputName] = ''
		, [HoldEmailUnlessError] = 
		, [SQLQueryName] = ''
		, [SQLServer] = ''
		, [SQLDatabase] = ''
		, [SQLQuery] = ''
		, [ReportServerEnvironmentCode] = ''
#>

