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
for /f "tokens=*" %%i in ('wsl echo $HOME') do set "home=%%i"
:: 定义源目录和目标目录
set "source=..\linux"
set "destination=\\wsl$\Ubuntu%home%\%ENV_NAME%"

:: 创建目标目录
wsl mkdir -p "%home%/%ENV_NAME%"

:: 复制文件到 WSL 用户目录
xcopy "%source%" "%destination%" /s /e /y
if %errorlevel% neq 0 (
    echo 文件复制失败。
    exit /b %errorlevel%
)

:: 创建一个临时脚本来配置 sudo
echo %wsl_username% ALL=(ALL) NOPASSWD:ALL > temp_sudoers
wsl sudo cp temp_sudoers /etc/sudoers.d/%wsl_username%
wsl sudo chmod 0440 /etc/sudoers.d/%wsl_username%
del temp_sudoers

:: Install dos2unix if not already installed
wsl sudo apt-get update
wsl sudo apt-get install -y dos2unix
:: Convert all .sh files to Unix line endings
wsl bash -c "find %home%/%ENV_NAME% -type f -name '*.sh' -exec dos2unix {} +"

:: 在 WSL 中为所有 .sh 文件添加执行权限
wsl bash -c "chmod +x %home%/%ENV_NAME%/*.sh"

:: 确保所有子目录中的 .sh 文件也有执行权限
wsl bash -c "find %home%/%ENV_NAME% -type f -name '*.sh' -exec chmod +x {} +"

:: 在 WSL 中执行脚本
wsl bash -ic "cd %home%/%ENV_NAME% && ./install.sh"
if %errorlevel% neq 0 (
    echo 脚本执行失败。
    exit /b %errorlevel%
)

echo 文件已成功复制并执行。
endlocal
@REM pause
