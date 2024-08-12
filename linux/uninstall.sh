#!/bin/bash

# 加载用户的环境变量
source ~/.bashrc

# # 卸载其它可选依赖如deepspeed
# echo "卸载可选依赖..."
# ./uninstall_optional.sh

# 卸载CUDA和CUDNN
./uninstall_cuda.sh
# 卸载lmf源码
echo "卸载lmf源码..."
./uninstall_lmf.sh
# 删除conda环境
./env_remove.sh
# 检查是否已经安装了 conda
if command -v conda &> /dev/null; then
    echo "卸载Miniconda..."
    # 卸载conda工具,调用conda_uninstall.sh脚本
    ./conda_uninstall.sh
else
    echo "Conda 未安装，无需卸载。"
fi

echo "卸载完成。"