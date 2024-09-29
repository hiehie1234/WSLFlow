@echo off
set "ENV_NAME=FlexTuner"

wsl -d ASUS-Workbench -e bash -ic "source ~/.bashrc && conda activate %ENV_NAME% && conda env list && cd /usr/share/asus-llm/env && pwd && ./run.sh %1"
if %errorlevel% neq 0 (
    echo llamafactory-cli error
    exit /b %errorlevel%
)
exit 0