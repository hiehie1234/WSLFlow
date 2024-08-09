#!/bin/bash

# 更新系统包管理器
sudo apt-get update

# 安装必要的依赖项
sudo apt-get install -y build-essential cmake

# 安装 CUDA（如果尚未安装）
sudo apt-get install -y cuda

# 克隆 bitsandbytes 仓库并安装
git clone https://github.com/TimDettmers/bitsandbytes.git
cd bitsandbytes
pip install -r requirements-dev.txt
cmake -DCOMPUTE_BACKEND=cuda -S .
make
pip install .

echo "bitsandbytes 安装完成！"

# chmod +x install_bitsandbytes.sh
# ./install_bitsandbytes.sh
