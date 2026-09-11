@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title IT Help Desk - SQL Server Database
where sqlcmd >nul 2>nul
if errorlevel 1 (
  echo sqlcmd غير موجود. يمكنك تنفيذ sqlserver_schema.sql من SSMS.
  pause
  exit /b 1
)
set /p SERVER=اسم SQL Server: 
set /p DB=اسم قاعدة البيانات: 
if "%SERVER%"=="" goto FAIL
if "%DB%"=="" goto FAIL
sqlcmd -S "%SERVER%" -E -Q "IF DB_ID(N'%DB%') IS NULL CREATE DATABASE [%DB%]"
if errorlevel 1 goto FAIL
sqlcmd -S "%SERVER%" -d "%DB%" -E -i "sqlserver_schema.sql"
if errorlevel 1 goto FAIL
echo تم إنشاء/تهيئة قاعدة البيانات %DB% بنجاح.
pause
exit /b 0
:FAIL
echo تعذر إنشاء قاعدة البيانات. راجع الاتصال وSQL Server.
pause
exit /b 1
