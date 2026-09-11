@echo off
setlocal EnableExtensions
cd /d "%~dp0"
if exist "dist\IT_Help_Desk\IT_Help_Desk.exe" (
  start "IT Help Desk" "dist\IT_Help_Desk\IT_Help_Desk.exe"
  exit /b 0
)
if not exist ".venv\Scripts\python.exe" (
  echo البرنامج غير مبني بعد. شغّل BUILD_AND_INSTALL.bat أولاً.
  pause
  exit /b 1
)
".venv\Scripts\python.exe" app.py
