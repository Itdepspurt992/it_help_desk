@echo off
cd /d "%~dp0"
title IT Help Desk - مركز التشغيل
:MENU
cls
echo ===============================================
echo       IT Help Desk - مركز التشغيل
echo ===============================================
echo 1 - تثبيت وبناء برنامج EXE تلقائيا
echo 2 - إعداد اتصال SQL Server
echo 3 - إنشاء/تهيئة قاعدة SQL Server
echo 4 - تشغيل البرنامج
echo 5 - فتح تعليمات التثبيت
echo 6 - خروج
echo.
set /p C=اختر [1-6]: 
if "%C%"=="1" call BUILD_AND_INSTALL.bat & goto MENU
if "%C%"=="2" call CONFIGURE_SQLSERVER.bat & goto MENU
if "%C%"=="3" call CREATE_SQLSERVER_DATABASE.bat & goto MENU
if "%C%"=="4" call RUN_SERVER.bat & goto MENU
if "%C%"=="5" start "" notepad "%~dp0README_INSTALL_AR.md" & goto MENU
if "%C%"=="6" exit /b 0
goto MENU
