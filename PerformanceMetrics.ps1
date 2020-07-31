#Powershell performance System Counters

#Processor
# Get-Help Get-Counter -Detailed



Get-Counter -Counter "\Processor(_Total)\% Processor Time" -Continuous -ComputerName LGHBDB17
Get-Counter -Counter "\Processor(_Total)\% Processor Time" -ComputerName LGHBDB17 -SampleInterval 30 -MaxSamples 3

# Using list set - 
Get-Counter -ListSet "Processor"  -ComputerName LGHBDB17
$p = Get-Counter -ListSet "Processor"  -ComputerName LGHBDB17
$m = Get-Counter -ListSet "Memory"  -ComputerName LGHBDB17
Get-Counter -ListSet "SQLServer:Access Methods"  -ComputerName LGHBDB17
Get-Counter -ListSet * | Where-Object $_.CounterSetName like "SQL"

$ctr = Get-Counter -ComputerName LGHBDB17 - Counter  "\Processor(_Total)\% Processor Time"  -SampleInterval 30 -MaxSamples 5
$ctr | Get-Member 


  #  Export-Counter 
  #  Import-Counter 

$ctr|   Export-Clixml -Path "C:\Temp\Counterexp.xml"

$newctr = Import-Clixml -Path  "C:\Temp\Counterexp.xml"  
$ Run counters on the monitored system for 24 hrs
# then export &  import into an analysis database
# 

# U can then use counters from the List Set
Get-Counter -Counter 
# memory
#Paging File 


# Physival Disk - On SSDs it shd be 5 millisecs or less but can use 20 ms as a baseline
# Tells u how long SQL server has to wait to come off physical disk

# Processor Queue Lengtth - How long does the process have to wait to get time n the CPU
# e.g if u have more threads per process than u have CPU's, it could be a problem


### SQL Server counters

#1. Forwarded recs/sec - Applicable When u have heaps i.e. tables without clustered indexes
#                        An update causes the data to move pages & a pointer sits in the old page
#                        ALTER TALE REBUILD fixes fragmentation but needs to be done during downtime


#2. PageSplits/sec    - Fragmentiation of data . Page splits are time consuming.
#                       U are better off using the time to do a reorg or a rebuild during a maintenance window
#                       Jonathan Kehayias bolg on extended events

#3. Buffer Manager - Page Life expectatncy - Running DBCC CHECKDB  drops Page Life expectancy to 0
#                   But if Page life expectatncy drops tp 0 in the middle of biz day, then question it.


# Excessive blocking - Create a baseline & chheck for blocking

# SQL Compilations/sec 7 SQL Recompilatins/sec




