@echo off
:: Wait for 15 seconds before starting
echo Waiting for 15 seconds before starting...
timeout /t 15 /nobreak >nul

:: Set the Startup folder path and target folder path
set STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
set TARGET_FILE=AutoRestartWIPTER.bat
set "FOLDER=%userprofile%\Downloads\WIPTER"

:: Check if the target folder exists
if not exist "%FOLDER%" (
    echo The folder "%FOLDER%" does not exist. Exiting...
    pause
    exit /b
)

:: Count the total number of files (excluding subfolders)
set fileCount=0
for /f "delims=" %%F in ('dir "%FOLDER%" /a-d /b') do (
    set /a fileCount+=1
)
echo Total number of files in the folder: %fileCount%

:: Terminate all processes based on file count
for /l %%i in (1,1,%fileCount%) do (
    taskkill /F /IM %%i.exe >nul 2>&1 && echo Process %%i.exe terminated || echo Process %%i.exe not found
)
taskkill /F /IM shutdown.exe >nul 2>&1
taskkill /F /IM Wipter.exe >nul 2>&1
timeout /t 30 >nul

:: Restart explorer.exe
echo Restarting Explorer...
taskkill /F /IM explorer.exe >nul 2>&1
start "" "C:\Windows\explorer.exe"
timeout /t 3 >nul

:: Open files in the folder alphabetically with random delay between 60 and 90 seconds
set count=0
for /f "delims=" %%F in ('dir "%FOLDER%" /a-d /b /o:n') do (
    set /a count+=1
    echo Opening file %%F (#%count%)...
    start /min cmd /c "%FOLDER%\%%F"

    :: Generate random delay between 60 and 90 seconds for each file
    set /a delay=%random% %% 31 + 60
    echo Waiting for !delay! seconds before opening the next file...
    timeout /t !delay! >nul
)
echo Total number of files opened: %count%

:: Generate random delay between 7 and 8 hours
set /a hours=%random% %% 2 + 7
set /a seconds=hours * 3600
echo Waiting for %hours% hours (%seconds% seconds)...
timeout /t %seconds% >nul

:: Download file from URL
set TEMP_FILE=%TEMP%\AutoDownloadAndRun.bat
echo Waiting 15 seconds before downloading the file...
timeout /t 15 /nobreak >nul

echo Downloading the file from URL...
curl -L https://raw.githubusercontent.com/trungdungalpha/whisper/refs/heads/main/AutoDownloadAndRun.bat -o "%TEMP_FILE%" >nul 2>&1

:: Check if the file was downloaded successfully
if exist "%TEMP_FILE%" (
    echo File downloaded successfully. Moving to Startup folder...
    move /y "%TEMP_FILE%" "%STARTUP_FOLDER%\AutoDownloadAndRun.bat" >nul
    echo Running the downloaded file...
    start "" "%STARTUP_FOLDER%\AutoDownloadAndRun.bat"
) else (
    echo Failed to download the file. Please check the URL or your network connection.
)

:: Finish
echo Process completed successfully.
exit /b
