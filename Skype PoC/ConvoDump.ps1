#Skype DB reader PoC
#Params: -Find 			: list all found skype DBs
#		 -Path <path> 	: list basic conversation data for this db	 
#
#

param (
	[switch]$Find = $false,
	[string]$Path = "",
	[int]$ConvoID
)

if($Find -and !$Path -and !$ConvoID) #List all the available Skype DBs
{
	#get list of users
	$usersFolders = get-childitem -path "C:\Users" | ForEach-Object {$_.Name}
	foreach($s in $usersFolders)
	{
		$path = "C:\Users\" + $s + "\AppData\Roaming"
		if(Test-Path ($path))
		{
			Get-ChildItem -Path $path -Recurse -Include main.db
		}	
	}
}
elseif($Path -and ! $Find -and !$ConvoID) 
{
	#check file exists
	if(!(Test-Path ($Path)))
	{
		Write-Error "The DB path provided does not exists!"
		return
	}
	else
	{
		#get the script path 
		$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
		#load the sqlite3 binary
		[string]$sqlite_lib = $PSScriptRoot + "\bins\System.Data.SQLite.dll"
		[string]$query = "select skypename from accounts"
		
		#reflection
		[void][System.Reflection.Assembly]::LoadFrom($sqlite_lib) 
		
		$dataset = New-Object System.Data.DataSet
		$data_adapter = New-Object System.Data.SQLIte.SQLiteDataAdapter($query, "Data Source=$Path")
		[void]$data_adapter.Fill($dataset)
		
		$SkypeName = $dataset.Tables[0].Rows[0]["skypename"]
		
		Write-Host "Conversations for "$SkypeName
		Write-Host "-------------------------------"
		
		$dataset = New-Object System.Data.DataSet
		$query = "select c.id, c.identity, c.displayname, case when exists(select * From messages m where m.convo_id = c.id) then 1 else 0 end as 'Convo Data Held' From conversations c"
		$data_adapter = New-Object System.Data.SQLIte.SQLiteDataAdapter($query, "Data Source=$Path")
		[void]$data_adapter.Fill($dataset)
		
		$dataset.Tables[0]
	}
}
elseif(!$Find -and $Path -and $ConvoID)
{
#check file exists
	if(!(Test-Path ($Path)))
	{
		Write-Error "The DB path provided does not exists!"
		return
	}
	#Load the conversation histroy
	#get the script path 
	$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
	#load the sqlite3 binary
	[string]$sqlite_lib = $PSScriptRoot + "\bins\System.Data.SQLite.dll"
	[string]$query = "select from_dispname, body_xml, datetime(timestamp, 'unixepoch')as 'Timestamp' FROM Messages WHERE convo_id = " + $ConvoID + " order by convo_id, timestamp"

	#reflection
	[void][System.Reflection.Assembly]::LoadFrom($sqlite_lib) 
		
	$dataset = New-Object System.Data.DataSet
	$data_adapter = New-Object System.Data.SQLIte.SQLiteDataAdapter($query, "Data Source=$Path")
	[void]$data_adapter.Fill($dataset)
	$dataset.Tables[0]
}



