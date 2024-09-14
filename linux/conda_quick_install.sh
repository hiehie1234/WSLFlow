#!/bin/bash

# 创建目录并下载 Miniconda 安装脚本
mkdir -p ~/miniconda3
if ! wget --tries=10 --timeout=60 --waitretry=5 --no-check-certificate https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh; then
    echo "downloading miniconda.sh failed."
    exit 1
fi

# 安装 Miniconda
if ! bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3; then
    echo "Miniconda 安装失败。"
    exit 1
fi
# 删除安装脚本
rm -rf ~/miniconda3/miniconda.sh

# 初始化 conda
~/miniconda3/bin/conda init bash
~/miniconda3/bin/conda init zsh

exit 0