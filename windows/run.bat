@echo off

wsl --set-default Ubuntu
if %errorlevel% neq 0 (
    echo set default error
    exit /b %errorlevel%
)

set "ENV_NAME=FlexTuner"

wsl -e bash -ic "source ~/.bashrc && conda activate %ENV_NAME% && conda env list && cd /usr/share/asus-llm/env && pwd && ./run.sh %1"
if %errorlevel% neq 0 (
    echo llamafactory-cli error
    exit /b %errorlevel%
)
exit 0