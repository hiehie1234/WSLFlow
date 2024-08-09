@echo off
:: 以管理员身份执行
echo Starting WSL2 installation...

:: 启用 WSL 和虚拟机平台
echo Enabling WSL and Virtual Machine Platform...
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

:: 设置 WSL2 为默认版本
echo Setting WSL2 as the default version...
wsl --set-default-version 2

:: 安装 Ubuntu 发行版
echo Installing Ubuntu distribution. This may take a while...
:: 提示用户首次启动 Ubuntu 控制台时，需要手动输入 exit 并按回车退出，以确保更新正常
echo Please exit the Ubuntu console by typing 'exit' to complete the installation.
wsl --install -d Ubuntu

:: 写入标记到文件，表示用户上一步输入exit退出,而不是直接关闭窗口
:: 输入退出可以继续下面步骤，直接关闭窗口会导致下面步骤无法执行

:: 更新 WSL
echo Updating WSL...
wsl --update

:: 将分布版设置为默认值
wsl --set-default Ubuntu

echo WSL2 installation and configuration complete.
pause
