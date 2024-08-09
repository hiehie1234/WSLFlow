#!/bin/bash

# 下载 CUDA pin 文件并移动到 apt preferences 目录
wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
sudo mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600

# 下载 CUDA 安装包
CUDA_DEB=cuda-repo-wsl-ubuntu-12-1-local_12.1.1-1_amd64.deb
CUDA_DEB_URL=https://developer.download.nvidia.com/compute/cuda/12.1.1/local_installers/$CUDA_DEB
wget $CUDA_DEB_URL -O $CUDA_DEB

# 下载 MD5 校验值文件
MD5SUM_FILE=md5sum.txt
MD5SUM_URL=https://developer.download.nvidia.com/compute/cuda/12.1.1/docs/sidebar/$MD5SUM_FILE
wget $MD5SUM_URL -O $MD5SUM_FILE

# 从 MD5 校验值文件中获取正确的 MD5 校验值
EXPECTED_MD5=$(grep "$CUDA_DEB" $MD5SUM_FILE | awk '{ print $1 }')
echo "Expected MD5: $EXPECTED_MD5"
# 对 CUDA 安装包做 md5sum 得到当前下载档的 MD5 值
ACTUAL_MD5=$(md5sum $CUDA_DEB | awk '{ print $1 }')

# 比较 MD5 校验值，如果不匹配，则退出并警告用户
if [ "$EXPECTED_MD5" != "$ACTUAL_MD5" ]; then
    echo "MD5 校验值不匹配，下载的 $CUDA_DEB 文件可能已损坏。"
    exit 1
fi

# 安装 CUDA 包
sudo dpkg -i $CUDA_DEB

# 复制 keyring 文件
sudo cp /var/cuda-repo-wsl-ubuntu-12-1-local/cuda-*-keyring.gpg /usr/share/keyrings/

# 更新 apt-get 并安装 CUDA
sudo apt-mark hold cuda
sudo apt-get update
sudo apt-get -y install cuda-12-1

# 删除下载的 CUDA 包和 MD5 校验值文件
# rm $CUDA_DEB $MD5SUM_FILE

# 添加环境变量到 .bashrc
cuda_path='export PATH=/usr/local/cuda/bin:$PATH'
cuda_ld_library_path='export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH'

# 检查 .bashrc 文件中是否已经包含这些内容
if ! grep -qxF "$cuda_path" ~/.bashrc; then
    echo "$cuda_path" >> ~/.bashrc
fi

if ! grep -qxF "$cuda_ld_library_path" ~/.bashrc; then
    echo "$cuda_ld_library_path" >> ~/.bashrc
fi

# 重新加载 .bashrc 以使环境变量生效
source ~/.bashrc