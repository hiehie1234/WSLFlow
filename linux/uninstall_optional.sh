#!/bin/bash

# 卸载可选依赖项，如 deepspeed

# 检查并卸载 deepspeed
if pip show deepspeed &> /dev/null; then
    echo "卸载 deepspeed..."
    pip uninstall -y deepspeed
else
    echo "deepspeed 未安装。"
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