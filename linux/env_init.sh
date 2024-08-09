#!/bin/bash

# 命名环境名称为ENV_NAME=FlexTuner
ENV_NAME=FlexTuner

# conda创建python==3.11环境
conda create -n $ENV_NAME python=3.11 -y

# 初始化conda环境配置
eval "$(conda shell.bash hook)"

# 确保退出base环境
# conda deactivate

# 激活conda环境
conda activate $ENV_NAME
echo "环境 $ENV_NAME 已成功创建并激活。"
conda list python

# install some_package
conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia -y
echo "torch 安装完成！"
conda list torch

echo "环境 $ENV_NAME 关闭。"

