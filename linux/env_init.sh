#!/bin/bash

# 命名环境名称为ENV_NAME=FlexTuner
ENV_NAME=FlexTuner
ISME=${SUDO_USER:-$(id -un)}
HOUSE="`cat /etc/passwd |grep ^${SUDO_USER:-$(id -un)}: | cut -d: -f 6`"
HOUSE=${HOUSE:-$HOME}

source $HOUSE/.bashrc
# 初始化conda环境配置
eval "$($HOUSE/miniconda3/bin/conda shell.bash hook)"

# 检查脚本是否以sudo执行
if [ "$EUID" -eq 0 ]; then
    # 以非sudo用户身份执行conda create命令
    sudo -u $ISME $HOUSE/miniconda3/bin/conda create -n $ENV_NAME python=3.11 -y
else
    # 直接执行conda create命令
    $HOUSE/miniconda3/bin/conda create -n $ENV_NAME python=3.11 -y
fi

# 确保退出base环境
# conda deactivate

# 激活conda环境
# 检查环境是否存在
if $HOUSE/miniconda3/bin/conda info --envs | grep -q "$ENV_NAME"; then
  sudo -u $ISME bash -c "
    source $HOUSE/.bashrc
    eval \"\$($HOUSE/miniconda3/bin/conda shell.bash hook)\"
    
    conda activate $ENV_NAME
    if [ $? -ne 0 ]; then
        echo \"Failed to activate $ENV_NAME.\"
        exit 1
    fi
    echo \"$ENV_NAME activated.\"
    
    conda list python    
    conda install pytorch==2.2.1 torchvision==0.17.1 torchaudio==2.2.1 pytorch-cuda=12.1 -c pytorch -c nvidia -y
    if [ $? -ne 0 ]; then
        echo \"Failed to install PyTorch and related packages.\"
        exit 1
    fi
    
    conda list torch
    if [ $? -ne 0 ]; then
        echo \"Failed to list Torch packages.\"
        exit 1
    fi
  "
else
    echo "$ENV_NAME does not exist."
    exit 1
fi

exit 0