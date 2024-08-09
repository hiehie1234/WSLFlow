@echo off

set "ENV_NAME=FlexTuner"
:: 获取 WSL 用户名
for /f "tokens=* USEBACKQ" %%F in (`wsl whoami`) do set "wsl_username=%%F"
echo %wsl_username%
:: WSL 列出conda 环境列表
wsl -e bash -ic "source ~/.bashrc && conda env list"

:: 在 WSL conda ENV_NAME 环境中执行脚本
:: 启动lmf-cli webui
wsl -e bash -ic "source ~/.bashrc && conda activate %ENV_NAME% && cd /home/%wsl_username%/%ENV_NAME%/src && llamafactory-cli webui"

pause