#!/bin/bash

# 命名环境名称为ENV_NAME=FlexTuner
ENV_NAME=FlexTuner

# 初始化conda环境配置
eval "$(conda shell.bash hook)"

# 确保退出base环境
conda deactivate

# 激活conda环境
conda activate $ENV_NAME
echo "环境 $ENV_NAME 已成功创建并激活。"

# 检查并卸载 deepspeed
if pip show deepspeed &> /dev/null; then
    echo "卸载 deepspeed..."
    pip uninstall -y deepspeed
else
    echo "deepspeed 未安装。"
fi

# 检查并卸载 bitsandbytes
if pip show bitsandbytes &> /dev/null; then
    echo "卸载 bitsandbytes..."
    pip uninstall -y bitsandbytes
else
    echo "bitsandbytes 未安装。"
fi

# 你可以在这里添加更多可选依赖项的卸载逻辑
# 例如：
# if pip show some_optional_package &> /dev/null; then
#     echo "卸载 some_optional_package..."
#     pip uninstall -y some_optional_package
# else
#     echo "some_optional_package 未安装。"
# fi

echo "可选依赖项卸载完成。"