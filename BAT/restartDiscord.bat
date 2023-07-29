REM Restarts Discord. Also happens to make it update. Make a scheduled task run this at 3AM daily to never need to manually update Discord again.
taskkill /f /im Discord.exe
start "" "C:\Users\Austin\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk"