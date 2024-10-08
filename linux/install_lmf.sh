
#!/bin/bash

# 命名环境名称为ENV_NAME=FlexTuner
ENV_NAME=FlexTuner

# 初始化conda环境配置
eval "$(conda shell.bash hook)"

# 激活conda环境
conda activate $ENV_NAME
echo "环境 $ENV_NAME 已激活。"

# install source code from github
git clone --depth 1 -b feature https://github.com/hiehie1234/LLaMA-Factory.git "$HOME/$ENV_NAME/src" --config http.lowSpeedLimit=0 --config http.lowSpeedTime=99999
if [ $? -ne 0 ]; then
  echo "Error: Failed to clone repository."
fi

cd $HOME/$ENV_NAME/src
pip install -e ".[metrics]" --timeout 600

echo "环境 $ENV_NAME 关闭。"

