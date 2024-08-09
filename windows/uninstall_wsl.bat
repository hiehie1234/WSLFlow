@echo off
:: 以管理员身份执行
echo Uninstalling WSL2 and all related components...

:: 在 WSL 中执行脚本
wsl bash -ic "cd /home/%wsl_username%/%ENV_NAME% && ./install.sh"
if %errorlevel% neq 0 (
    echo 脚本执行失败。
    exit /b %errorlevel%
)

:: 停止所有正在运行的 WSL 实例
wsl --shutdown

:: 提示用户--unregister Ubuntu卸载将删除已安装的 Linux 发行版，让用户选择是否继续
echo Uninstalling Ubuntu distribution. This will remove all installed Linux distributions.
echo Are you sure you want to continue? (Y/N)
choice /M "Press Y to continue or N to cancel."

if errorlevel 2 (
    echo Uninstallation cancelled.
    exit /B
)

:: 继续卸载过程
echo Proceeding with uninstallation...
:: 卸载所有已安装的 Linux 发行版
@REM for /f "tokens=*" %%i in ('wsl --list --quiet') do wsl --unregister %%i
wsl --unregister Ubuntu

:: 禁用 WSL 和虚拟机平台
dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux
dism.exe /online /disable-feature /featurename:VirtualMachinePlatform

:: 删除 WSL 相关文件夹
rmdir /s /q %USERPROFILE%\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu*

echo WSL2 and all related components have been uninstalled.
pause
