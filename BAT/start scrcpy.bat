REM Uses scrcpy to connect to my phone over WiFi. Have to plug phone into PC first and run the script once, then you can unplug. Subsequent runs don't need the phone plugged in, unless you reboot your phone.
adb kill-server
adb tcpip 5555
adb connect 192.168.2.135:5555
scrcpy -e --stay-awake
