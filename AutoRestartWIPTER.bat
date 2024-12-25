
@echo off
set "folder=C:\Users\admin\Downloads\WIPTER"

if not exist "%folder%" (
    echo The folder "%folder%" does not exist.
    pause
    exit /b
)

set loopCount=999999
:loop
setlocal enabledelayedexpansion
set count=0

REM Loop through files in alphabetical order
for /f "delims=" %%F in ('dir "%folder%" /a-d /b') do (
    set /a count+=1
    echo Opening file %%F in order #%count%
    start "" "%folder%\%%F"
    
    REM Generate a random delay between 30-60 seconds
    set /a delay=%random% %% 31 + 30
    echo Waiting for !delay! seconds before opening the next file...
    timeout /t !delay! >nul
)

echo Total number of files opened: %count%

REM Generate a random delay between 4 and 5 hours
set /a hours=%random% %% 2 + 4
set /a seconds=hours * 3600
echo Waiting for a random time of %hours% hours (%seconds% seconds)...
timeout /t %seconds% >nul

REM Additional commands at the end
TASKKILL /F /IM explorer.exe
start "explorer.exe" "C:\Windows\explorer.exe"
timeout 3
TASKKILL /F /IM shutdown.exe

taskkill /F /IM Wipter.exe
timeout /t 30

set /a loopCount=%loopCount%-1
if %loopCount%==0 GOTO:EOF

GOTO ➿
