@echo off
REM Mumei VSCode Extension Installer (Windows)

setlocal

set EXTENSION_NAME=mumei-language-1.0.0
set VSCODE_EXTENSIONS_DIR=%USERPROFILE%\.vscode\extensions
set SCRIPT_DIR=%~dp0

echo ========================================
echo Mumei VSCode Extension Installer
echo ========================================
echo.

REM Create extensions directory if it doesn't exist
if not exist "%VSCODE_EXTENSIONS_DIR%" (
    echo Creating extensions directory...
    mkdir "%VSCODE_EXTENSIONS_DIR%"
)

REM Remove existing extension
if exist "%VSCODE_EXTENSIONS_DIR%\%EXTENSION_NAME%" (
    echo Removing existing extension...
    rmdir /s /q "%VSCODE_EXTENSIONS_DIR%\%EXTENSION_NAME%"
)

REM Copy extension
echo Installing extension...
xcopy /E /I /Q "%SCRIPT_DIR%" "%VSCODE_EXTENSIONS_DIR%\%EXTENSION_NAME%"

echo.
echo Installation complete!
echo.
echo Next steps:
echo   1. Restart VSCode
echo   2. Open a .mu file
echo   3. Enjoy syntax highlighting!
echo.
echo Test with:
echo   code ..\examples\hello.mu
echo.
echo ========================================

pause
