@echo off
:: 以管理员身份执行
echo Administrative permissions required. Detecting permissions...

net session >nul 2>&1
if %errorLevel% == 0 (
    echo Success: Administrative permissions confirmed.
) else (
    echo Failure: Current permissions inadequate.
    goto end
)

echo Starting WSL2 installation...

:: 启用 WSL 和虚拟机平台
echo Enabling WSL and Virtual Machine Platform...
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

:: 使用 PowerShell 检查 WSL 功能是否已启用
echo Checking if WSL is enabled...
powershell -Command "Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux | Select-Object -ExpandProperty State" | findstr /i "Enabled"
if %errorlevel% equ 0 (
    echo WSL is enabled.
) else (
    echo WSL is not enabled.
    :: 提示用户重启系统
    echo The system needs to be restarted for the changes to take effect.
    pause
    shutdown /r /t 0
)

:: 使用 PowerShell 检查虚拟机平台功能是否已启用
echo Checking if Virtual Machine Platform is enabled...
powershell -Command "Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform | Select-Object -ExpandProperty State" | findstr /i "Enabled"
if %errorlevel% equ 0 (
    echo Virtual Machine Platform is enabled.
) else (
    echo Virtual Machine Platform is not enabled.
    :: 提示用户重启系统
    echo The system needs to be restarted for the changes to take effect.
    pause
    shutdown /r /t 0
)


:: 设置 WSL2 为默认版本
echo Setting WSL2 as the default version...
wsl --set-default-version 2

:: 更新 WSL
echo Updating WSL...
wsl --update

:: 安装 Ubuntu 发行版
echo Installing Ubuntu distribution. This may take a while...
:: 提示用户首次启动 Ubuntu 控制台时，需要手动输入 exit 并按回车退出，以确保更新正常
:: echo Please exit the Ubuntu console by typing 'exit' to complete the installation.
wsl --install -d Ubuntu --no-launch
if %errorlevel% neq 0 (
    echo Installing Ubuntu distribution failed.
    exit /b %errorlevel%
)

:: 启动 Ubuntu 以完成初始设置
echo Launching Ubuntu to complete initial setup...
explorer.exe shell:appsFolder\CanonicalGroupLimited.Ubuntu_79rhkp1fndgsc!Ubuntu

:: 确保当前工作目录正确
cd /d %~dp0

:: 等待用户完成初始设置
:wait_loop
timeout /t 5 /nobreak >nul
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0check-ubuntu.ps1"
if %errorlevel% equ 0 (
    echo Ubuntu-22.04 is installed
) else (
    echo Ubuntu-22.04 is not installed
    goto wait_loop
)

:: 设置 Ubuntu 为默认发行版
echo Setting Ubuntu as the default distribution...
wsl -l -v
timeout /t 5 /nobreak >nul
wsl --set-default Ubuntu
if %errorlevel% neq 0 (
    echo set-default failed.
    exit /b %errorlevel%
)

echo WSL2 installation and configuration complete.
:end
@REM pause
