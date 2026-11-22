@echo off
setlocal EnableExtensions
title Cosmic Breaker - Install Desktop Shortcut
cd /d "%~dp0"
echo.
echo ===========================================
echo    COSMIC BREAKER - ONE-CLICK INSTALLER
echo ===========================================
echo.
echo Installs a game shortcut, no Node.js needed.
echo.
if not exist "%~dp0brick.html" (
  echo ERROR: brick.html is missing. Extract the entire ZIP first.
  pause
  exit /b 1
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-CosmicBreaker.ps1"
if errorlevel 1 (
  echo.
  echo Installation failed. Read the error above.
  pause
  exit /b 1
)
echo.
echo SUCCESS! Open COSMIC BREAKER from your desktop.
echo You can also find it in the Start Menu.
echo.
pause
exit /b 0
