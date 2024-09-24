#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <model_name_or_path> <dataset_dir> <dataset_name> <output_dir>"
    exit 1
fi

# Assign arguments to variables
MODEL_NAME_OR_PATH=$1
DATASET_DIR=$2
DATASET_NAME=$3
OUTPUT_DIR=$4

# Activate the Conda environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate FlexTuner
pwd
# Run the command
llamafactory-cli train \
  --stage sft \
  --do_train True \
  --model_name_or_path "$MODEL_NAME_OR_PATH" \
  --preprocessing_num_workers 16 \
  --finetuning_type lora \
  --template default \
  --flash_attn auto \
  --dataset_dir "$DATASET_DIR" \
  --dataset "$DATASET_NAME"\
  --cutoff_len 1024 \
  --learning_rate 5e-05 \
  --num_train_epochs 3.0 \
  --max_samples 100000 \
  --per_device_train_batch_size 2 \
  --gradient_accumulation_steps 8 \
  --lr_scheduler_type cosine \
  --max_grad_norm 1.0 \
  --logging_steps 5 \
  --save_steps 100 \
  --warmup_steps 0 \
  --optim adamw_torch \
  --packing False \
  --report_to none \
  --output_dir "$OUTPUT_DIR" \
  --fp16 True \
  --plot_loss True \
  --ddp_timeout 180000000 \
  --include_num_input_tokens_seen True \
  --lora_rank 8 \
  --lora_alpha 16 \
  --lora_dropout 0 \
  --lora_target all
