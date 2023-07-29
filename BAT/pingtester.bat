REM Pings and writes timestamped results to pinglog.txt
@echo off
del pinglog.txt
echo Pinging and writing results to pinglog.txt
for /f "tokens=*" %%A in ('ping 8.8.8.8 -n 1 ') do (echo %date% %time% %%A>>pinglog.txt && GOTO Ping)
:Ping
for /f "tokens=* skip=2" %%A in ('ping 8.8.8.8 -n 1') do (echo %date% %time% %%A >> pinglog.txt && GOTO Ping)
