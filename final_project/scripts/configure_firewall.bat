@echo off
echo Configuring Firebase Firewall Rules...
echo This script requires administrator privileges.
echo.

NET SESSION >nul 2>&1
if %errorLevel% == 0 (
    powershell.exe -ExecutionPolicy Bypass -File "%~dp0configure_firewall.ps1"
) else (
    echo Please run this script as Administrator
    echo Right-click on the script and select "Run as administrator"
    pause
    exit
) 