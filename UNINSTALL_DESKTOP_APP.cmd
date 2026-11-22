@echo off
setlocal
title THE HOLLOW - Remove Desktop Shortcut
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0UNINSTALL_DESKTOP_APP.ps1"
pause
