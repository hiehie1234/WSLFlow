#!/bin/bash

# 修复libcurand.so找不到，FAILED: cpu_adam.so
USER_HOME=$(eval echo ~${SUDO_USER:-$USER})
TARGET_PATH="$USER_HOME/miniconda3/envs/FlexTuner/lib/python3.11/site-packages/torch/lib/libcurand.so"
SOURCE_PATH="/usr/local/cuda/lib64/libcurand.so"

# 检查源路径是否存在
if [ ! -e "$SOURCE_PATH" ]; then
    echo "源路径 $SOURCE_PATH 不存在"
    exit 1
fi

# 检查目标路径是否存在
if [ -e "$TARGET_PATH" ]; then
    # 删除现有的符号链接或文件
    rm -f "$TARGET_PATH"
fi

# 创建新的符号链接
ln -s "$SOURCE_PATH" "$TARGET_PATH"