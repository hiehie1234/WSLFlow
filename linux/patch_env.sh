#!/bin/bash

# 命名环境名称为ENV_NAME=FlexTuner
ENV_NAME=FlexTuner

# 初始化conda环境配置
source ~/.bashrc
eval "$(conda shell.bash hook)"

# 确保退出base环境
# conda deactivate

# 激活conda环境
conda activate $ENV_NAME

# 获取transformers包路径
TRANSFORMERS_PATH=$(python -c "import transformers; print(transformers.__path__[0])")

# 输出路径（可选）
echo "Transformers package path: $TRANSFORMERS_PATH"

# 检查补丁文件是否存在
PATCH_FILE="./patch/token_sec.patch"
if [ ! -f "$PATCH_FILE" ]; then
  echo "Patch file $PATCH_FILE does not exist"
  echo "Patch file path: $PATCH_FILE"
  exit 1
fi

# 应用补丁
if patch -p0 -d "$TRANSFORMERS_PATH" < "$PATCH_FILE"; then
  echo "Patch successfully applied to $TRANSFORMERS_PATH/trainer.py"
else
  echo "Patch application failed"
  exit 1
fi