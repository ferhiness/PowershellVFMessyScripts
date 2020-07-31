
Get-Command -Module PSTeams

Get-help Send-TeamsMessage

#https://outlook.office.com/webhook/d007cd55-28f3-4269-b738-35ad5b38e048@172f05a2-f956-4856-b4c8-9580a54dbd56/IncomingWebhook/589dd72b26ea4999b0d0a040f8ac5445/52a89769-fdc7-411f-8b2b-de81240a4425

Send-TeamsMessage -Uri https://outlook.office.com/webhook/d007cd55-28f3-4269-b738-35ad5b38e048@172f05a2-f956-4856-b4c8-9580a54dbd56/IncomingWebhook/589dd72b26ea4999b0d0a040f8ac5445/52a89769-fdc7-411f-8b2b-de81240a4425 -MessageTitle 'Test' -MessageText 'Test' -Color IndianRed 
