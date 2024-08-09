@echo off
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
@REM wsl --install -d Ubuntu

:: 创建一个临时任务来退出 Ubuntu 控制台
echo Creating a temporary task to install Ubuntu console...
schtasks /create /tn "ExitUbuntu" /tr "wsl -t Ubuntu" /sc once /st 00:00 /f

:: 运行临时任务
echo Running the temporary task to exit Ubuntu console...
schtasks /run /tn "ExitUbuntu"

:: 等待 Ubuntu 安装完成
echo Waiting for Ubuntu installation to complete...
timeout /t 60

wsl --install -d Ubuntu

:: 删除临时任务
echo Deleting the temporary task...
schtasks /delete /tn "ExitUbuntu" /f

:: 更新 WSL
echo Updating WSL...
wsl --update

:: 将分布版设置为默认值
wsl --set-default Ubuntu

echo WSL2 installation and configuration complete.
pause
