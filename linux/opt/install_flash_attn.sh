#!/bin/bash

# https://github.com/Dao-AILab/flash-attention

# 更新系统包管理器
sudo apt-get update

# 安装必要的依赖项
sudo apt-get install -y build-essential cmake ninja-build

# 安装 CUDA（如果尚未安装）
sudo apt-get install -y cuda

# 安装 PyTorch
pip install torch torchvision torchaudio

# 安装 flash-attn
pip install flash-attn --no-build-isolation

echo "flash-attn 安装完成！"
