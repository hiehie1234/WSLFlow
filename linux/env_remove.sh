#!/bin/bash

# 检查是否安装了 Conda
if ! command -v conda &> /dev/null
then
    echo "Conda is not installed."
    exit 1
fi

# 指定要删除的 conda 环境名称
ENV_NAME=FlexTuner

# # 确认用户输入
# read -p "你确定要卸载环境 $ENV_NAME 吗？(y/n): " CONFIRM
# if [ "$CONFIRM" != "y" ]; then
#     echo "操作已取消。"
#     exit 1
# fi

# 卸载选定的环境
conda env remove -n "$ENV_NAME"

# 检查卸载是否成功
if [ $? -eq 0 ]; then
    echo "$ENV_NAME uninstalled successfully."
else
    echo "$ENV_NAME uninstallation failed."
    exit 1
fi

