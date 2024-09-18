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

:: 如果默认分布版不是Ubuntu，则将分布版设置为Ubuntu
:: 将分布版设置为默认值
wsl --set-default Ubuntu

set "ENV_NAME=FlexTuner"

:: 在 WSL 中执行脚本
wsl bash -ic "cd /usr/share/asus-lim/env && ./uninstall.sh"
if %errorlevel% neq 0 (
    echo uninstall Script execution failed.
)

:: 停止所有正在运行的 WSL 实例
wsl --shutdown

::删除 WSL 相关文件夹
wsl rm -rf /usr/share/asus-llm
wsl rm -rf /usr/lib/asus-llm

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

:: 删除 WSL 相关文件夹
:: 使用 for 循环处理通配符路径
for /d %%i in ("%USERPROFILE%\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu_*") do (
    rmdir /s /q "%%i"
)

:: 禁用 WSL 和虚拟机平台
@REM dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux
@REM dism.exe /online /disable-feature /featurename:VirtualMachinePlatform

echo WSL2 and all related components have been uninstalled.
@REM pause
