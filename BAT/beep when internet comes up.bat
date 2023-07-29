REM Title: Beep when internet comes up
REM Description: Pings Google DNS until it gets a response, then beeps. Useful for when you're waiting for your internet to come back up after a power outage.

@setlocal enableextensions enabledelayedexpansion
@echo off
 :loop
set state=down
for /f "tokens=5,7" %%a in ('ping 8.8.8.8 -n 5 ') do (
	if "x%%a"=="xReceived" if "x%%b"=="x5," set state=up
)

	echo Internet is !state!
	if "!state!"=="up" echo 
	

goto :loop
ping -n 3 127.0.0.1 >nul: 2>nul: