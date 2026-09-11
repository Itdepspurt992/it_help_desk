﻿@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title IT Help Desk - إعداد SQL Server
color 0B

echo ===============================================
echo      إعداد الاتصال بـ Microsoft SQL Server
echo ===============================================
echo.
set /p SERVER=اسم/عنوان SQL Server (مثال: 192.168.1.10\SQLEXPRESS): 
if "%SERVER%"=="" goto FAIL
set /p DB=اسم قاعدة البيانات (مثال: IT_Help_Desk): 
if "%DB%"=="" goto FAIL

echo.
echo اختر طريقة الدخول:
echo 1 - Windows Authentication
echo 2 - SQL Server Authentication
set /p AUTH=اختيارك [1/2]: 
if "%AUTH%"=="1" goto WINDOWS_AUTH
if "%AUTH%"=="2" goto SQL_AUTH
goto FAIL

:TARGET
set "TARGET=%CD%"
if exist "dist\IT_Help_Desk\IT_Help_Desk.exe" set "TARGET=%CD%\dist\IT_Help_Desk"
exit /b

:WINDOWS_AUTH
call :TARGET
> "%TARGET%\.env" echo SECRET_KEY=CHANGE_THIS_SECRET_KEY
>> "%TARGET%\.env" echo DATABASE_URL=mssql+pyodbc://@%SERVER%/%DB%?driver=ODBC+Driver+18+for+SQL+Server^&TrustServerCertificate=yes^&trusted_connection=yes
>> "%TARGET%\.env" echo HOST=0.0.0.0
>> "%TARGET%\.env" echo PORT=5000
>> "%TARGET%\.env" echo SESSION_COOKIE_SECURE=0
echo تم إنشاء ملف .env في:
echo %TARGET%\ .env
goto DONE

:SQL_AUTH
set /p USER=اسم مستخدم SQL Server: 
set /p PASS=كلمة مرور SQL Server: 
call :TARGET
> "%TARGET%\.env" echo SECRET_KEY=CHANGE_THIS_SECRET_KEY
>> "%TARGET%\.env" echo DATABASE_URL=mssql+pyodbc://%USER%:%PASS%@%SERVER%/%DB%?driver=ODBC+Driver+18+for+SQL+Server^&TrustServerCertificate=yes
>> "%TARGET%\.env" echo HOST=0.0.0.0
>> "%TARGET%\.env" echo PORT=5000
>> "%TARGET%\.env" echo SESSION_COOKIE_SECURE=0
echo تم إنشاء ملف .env في:
echo %TARGET%\ .env
goto DONE

:DONE
echo.
echo تنبيه: يجب تثبيت Microsoft ODBC Driver 18 for SQL Server على جهاز التشغيل.
echo ثم تأكد من تشغيل قاعدة البيانات وتطبيق sqlserver_schema.sql قبل التشغيل.
echo.
pause
exit /b 0

:FAIL
echo بيانات غير صحيحة أو اختيار غير صالح.
pause
exit /b 1
