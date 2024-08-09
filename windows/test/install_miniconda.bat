@echo off
setlocal

:: 获取 WSL 用户名
for /f "tokens=* USEBACKQ" %%F in (`wsl whoami`) do set "wsl_username=%%F"

:: 创建 Miniconda3 目录
wsl mkdir -p /home/%wsl_username%/miniconda3

:: 下载 Miniconda 安装脚本
wsl wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /home/%wsl_username%/miniconda3/miniconda.sh

:: 安装 Miniconda
wsl bash -c "bash /home/%wsl_username%/miniconda3/miniconda.sh -b -u -p /home/%wsl_username%/miniconda3"

:: 初始化 conda for bash 和 zsh
wsl bash -c "/home/%wsl_username%/miniconda3/bin/conda init bash"
wsl bash -c "/home/%wsl_username%/miniconda3/bin/conda init zsh"

:: 删除安装脚本
wsl rm -rf /home/%wsl_username%/miniconda3/miniconda.sh

echo Miniconda 已成功安装并初始化到 WSL2。
pause
