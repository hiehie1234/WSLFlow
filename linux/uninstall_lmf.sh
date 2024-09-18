#!/bin/bash

# 卸载 lmf 源码

# 假设 lmf 源码安装在 /usr/local/lmf 目录下
# 命名环境名称为ENV_NAME=FlexTuner
ENV_NAME=FlexTuner
# LMF_DIR="$HOME/$ENV_NAME/src"
LMF_DIR="/usr/lib/asus-llm/LLaMA-Factory"

# $LMF_DIR = ~/FlexTuner/src
echo $LMF_DIR 
if [ -d "$LMF_DIR" ]; then
    echo "卸载 lmf 源码..."
    sudo rm -rf "$LMF_DIR"
    echo "lmf 源码已卸载。"
else
    echo "lmf 源码目录不存在。"
fi

echo "lmf 源码卸载完成。"