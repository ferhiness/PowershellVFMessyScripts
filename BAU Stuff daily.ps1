#AUAZEJH001.apac.linkgroup.corp                   #LGHBCDCPOC
#$server = 'AUAZECCPDB001'
#$server = 'AUAZEDVDB005'
#$server = 'LGHBDB27'

$server = 'auerdsnp001'
$server = 'aueodsdvap001'
$server = 'AUAZEDVDB006'
$server = 'LGHBDB12'
$server = 'LGHBCDCPOC'
$server = 'LGHBDB14'
$server = 'LGNRDB14'
$server = 'LGHBDB17'
$server = 'LGHBDB02'
$server = 'LGNRDB02'
$server = 'LGNRDB03'
$server = 'LGNRDB04' #Encore+
$server = 'oc-syd-sql-dr4.miracle.local'
#Azure servers
$server = 'AUEODSDVDB001'
$server = 'AUEODSDVDB002'
$server = 'AUAZEJH001'
$server = 'LGHBAP120'
$server = 'LGNRDB06'

#ping $server
$session = (quser /server:$server ) 
$session
Start-DbaAgentJob -SqlInstance LGHBDB17 -Job 'Run Process MC Extracts'

Start-DbaAgentJob -SqlInstance LGHBDB17 -Job 'Run Process Extracts'  #'Run Process MC Extracts'

Find-Module -Name Az

Get-PSDrive

Get-DbaDbSpace

Get-DbaDiskSpace -ComputerName LGHBDB17
Get-DbaDiskSpace -ComputerName lghbdb24

Get-DbaDiskSpace -ComputerName LGHBDB17

#Enter-PSSession -ComputerName $server
#Get-Service -Name TermService -ComputerName AUAZECCPDB001 -DependentServices -RequiredServices
#Get-Service -Name TermService -ComputerName AUAZECCPDB001 | Stop-Service -Force
#Get-Service -Name TermService -ComputerName AUAZECCPDB001 | Start-Service
$server = "aueodsdvdb002"
$server ="lgnrapacdc01.apac.linkgroup.corp"
$server = ''
Enter-PSSession -ComputerName $server

quser /server:$server
logoff /server:$server 2 /v

Exit-PSSession
nslookup 10.150.159.76

Get-Help Restart-Computer -ComputerName 
	
Get-Process -ComputerName $server | Sort CPU -descending
