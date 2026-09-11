@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title IT Help Desk - تثبيت وبناء البرنامج
color 0A

echo ===============================================
echo       IT Help Desk - Windows Installer
echo ===============================================
echo.

where py >nul 2>nul
if %errorlevel%==0 (set "PY=py -3") else (
  where python >nul 2>nul
  if errorlevel 1 (
    echo ERROR: Python غير مثبت على هذا الجهاز.
    echo ثبّت Python 3.11/3.12 ثم شغل الملف مرة أخرى.
    pause
    exit /b 1
  )
  set "PY=python"
)

echo [1/7] إنشاء البيئة الافتراضية...
if not exist ".venv\Scripts\python.exe" %PY% -m venv .venv
if errorlevel 1 goto FAIL

set "VP=%CD%\.venv\Scripts\python.exe"

echo [2/7] تثبيت المكتبات...
"%VP%" -m pip install -r requirements.txt
if errorlevel 1 goto FAIL

"%VP%" -m pip install pyinstaller
if errorlevel 1 goto FAIL

echo [3/7] إنشاء المجلدات...
if not exist database mkdir database
if not exist uploads mkdir uploads
if not exist backups mkdir backups
if not exist reports mkdir reports

echo [4/7] تهيئة قاعدة البيانات المحلية والبيانات التجريبية...
"%VP%" seed.py
if errorlevel 1 goto FAIL

echo [5/7] بناء البرنامج...
"%VP%" -m PyInstaller --clean --noconfirm IT_Help_Desk.spec
if errorlevel 1 goto FAIL

if not exist "dist\IT_Help_Desk\IT_Help_Desk.exe" goto FAIL

echo [6/7] إنشاء اختصار على سطح المكتب...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut([Environment]::GetFolderPath('Desktop')+'\IT Help Desk.lnk');$s.TargetPath='%CD%\dist\IT_Help_Desk\IT_Help_Desk.exe';$s.WorkingDirectory='%CD%\dist\IT_Help_Desk';$s.IconLocation='%CD%\dist\IT_Help_Desk\IT_Help_Desk.exe,0';$s.Save()"

echo [7/7] إنشاء ملف تشغيل سريع...
(
  echo @echo off
  echo cd /d "%%~dp0"
  echo start "IT Help Desk" "%%~dp0IT_Help_Desk.exe"
) > "dist\IT_Help_Desk\تشغيل IT Help Desk.bat"

echo.
echo ===============================================
echo           تم البناء بنجاح
echo البرنامج:
echo dist\IT_Help_Desk\IT_Help_Desk.exe
echo الاختصار: سطح المكتب\IT Help Desk.lnk
echo ===============================================
echo.
pause
exit /b 0

:FAIL
echo.
echo ===============================================
echo حدث خطأ أثناء التثبيت/البناء.
echo راجع الرسالة أعلاه وأرسل صورة لها إذا احتجت مساعدة.
echo ===============================================
pause
exit /b 1
