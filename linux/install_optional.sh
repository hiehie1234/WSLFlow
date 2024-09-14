#!/bin/bash

# 命名环境名称为ENV_NAME=FlexTuner
ENV_NAME=FlexTuner

# 初始化conda环境配置
source ~/.bashrc
eval "$(conda shell.bash hook)"

# 确保退出base环境
# conda deactivate

# 激活conda环境
conda activate $ENV_NAME
echo "环境 $ENV_NAME 已成功创建并激活。"

# [Mandatory]
if ! python -c "import torch" &> /dev/null; then
	conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia -y
	echo "torch 安装完成！"
else
	echo "torch 已经安装。"
fi

conda list torch
# 更新系统包管理器
sudo apt-get update

# 这里判断是否安装了build-essential和libaio-dev，未安装再进行安装必要的依赖项
if ! dpkg -s build-essential &> /dev/null; then
	sudo apt-get install -y build-essential
fi

if ! dpkg -s libaio-dev &> /dev/null; then
	sudo apt-get install -y libaio-dev
fi

# [optional]
# 安装 NVIDIA CUDA
# ./install_cuda.sh

# [optional]
# 安装 DeepSpeed
pip install deepspeed
# 验证安装
ds_report
echo "DeepSpeed 安装完成！"

# [optional]
# 安装 bitsandbytes
# pip install bitsandbytes

# [optional]
# 安装 flash-attn

echo "环境 $ENV_NAME 关闭。"