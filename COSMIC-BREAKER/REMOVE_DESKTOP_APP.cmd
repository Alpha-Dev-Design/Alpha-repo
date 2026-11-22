@echo off
setlocal EnableExtensions
title Cosmic Breaker - Remove Desktop Shortcut
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Remove-CosmicBreaker.ps1"
if errorlevel 1 (
  echo Could not remove the shortcut.
) else (
  echo Cosmic Breaker shortcut and locally installed copy removed.
)
pause
