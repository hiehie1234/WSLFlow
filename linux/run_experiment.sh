#!/bin/bash
current_dir=$(cd $(dirname $0); pwd)
ENV_NAME=FlexTuner
# Check if the correct number of arguments are provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <yaml_path>"
    exit 1
fi

# Assign arguments to variables
YAML_PATH=$1
echo "file_path: $YAML_PATH"
# Activate the Conda environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate FlexTuner
pwd
if conda info --envs | grep -q "$ENV_NAME"; then
    if [ -z "$1" ]; then
      echo "Please provide a yaml file path as a parameter."
      exit 1
    fi
    cd /usr/lib/asus-llm/LLaMA-Factory
    pwd
    # Run the command
    llamafactory-cli train "$YAML_PATH" &
    # Capture the pid and save it
    echo "runing"
    sleep 1
    PID=$!
    echo "llm PID : $PID"
    cd $current_dir
    pwd
    # 检查当前目录是否有写权限
    if [ -w "$current_dir" ]; then
        echo $PID > pidfile
    else
        echo "Permission denied, Try creating in tmp dir"
        echo $PID > /tmp/pidfile
    fi
    # 等待后台进程完成
    wait $PID
else
    echo "env $ENV_NAME activate fail."
fi