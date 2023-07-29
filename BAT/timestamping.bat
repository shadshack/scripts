@echo off
title Testing Network. DO NOT CLOSE THIS WINDOW.
color c0
echo ###############################################################################
echo ##               NETWORK TEST. DO NOT CLOSE THIS WINDOW                      ##
echo ###############################################################################
echo Cleaning up old pingtest.txt if it exists.
del pingtest.txt > nul 2> nul
echo %date% %time%
echo Starting Ping Test
for /f "tokens=*" %%A in ('ping google.com -n 1 ') do (echo %%A>>pingtest.txt && GOTO Ping)
:Ping
for /f "tokens=* skip=2" %%A in ('ping google.com -n 1 ') do (echo %date% %time% %%A>>pingtest.txt && GOTO Ping)
