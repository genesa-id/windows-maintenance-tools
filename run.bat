@echo off
REM Windows Maintenance Utility Launcher
REM This script will run the PowerShell maintenance GUI with Administrator privileges

REM Check for administrator privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    REM Already running as admin, proceed
    goto :RunScript
) else (
    REM Request elevation
    echo Requesting Administrator privileges...
    powershell.exe -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:RunScript
REM Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%system_maintenance_gui.ps1"

REM Verify the PowerShell script exists
if not exist "%PS_SCRIPT%" (
    echo Error: PowerShell script not found at: %PS_SCRIPT%
    echo Please ensure system_maintenance_gui.ps1 is in the same directory as run.bat
    pause
    exit /b 1
)

REM Run the PowerShell script
echo Starting Windows Maintenance Utility...
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%PS_SCRIPT%"

REM Check if script executed successfully
if %errorLevel% == 0 (
    echo.
    echo Maintenance utility completed.
) else (
    echo.
    echo Maintenance utility exited with error code: %errorLevel%
)

pause