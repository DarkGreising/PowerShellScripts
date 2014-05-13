ConvoDump.ps1 - Dumps out stored conversation data from the Skype Main.db sqlite database. 

Usage: 
ConvoDump.ps1 -Find - lists all skype DBs in all user directories (must be run as admin)
ConvoDump.ps1 -Path <path to main.db> Lists chat history 
ConvoDump.ps1 -Path <path to main.db> -ConvoID <ID> dumps out the full conversation history for the provided Conversation ID 	

Requirements: Dependent on System.Data.SQLite.dll binary from http://system.data.sqlite.org/index.html/doc/trunk/www/downloads.wiki
Place the version that matches your environment in the 'bins' directory. No install necessary if visual C++ runtime is present. 