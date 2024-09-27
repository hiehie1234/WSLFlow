#!/bin/bash
ENV_NAME=FlexTuner
cd /usr/share/asus-llm/env/
current_dir=$(cd $(dirname $0); pwd)
pwd
echo "Current dir: $current_dir"
HOUSE="`cat /etc/passwd |grep ^${SUDO_USER:-$(id -un)}: | cut -d: -f 6`"
HOUSE=${HOUSE:-$HOME}

# 加载用户的环境变量
source $HOUSE/.bashrc

# 初始化 conda 环境
eval "$($HOUSE/miniconda3/bin/conda shell.bash hook)"

# 调试信息：尝试查找 conda
echo "调试信息：尝试查找 conda"
command -v conda

# 检查是否已经安装了 conda
if command -v conda &> /dev/null; then
    echo "Conda installed."
else
    echo "Conda not installed, start to install conda."
    # 安装conda工具,调用conda_quick_install.sh脚本
    if ! "$current_dir/conda_quick_install.sh"; then
        echo "Conda 安装脚本执行失败。"
        exit 1
    fi
    
    sleep 3
    # 重新加载用户的环境变量
    echo "source $HOUSE/.bashrc"
    source $HOUSE/.bashrc

    # 初始化 conda 环境
    eval "$($HOUSE/miniconda3/bin/conda shell.bash hook)"
    
    # 再次判断防止conda未安装成功
    if ! command -v conda &> /dev/null; then
        echo "FAILED to install, please check the installation script."
        exit 1
    fi
fi

# 新建conda环境,调用env_init.sh脚本
$current_dir/env_init.sh
# 检查退出状态码
if [ $? -ne 0 ]; then
  echo "env_init.sh execution failed"
  exit 1
else
  echo "env_init.sh executed successfully"
fi
# 检查环境是否存在
if conda info --envs | grep -q "$ENV_NAME"; then
    # 激活conda环境
    conda activate $ENV_NAME
    echo "环境 $ENV_NAME 已成功激活。"
else
    echo "环境 $ENV_NAME 不存在，无法激活。"
    echo "尝试重新创建环境..."
    $current_dir/env_init.sh
fi

# 安装lmf源码，调用install_lmf.sh脚本
./install_lmf.sh

# 前置条件需要先安装CUDA和CUDNN
# 判断是否有安装cuda
if [ -d "/usr/local/cuda" ]; then
    echo "CUDA 已经安装。"
else
    echo "CUDA 未安装，开始安装 CUDA。"
    # 安装cuda工具,调用install_cuda.sh脚本
    ./install_cuda.sh
fi

# 安装其它可选依赖如deepspeed
./install_optional.sh

# 安装补丁
# ./patch_env.sh