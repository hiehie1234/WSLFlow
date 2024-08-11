@echo off
setlocal

:: 将分布版设置为默认值
wsl --set-default Ubuntu
if %errorlevel% neq 0 (
    echo 操作失败。
    exit /b %errorlevel%
)


set "ENV_NAME=FlexTuner"
:: 获取 WSL 用户名
for /f "tokens=* USEBACKQ" %%F in (`wsl whoami`) do set "wsl_username=%%F"

:: 定义源目录和目标目录
set "source=..\linux"
set "destination=\\wsl$\Ubuntu\home\%wsl_username%\%ENV_NAME%"

:: 创建目标目录
wsl mkdir -p /home/%wsl_username%/%ENV_NAME%

:: 复制文件到 WSL 用户目录
xcopy %source% %destination% /s /e /y
if %errorlevel% neq 0 (
    echo 文件复制失败。
    exit /b %errorlevel%
)

:: 在 WSL 中为所有 .sh 文件添加执行权限
wsl bash -c "chmod +x /home/%wsl_username%/%ENV_NAME%/*.sh"

:: 确保所有子目录中的 .sh 文件也有执行权限
wsl bash -c "find /home/%wsl_username%/%ENV_NAME% -type f -name '*.sh' -exec chmod +x {} +"

:: 在 WSL 中执行脚本
wsl bash -ic "cd /home/%wsl_username%/%ENV_NAME% && ./install.sh"
if %errorlevel% neq 0 (
    echo 脚本执行失败。
    exit /b %errorlevel%
)

echo 文件已成功复制并执行。
pause
