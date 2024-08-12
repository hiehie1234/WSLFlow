#!/bin/bash

# 加载用户的环境变量
source ~/.bashrc

# 检查是否已经安装了 conda
if command -v conda &> /dev/null; then
    echo "Conda 已经安装。"
else
    echo "Conda 未安装，开始安装 Miniconda。"
    # 安装conda工具,调用conda_quick_install.sh脚本
    ./conda_quick_install.sh

    source ~/.bashrc
    
    # 再次判断防止conda未安装成功
    if ! command -v conda &> /dev/null; then
        echo "Conda 安装失败，请检查安装脚本。"
        exit 1
    fi
fi

# 新建conda环境,调用env_init.sh脚本
./env_init.sh

# 安装lmf源码，调用install_lmf.sh脚本
./install_lmf.sh

# 前置条件需要先安装CUDA和CUDNN
./install_cuda.sh

# 安装其它可选依赖如deepspeed
./install_optional.sh