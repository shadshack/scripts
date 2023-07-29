REM Enables and disables the hotspot on Windows 10/11
PowerShell -Command "Set-ExecutionPolicy Unrestricted" >> "%TEMP%\StartupLog.txt" 2>&1
PowerShell ".\hotspot.ps1" >> "%TEMP%\StartupLog.txt" 2>&1
