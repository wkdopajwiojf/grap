@echo off
:: 1. ส่วนสั่งงาน (Payload)
start explorer.exe "C:\"
echo "DLL System Working!" > "%TEMP%\test_log.txt"
start notepad.exe "%TEMP%\test_log.txt"

:: 2. ส่วนทำลายหลักฐาน (Self-Destruct)
:: รอสัก 1-2 วินาทีเพื่อให้ระบบ Windows เคลียร์ไฟล์เสร็จ (ใส่หรือไม่ใส่ก็ได้)
timeout /t 2 /nobreak >nul

:: บรรทัดนี้คือเวทมนตร์ที่จะลบไฟล์ .bat นี้ทิ้งทันที
(goto) 2>nul & del "%~f0"
