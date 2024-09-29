@echo off
setlocal

set "ENV_NAME=FlexTuner"
:: 获取 WSL 用户名
for /f "tokens=* USEBACKQ" %%F in (`wsl -d ASUS-Workbench -- whoami`) do set "wsl_username=%%F"
echo get default distribution username is %wsl_username%

cd /d %~dp0
echo "current directory is " %~dp0
:: 定义源目录和目标目录
set "source=..\linux"
set "destination=\\wsl$\ASUS-Workbench\usr\share\asus-llm\env"


:: 创建目标目录
wsl -d ASUS-Workbench -- mkdir -p "/usr/share/asus-llm/env"
:: 复制文件到 WSL 用户目录
xcopy "%source%" "%destination%" /s /e /y
if %errorlevel% neq 0 (
    echo File copy failed.
    pause
    exit /b %errorlevel%
)

set "sourceLLM=..\scripts\llama-factory"
set "destinationLLM=\\wsl$\ASUS-Workbench\usr\lib\asus-llm\LLaMA-Factory"

@REM wsl mkdir -p "%home%/%ENV_NAME%/src"
wsl -d ASUS-Workbench -- mkdir -p "/usr/lib/asus-llm/LLaMA-Factory"
xcopy "%sourceLLM%" "%destinationLLM%" /s /e /y

if %errorlevel% neq 0 (
    echo File copy failed.
    pause
    exit /b %errorlevel%
)

:: 创建一个临时脚本来配置 sudo
echo %wsl_username% ALL=(ALL) NOPASSWD:ALL > temp_sudoers
wsl -d ASUS-Workbench -u root -- cp temp_sudoers /etc/sudoers.d/%wsl_username%
wsl -d ASUS-Workbench -u root -- chmod 0440 /etc/sudoers.d/%wsl_username%
del temp_sudoers

:: Install dos2unix if not already installed
wsl -d ASUS-Workbench -u root -- apt-get update
wsl -d ASUS-Workbench -u root -- apt-get install -y dos2unix
:: Convert all .sh files to Unix line endings
wsl -d ASUS-Workbench -- bash -c "find /usr/share/asus-llm/env -type f -name '*.sh' -exec dos2unix {} +"

:: 在 WSL 中为所有 .sh 文件添加执行权限
wsl -d ASUS-Workbench -- bash -c "chmod +x /usr/share/asus-llm/env/*.sh"

:: 确保所有子目录中的 .sh 文件也有执行权限
wsl -d ASUS-Workbench -- bash -c "find /usr/share/asus-llm/env -type f -name '*.sh' -exec chmod +x {} +"

:: 在 WSL 中执行脚本
wsl -d ASUS-Workbench -- bash -ic "cd /usr/share/asus-llm/env && ./install.sh"
if %errorlevel% neq 0 (
    echo Installing failed.
    exit /b %errorlevel%
)

echo File copied and executed successfully.
endlocal
@REM pause
