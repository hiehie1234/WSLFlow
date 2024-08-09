@echo off
setlocal

:: 获取 WSL 用户名
for /f "tokens=* USEBACKQ" %%F in (`wsl whoami`) do set "wsl_username=%%F"

:: 创建一个临时脚本来配置 sudo
echo %wsl_username% ALL=(ALL) NOPASSWD:ALL > temp_sudoers
wsl sudo cp temp_sudoers /etc/sudoers.d/%wsl_username%
wsl sudo chmod 0440 /etc/sudoers.d/%wsl_username%
del temp_sudoers

:: 更新包列表并安装必要的依赖项
wsl sudo apt-get update
wsl sudo apt-get install -y build-essential dkms

:: 下载 CUDA 12.1 安装包、
wsl wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin -O ~/cuda-wsl-ubuntu.pin
wsl sudo mv /home/%wsl_username%/cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
wsl wget https://developer.download.nvidia.com/compute/cuda/12.1.0/local_installers/cuda-repo-wsl-ubuntu-12-1-local_12.1.0-1_amd64.deb -O ~/cuda-repo-wsl-ubuntu-12-1-local_12.1.0-1_amd64.deb

:: 计算本地文件的 MD5 校验值
:: for /f "tokens=* USEBACKQ" %%F in (`wsl md5sum ~/cuda-repo-wsl-ubuntu-12-1-local_12.1.0-1_amd64.deb`) do set "local_md5=%%F"
for /f "tokens=1" %%i in ('wsl md5sum ~/cuda-repo-wsl-ubuntu-12-1-local_12.1.0-1_amd64.deb') do set local_md5=%%i

:: 下载 MD5 校验值文件
wsl wget https://developer.download.nvidia.com/compute/cuda/12.1.0/docs/sidebar/md5sum.txt -O ~/md5sum.txt

:: 从 MD5 校验值文件中获取正确的 MD5 校验值
for /f "tokens=1,2 delims= " %%A in ('wsl grep "cuda-repo-wsl-ubuntu-12-1-local_12.1.0-1_amd64.deb" ~/md5sum.txt') do set "correct_md5=%%A"

:: 比较 MD5 校验值
if "%local_md5%" == "%correct_md5%" (

    :: 安装 CUDA 12.1
    wsl sudo dpkg -i /home/%wsl_username%/cuda-repo-wsl-ubuntu-12-1-local_12.1.0-1_amd64.deb
    wsl sudo cp /var/cuda-repo-wsl-ubuntu-12-1-local/cuda-*-keyring.gpg /usr/share/keyrings/
    wsl sudo apt-get update
    wsl sudo apt-get install -y cuda

    :: 设置环境变量
    wsl bash -c "grep -qxF 'export PATH=/usr/local/cuda-12.1/bin${PATH:+:\$PATH}' ~/.bashrc || echo 'export PATH=/usr/local/cuda-12.1/bin${PATH:+:\$PATH}' >> ~/.bashrc"
    wsl bash -c "grep -qxF 'export LD_LIBRARY_PATH=/usr/local/cuda-12.1/lib64${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}' ~/.bashrc || echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.1/lib64${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}' >> ~/.bashrc"
    :: 重新加载 .bashrc 文件
    wsl bash -c "source /home/%wsl_username%/.bashrc"
    
    echo CUDA 12.1 已成功安装到 WSL2。
    wsl rm -rf ~/md5sum.txt
) else (
    echo MD5 校验失败，文件可能已损坏，请重新尝试。
)

echo CUDA 12.1 已成功安装到 WSL2。
endlocal
pause
