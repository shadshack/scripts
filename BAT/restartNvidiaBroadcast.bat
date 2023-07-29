REM Restarts NVIDIA Broadcast if it's having issues. Also restarts Voicemeeter Audio Engine so it can detect the audio device is connected.
taskkill /f /im "NVIDIA Broadcast UI.exe"
start "" "C:\Program Files\NVIDIA Corporation\NVIDIA Broadcast\NVIDIA Broadcast UI.exe"
timeout /t 10
"C:\Program Files (x86)\VB\Voicemeeter\voicemeeter.exe" -r