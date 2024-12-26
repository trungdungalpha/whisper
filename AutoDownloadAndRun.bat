@echo off
:: Set a temporary path to download the file
set TEMP_FILE=%TEMP%\AutoRestartWIPTER.bat

:: Wait for 15 seconds before downloading the file
echo Waiting 15 seconds before downloading the file...
timeout /t 15 /nobreak >nul

:: Download the file from the URL using curl
curl -L https://raw.githubusercontent.com/trungdungalpha/whisper/refs/heads/main/AutoRestartWIPTER.bat -o %TEMP_FILE%

:: Check if the file was downloaded successfully
if exist "%TEMP_FILE%" (
    :: Move the file to the Desktop
    move "%TEMP_FILE%" "%USERPROFILE%\Desktop\AutoRestartWIPTER.bat"
    
    :: Execute the file
    start /min "" "%USERPROFILE%\Desktop\AutoRestartWIPTER.bat"
) else (
    echo Unable to download the file.
)

:: End
exit
