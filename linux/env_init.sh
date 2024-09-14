#!/bin/bash

# 命名环境名称为ENV_NAME=FlexTuner
ENV_NAME=FlexTuner

source ~/.bashrc
# 初始化conda环境配置
eval "$(conda shell.bash hook)"
# conda创建python==3.11环境
conda create -n $ENV_NAME python=3.11 -y

# 确保退出base环境
# conda deactivate

# 检查环境是否存在
if conda info --envs | grep -q "$ENV_NAME"; then
    # 激活conda环境
    conda activate $ENV_NAME
    # 捕获命令的退出状态
    if [ $? -eq 0 ]; then
        echo "$ENV_NAME activated successfully."
    else
        echo "$ENV_NAME activated failed."
        exit 1
    fi
else
    echo "$ENV_NAME does not exist."
    exit 1
fi

conda list python

# install some_package
conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia -y
conda list torch
exit 0