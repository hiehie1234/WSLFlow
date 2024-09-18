@echo off

:: 将分布版设置为默认值
wsl --set-default Ubuntu
if %errorlevel% neq 0 (
    echo 操作失败。
    exit /b %errorlevel%
)

set "ENV_NAME=FlexTuner"
:: 获取 WSL 用户名
for /f "tokens=* USEBACKQ" %%F in (`wsl whoami`) do set "wsl_username=%%F"

:: 在 WSL conda ENV_NAME 环境中执行脚本
:: 启动lmf-cli webui
wsl -e bash -ic "source ~/.bashrc && conda activate %ENV_NAME% && conda env list && cd /usr/lib/asus-llm/LLaMA-Factory && pwd && llamafactory-cli webui"

:: 等待5秒后 开启浏览器 localhost:7860
timeout /t 5 /nobreak >nul
start http://localhost:7860

@REM pause