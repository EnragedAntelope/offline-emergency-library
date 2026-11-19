@echo off
setlocal
title Check Drive
cd /d "%~dp0"
rem A PowerShell 7 window passes down its module path, and Windows PowerShell then
rem fails to load its own commands (#117). Cleared, Windows PowerShell uses its default.
set "PSModulePath="
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0check-drive.ps1"
pause
