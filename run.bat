@echo off
setlocal EnableExtensions
cd /d %~dp0
if not exist .venv\Scripts\python.exe (
  py -3 -m venv .venv
  if errorlevel 1 (echo Failed to create virtual environment.&pause&exit /b 1)
)
call .venv\Scripts\activate.bat
python -m pip install -r requirements.txt
if errorlevel 1 (echo Dependency installation failed. Check Internet/proxy settings or install packages from an internal mirror.&pause&exit /b 1)
if not exist database mkdir database
if not exist uploads mkdir uploads
if not exist backups mkdir backups
python seed.py
if errorlevel 1 (echo Database initialization failed.&pause&exit /b 1)
start "IT Help Desk Server" cmd /c "call .venv\Scripts\activate.bat && python app.py"
timeout /t 3 /nobreak >nul
start "IT Help Desk" http://127.0.0.1:5000
endlocal
