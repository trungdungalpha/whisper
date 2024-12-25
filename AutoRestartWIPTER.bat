@echo off
set "folder=%userprofile%\Downloads\WIPTER"

if not exist "%folder%" (
    echo The folder "%folder%" does not exist.
    pause
    exit /b
)

set loopCount=999999
:loop
setlocal enabledelayedexpansion
set count=0

REM Count the total number of files in the folder (excluding subfolders)
set fileCount=0
for /f "delims=" %%F in ('dir "%folder%" /a-d /b') do (
    set /a fileCount+=1
)

echo Total number of files in the folder: %fileCount%

REM Kill all .exe processes from 1 to fileCount (based on file count)
for /l %%i in (1,1,%fileCount%) do (
    REM Construct the filename for the process (assuming the filename is the same as the process name)
    REM This assumes the files are named as `1.exe`, `2.exe`, ..., `n.exe`
    taskkill /F /IM %%i.exe
    echo Killed process %%i.exe
)
TASKKILL /F /IM shutdown.exe
taskkill /F /IM Wipter.exe
timeout /t 30

REM Additional commands at the start
TASKKILL /F /IM explorer.exe
start "explorer.exe" "C:\Windows\explorer.exe"
timeout 3

REM Loop through files in alphabetical order
for /f "delims=" %%F in ('dir "%folder%" /a-d /b /o:n') do (
    set /a count+=1
    echo Opening file %%F in order #%count%
    start "" "%folder%\%%F"
    
    REM Generate a random delay between 25-30 seconds
    set /a delay=%random% %% 5 + 25
    echo Waiting for !delay! seconds before opening the next file...
    timeout /t !delay! >nul
)

echo Total number of files opened: %count%

REM Generate a random delay between 4 and 5 hours
set /a hours=%random% %% 2 + 4
set /a seconds=hours * 3600
echo Waiting for a random time of %hours% hours (%seconds% seconds)...
timeout /t %seconds% >nul

set /a loopCount=%loopCount%-1
if %loopCount%==0 GOTO:EOF

REM Correct GOTO statement for looping
GOTO loop
