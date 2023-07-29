adb kill-server
adb tcpip 5555
adb connect 192.168.2.135:5555
scrcpy -e --stay-awake
