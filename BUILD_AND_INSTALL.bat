@echo off
setlocal EnableExtensions
cd /d "%~dp0"
call INSTALL_ON_WINDOWS.bat
if errorlevel 1 exit /b 1
if exist "dist\IT_Help_Desk\IT_Help_Desk.exe" (
  echo.
  echo تم تجهيز البرنامج بالكامل.
  echo لتشغيله: dist\IT_Help_Desk\IT_Help_Desk.exe
  start "IT Help Desk" "dist\IT_Help_Desk\IT_Help_Desk.exe"
)
