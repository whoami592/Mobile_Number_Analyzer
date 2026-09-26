@echo off
cd /d "%~dp0"
where ruby >nul 2>nul
if errorlevel 1 (
  echo Ruby not found. Install Ruby and enable Add Ruby to PATH, then reopen.
  pause
  exit /b 1
)
ruby mobile_analyzer.rb
pause
