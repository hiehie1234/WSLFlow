
#!/bin/bash

# 命名环境名称为ENV_NAME=FlexTuner
ENV_NAME=FlexTuner
LMF_DIR="/usr/lib/asus-llm/LLaMA-Factory"

# 初始化conda环境配置
source ~/.bashrc
eval "$(conda shell.bash hook)"

# 激活conda环境
conda activate $ENV_NAME
echo "$ENV_NAME activated."

# cd $HOME/$ENV_NAME/src
cd $LMF_DIR
pip install -e ".[metrics]" --timeout 600
if [ $? -ne 0 ]; then
  echo "Error: Failed to install dependencies."
fi