#!/bin/bash

# 检查是否安装了 miniconda
if [ -d "$HOME/miniconda3" ]; then
    # 提示用户确认是否卸载
    read -p "你确定要卸载 Miniconda 吗？(y/n): " CONFIRM
    if [ "$CONFIRM" == "y" ]; then
        # 卸载 miniconda
        rm -rf "$HOME/miniconda3"
        echo "Miniconda 已成功卸载。"
    else
        echo "操作已取消。"
    fi
else
    echo "Miniconda 未安装。"
fi