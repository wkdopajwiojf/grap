@echo off
:: สั่งเปิด File Explorer
start explorer.exe "C:\"
:: สั่งเปิด Notepad มาเขียนข้อความเทส
echo "DLL System Working!" > %TEMP%\test_log.txt
start notepad.exe %TEMP%\test_log.txt
exit
