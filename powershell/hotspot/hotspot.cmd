PowerShell -Command "Set-ExecutionPolicy Unrestricted" >> "%TEMP%\StartupLog.txt" 2>&1
PowerShell "C:\Users\wolcott-austin\OneDrive - State of Florida - Department of Children and Families\Scripts\hotspot\hotspot.ps1" >> "%TEMP%\StartupLog.txt" 2>&1
