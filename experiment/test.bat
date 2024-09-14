@echo off

:: 通用函数：检查功能是否已启用
:CheckFeatureEnabled
setlocal

set "featureName=%~1"
echo Checking if %featureName% is enabled...
echo abc %1
echo bcd %~1

endlocal & set "featureName=%featureName%"
echo featureName after endlocal: %featureName%
goto :eof

:: 检查 WSL 功能是否已启用
call :CheckFeatureEnabled "Microsoft-Windows-Subsystem-Linux"

:: 检查虚拟机平台功能是否已启用
call :CheckFeatureEnabled "VirtualMachinePlatform"

pause