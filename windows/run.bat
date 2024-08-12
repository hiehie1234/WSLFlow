@echo off

set "ENV_NAME=FlexTuner"
:: 获取 WSL 用户名
for /f "tokens=* USEBACKQ" %%F in (`wsl whoami`) do set "wsl_username=%%F"

:: 在 WSL conda ENV_NAME 环境中执行脚本
:: 启动lmf-cli webui
wsl -e bash -ic "source ~/.bashrc && conda activate %ENV_NAME% && conda env list && cd $HOME/%ENV_NAME%/src && pwd && llamafactory-cli webui"

pause