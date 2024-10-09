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

echo Uninstalling WSL2 and all related components...

set "ENV_NAME=FlexTuner"

:: 在 WSL 中执行脚本
wsl -d ASUS-Workbench -- bash -ic "cd /usr/share/asus-llm/env && ./uninstall.sh"
if %errorlevel% neq 0 (
    echo uninstall Script execution failed.
)

:: 停止所有正在运行的 WSL 实例
wsl -t ASUS-Workbench

::删除 WSL 相关文件夹
wsl -d ASUS-Workbench -- rm -rf /usr/share/asus-llm
wsl -d ASUS-Workbench -- rm -rf /usr/lib/asus-llm

:: 提示用户--unregister Ubuntu卸载将删除已安装的 Linux 发行版，让用户选择是否继续
echo Uninstalling ASUS-Workbench distribution. This will remove all installed Linux distributions.
@REM echo Are you sure you want to continue? (Y/N)
@REM choice /M "Press Y to continue or N to cancel."

@REM if errorlevel 2 (
@REM     echo Uninstallation cancelled.
@REM     exit /B 1
@REM )

:: 继续卸载过程
echo Proceeding with uninstallation...
:: 卸载所有已安装的 Linux 发行版
@REM for /f "tokens=*" %%i in ('wsl --list --quiet') do wsl --unregister %%i
wsl --unregister ASUS-Workbench

@REM :: 删除 WSL 相关文件夹
@REM :: 使用 for 循环处理通配符路径
@REM for /d %%i in ("%USERPROFILE%\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu_*") do (
@REM     rmdir /s /q "%%i"
@REM )

:: 禁用 WSL 和虚拟机平台
@REM dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux
@REM dism.exe /online /disable-feature /featurename:VirtualMachinePlatform

echo WSL2 and all related components have been uninstalled.
exit /b 0
@REM pause
