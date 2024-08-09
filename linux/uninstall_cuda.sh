#!/bin/bash

# 卸载 CUDA 和 CUDNN

# 检查并卸载 CUDA
if dpkg-query -W cuda &> /dev/null; then
    echo "卸载 CUDA..."
    sudo apt-get --purge remove cuda -y
    sudo apt-get autoremove -y
    sudo apt-get autoclean
else
    echo "CUDA 未安装。"
fi

# 检查并卸载 CUDNN
if dpkg-query -W libcudnn8 &> /dev/null; then
    echo "卸载 CUDNN..."
    sudo apt-get --purge remove libcudnn8* -y
    sudo apt-get autoremove -y
    sudo apt-get autoclean
else
    echo "CUDNN 未安装。"
fi

echo "CUDA 和 CUDNN 卸载完成。"

# 删除 CUDA 环境变量
# 删除 CUDA 环境变量
sed -i '/\/usr\/local\/cuda\/bin/d' ~/.bashrc
sed -i '/\/usr\/local\/cuda\/lib64/d' ~/.bashrc

sed -i '/\/usr\/local\/cuda\/bin/d' ~/.zshrc
sed -i '/\/usr\/local\/cuda\/lib64/d' ~/.zshrc


# 重新加载 .bashrc 和 .zshrc 以使更改生效
source ~/.bashrc
source ~/.zshrc