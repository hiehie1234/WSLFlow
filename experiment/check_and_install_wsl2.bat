@echo off
echo Checking for existing WSL2 installation...

:: 检查 WSL2 是否已安装
wsl --list --quiet >nul 2>&1
if %errorlevel% equ 0 (
    echo WSL2 is already installed.
) else (
    echo WSL2 is not installed. Proceeding with installation...

    :: 启用 WSL 和虚拟机平台
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

    :: 设置 WSL2 为默认版本
    wsl --set-default-version 2

    :: 提示用户安装 Linux 发行版
    echo Please install your preferred Linux distribution from the Microsoft Store.

    :: 更新 WSL
    wsl --update

    echo WSL2 installation and configuration complete.
)

pause
