@echo off
echo Starting distro checking...

@REM 确保当前工作目录正确
cd /d "%~dp0"

@REM 等待用户完成初始设置
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0check-ubuntu.ps1"
if %errorlevel% equ 0 (
    echo ASUS-Workbench is installed
    exit 409
) else (
    echo ASUS-Workbench is not installed, installation continues
    exit 404
)
