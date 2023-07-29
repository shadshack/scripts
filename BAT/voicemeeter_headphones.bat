@echo off
REM Restart Audio Engine
"C:\Program Files (x86)\VB\Voicemeeter\voicemeeter.exe" -r

REM Set the output channels
REM https://github.com/rpetti/vmcli
REM Switch to A2 (Headphones)
"C:\Program Files\vmcli.exe" Strip[1].A1=0 Strip[1].A2=1 Strip[5].A1=0 Strip[5].A2=1 Strip[6].A1=0 Strip[6].A2=1 Strip[7].A1=0 Strip[7].Gain=-25 Strip[7].A2=1