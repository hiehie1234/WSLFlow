
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

# # install source code from github
# git clone --depth 1 -b feature https://github.com/hiehie1234/LLaMA-Factory.git "$HOME/$ENV_NAME/src" --config http.lowSpeedLimit=0 --config http.lowSpeedTime=99999
# if [ $? -ne 0 ]; then
#   echo "Error: Failed to clone repository."
# fi

# cd $HOME/$ENV_NAME/src
cd $LMF_DIR
pip install -e ".[metrics]" --timeout 600
if [ $? -ne 0 ]; then
  echo "Error: Failed to install dependencies."
fi