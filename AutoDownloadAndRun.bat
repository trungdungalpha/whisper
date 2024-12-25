@echo off
:: Đặt đường dẫn tạm thời để tải file
set TEMP_FILE=%TEMP%\AutoRestartWIPTER.bat

:: Dừng chờ 15 giây trước khi tải file
echo Đang chờ 15 giây trước khi tải file...
timeout /t 15 /nobreak >nul

:: Tải file từ URL bằng curl
curl -L https://raw.githubusercontent.com/trungdungalpha/whisper/refs/heads/main/AutoRestartWIPTER.bat -o %TEMP_FILE%

:: Kiểm tra nếu file đã tải thành công
if exist "%TEMP_FILE%" (
    :: Di chuyển file tới màn hình Desktop
    move "%TEMP_FILE%" "%USERPROFILE%\Desktop\AutoRestartWIPTER.bat"
    
    :: Thực thi file
    start "" "%USERPROFILE%\Desktop\AutoRestartWIPTER.bat"
) else (
    echo Không thể tải file.
)

:: Kết thúc
exit
