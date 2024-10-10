#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <model_name_or_path>"
    exit 1
fi

MODEL_NAME_OR_PATH=$1

# Get the directory of the current script
SCRIPT_DIR=$(dirname "$0")

# Get memory usage
memory_usage=$(free -m | grep Mem | awk '{print $3, $2}')

# Get SSD usage
ssd_usage=$(df -h | grep '/$' | awk '{print $3, $2}')

# Get GPU memory usage
gpu_memory_usage=$(nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits | awk -F, '{print $1, $2}')

# Extract values
used_ram=$(echo $memory_usage | awk '{print $1}')
total_ram=$(echo $memory_usage | awk '{print $2}')
used_ssd=$(echo $ssd_usage | awk '{print $1}' | sed 's/G//')
total_ssd=$(echo $ssd_usage | awk '{print $2}' | sed 's/G//')
used_memory=$(echo $gpu_memory_usage | awk '{print $1}')
total_memory=$(echo $gpu_memory_usage | awk '{print $2}')

# Activate the Conda environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate FlexTuner
pwd
# Call the Python script with the extracted values
python "$SCRIPT_DIR/cal_mem.py" --used-memory $used_memory --used-ram $used_ram --used-ssd $used_ssd --total-memory $total_memory --total-ram $total_ram --total-ssd $total_ssd --model-path "$MODEL_NAME_OR_PATH"