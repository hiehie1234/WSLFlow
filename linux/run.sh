#!/bin/bash
current_dir=$(cd $(dirname $0); pwd)
# 命名环境名称为ENV_NAME=FlexTuner
ENV_NAME=FlexTuner

HOUSE="`cat /etc/passwd |grep ^${SUDO_USER:-$(id -un)}: | cut -d: -f 6`"
HOUSE=${HOUSE:-$HOME}

# 初始化conda环境配置
source $HOUSE/.bashrc
eval "$($HOUSE/miniconda3/bin/conda shell.bash hook)"

# 确保退出base环境
conda deactivate

# 激活conda环境
conda activate $ENV_NAME
echo "conda activate $ENV_NAME"

if conda info --envs | grep -q "$ENV_NAME"; then
    if [ -z "$1" ]; then
      echo "Please provide a yaml file path as a parameter."
      exit 1
    fi
    file_path="$1"
    echo "file_path: $file_path"
    cd /usr/lib/asus-llm/LLaMA-Factory
    pwd
    # 启动llamafactory-cli webui
    llamafactory-cli train "$file_path" &
    echo "命令已启动"
    sleep 1
    PID=$!
    echo "获取到的 PID 是: $PID"
    cd $current_dir
    pwd
    # 检查当前目录是否有写权限
    if [ -w "$current_dir" ]; then
        echo $PID > pidfile
    else
        echo "当前目录没有写权限，尝试在用户主目录下创建pidfile。"
        echo $PID > $HOUSE/pidfile
    fi
    # 等待后台进程完成
    wait $PID
else
    echo "env $ENV_NAME activate fail."
fi