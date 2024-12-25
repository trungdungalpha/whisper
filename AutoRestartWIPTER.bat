@echo off

:: Set the path to the Startup folder
set STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
set TARGET_FILE=AutoRestartWIPTER.bat
set "folder=%userprofile%\Downloads\WIPTER"

if not exist "%folder%" (
    echo The folder "%folder%" does not exist.
    pause
    exit /b
)
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
    start /min cmd /c "%folder%\%%F"
    
    REM Generate a random delay between 50-60 seconds
    set /a delay=%random% %% 10 + 50
    echo Waiting for !delay! seconds before opening the next file...
    timeout /t !delay! >nul
)

echo Total number of files opened: %count%

REM Generate a random delay between 4 and 5 hours
set /a hours=%random% %% 2 + 4
set /a seconds=hours * 3600
echo Waiting for a random time of %hours% hours (%seconds% seconds)...
timeout /t %seconds% >nul

:: Set a temporary path to download the file
set TEMP_FILE=%TEMP%\AutoDownloadAndRun.bat

:: Wait for 15 seconds before downloading the file
echo Waiting 15 seconds before downloading the file...
timeout /t 15 /nobreak >nul

:: Download the file from the URL using curl
curl -L https://raw.githubusercontent.com/trungdungalpha/whisper/refs/heads/main/AutoDownloadAndRun.bat -o %TEMP_FILE%

:: Check if the file was downloaded successfully
if exist "%TEMP_FILE%" (
    :: Move the file to the Startup folder
    move "%TEMP_FILE%" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\AutoDownloadAndRun.bat"
    
    :: Execute the file
    start "" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\AutoDownloadAndRun.bat"
) else (
    echo Unable to download the file.
)

:: End
exit


:: Check if the file exists in the Startup folder
if exist "%STARTUP_FOLDER%\%TARGET_FILE%" (
    echo Opening the file %TARGET_FILE% from the Startup folder...
    start "" "%STARTUP_FOLDER%\%TARGET_FILE%"
) else (
    echo The file %TARGET_FILE% does not exist in the Startup folder.
)

:: Exit
exit
