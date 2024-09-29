@echo off
REM 创建 workbench 用户
wsl -u root -d Ubuntu-24.04 -- bash -c "adduser --disabled-password --gecos '' workbench"

REM 获取 workbench 用户的 UID 和 GID
for /f "tokens=1,2 delims=:" %%i in ('wsl -u root -d Ubuntu-24.04 -- id -u workbench') do set UID=%%i
for /f "tokens=1,2 delims=:" %%i in ('wsl -u root -d Ubuntu-24.04 -- id -g workbench') do set GID=%%i

REM 输出 UID 和 GID
echo workbench 用户的 UID 是: %UID%
echo workbench 用户的 GID 是: %GID%

pause
