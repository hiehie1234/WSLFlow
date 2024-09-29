@echo off

wsl -d ASUS-Workbench -e bash -ic "cd /usr/share/asus-llm/env && pwd && ./kill_process.sh %1"
if %errorlevel% neq 0 (
    echo llamafactory-cli error
    exit /b %errorlevel%
)
exit 0