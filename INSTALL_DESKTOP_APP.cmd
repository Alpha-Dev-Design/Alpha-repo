@echo off
setlocal
title THE HOLLOW - Install Desktop App
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0INSTALL_DESKTOP_APP.ps1"
if errorlevel 1 (
  echo.
  echo Installation was not completed. Read the error above.
  pause
  exit /b 1
)
echo.
echo You can now open THE HOLLOW from your desktop.
pause
exit /b 0
