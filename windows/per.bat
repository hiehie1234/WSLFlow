@echo off
echo Administrative permissions required. Detecting permissions...

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Failure: Current permissions inadequate.
    pause
    exit /b %errorLevel% 
)

echo Starting WSL2 installation...

@REM echo Enabling WSL and Virtual Machine Platform...
@REM dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
@REM dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

:: 使用 PowerShell 检查 WSL 功能是否已启用
echo Checking if WSL is enabled...
powershell -Command "Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux | Select-Object -ExpandProperty State" | findstr /i "Enabled"
if %errorlevel% equ 0 (
    echo WSL is enabled.
) else (
    echo WSL is not enabled.
    :: 提示用户重启系统
    echo The system needs to be restarted for the changes to take effect.
    @REM pause
    @REM shutdown /r /t 0
)

echo Checking if Virtual Machine Platform is enabled...
powershell -Command "Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform | Select-Object -ExpandProperty State" | findstr /i "Enabled"
if %errorlevel% equ 0 (
    echo Virtual Machine Platform is enabled.
) else (
    echo Virtual Machine Platform is not enabled.
    echo The system needs to be restarted for the changes to take effect.
    @REM pause
    @REM shutdown /r /t 0
)

@REM pause
@REM 设置 WSL2 为默认版本
echo Setting WSL2 as the default version...
wsl --set-default-version 2
echo .
@REM 更新 WSL
echo Updating WSL...
wsl --update
echo .
@REM wsl --install -d Ubuntu --no-launch
@REM 获得Temp目录
set "tempdir=%temp%"
set "ubuntu_image=ubuntu-jammy-wsl-amd64-wsl.rootfs.tar.gz"
@REM 查找文件是否存在
if not exist "%tempdir%\%ubuntu_image%" (
    echo Ubuntu Jammy WSL image not found.
    pause
    exit /b 1
)
set "appdata_dir=%LocalAppData%\ASUSLLm\AIDistro"
wsl --import ASUS-Workbench "%appdata_dir%" "%tempdir%\%ubuntu_image%"
echo .
if %errorlevel% neq 0 (
    echo Installing ASUS-Workbench distribution failed.
    pause
    exit /b %errorlevel%
)

@REM 删除镜像文件 %ubuntu_image%
del "%tempdir%\%ubuntu_image%"

@REM 确保当前工作目录正确
cd /d "%~dp0"

@REM 等待用户完成初始设置
:wait_loop
timeout /t 5 /nobreak >nul
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0check-ubuntu.ps1"
if %errorlevel% equ 0 (
    echo ASUS-Workbench is installed
) else (
    echo ASUS-Workbench is not installed
    goto wait_loop
)

@REM 设置 ASUS-Workbench 为默认发行版
echo Setting ASUS-Workbench as the default distribution...
wsl -l -v
echo .
echo WSL2 installation and configuration completed.
exit /b 0
@REM pause