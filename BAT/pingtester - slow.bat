@echo off
del pinglog.txt
echo Pinging and writing results to pinglog.txt
:Ping
timeout 1
for /f "tokens=* skip=2" %%A in ('ping 8.8.8.8 -n 1') do (echo %date% %time% %%A >> pinglog.txt && GOTO Ping)
