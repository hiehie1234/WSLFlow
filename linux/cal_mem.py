from transformers import AutoConfig, AutoModelForCausalLM
import torch
import io
import sys
import deepspeed
import re
import json
import argparse
import math
FILE_NAME = "estimate"
FOLDER_PATH = "/usr/lib/asus-llm/LLaMA-Factory/log"
FILE_PATH = FOLDER_PATH + "/" + FILE_NAME + ".json"

def content_to_json(content):
    #print("---" * 3)
    #print(content)
    #print("---" * 3)
    # 先將每個不同設置拆分為一個塊
    blocks = content.strip().split("Estimated memory needed for params, optim states and gradients for a:")
 
    json_data = []
   
    for block in blocks:
        if not block.strip():
            continue
       
        # 匹配硬件設置（HW）和軟件設置（SW）
        hw_match = re.search(r"HW:\s*(.*?)\.\s*", block)
        sw_match = re.search(r"SW:\s*(.*?)\s*\n", block)
       
        if not hw_match or not sw_match:
            continue
       
        hw = hw_match.group(1)
        sw = sw_match.group(1)
       
        # 匹配每行的數據
        option_matches = re.findall(r"\s*(\d+\.\d+)\s*(GB|MB)\s*\|\s*(\d+\.\d+)\s*(GB|MB)\s*\|\s*(.+)", block)
 
        # 建立每個配置的字典
        for per_cpu, per_cpu_unit, per_gpu,  per_gpu_unit, options in option_matches:
            config = {
                "HW": hw,
                "SW": sw,
                "per_CPU": float(per_cpu),
                "per_cpu_unit": per_cpu_unit,
                "per_GPU": float(per_gpu),
                "per_gpu_unit": per_gpu_unit,
                "Options": options.strip()
            }
            json_data.append(config)
   
    return json_data


def cal_deepspeed_memory_consumption(model, num_gpus_per_node = 1, num_nodes = 1):
 
    # 創建一個字符串緩衝區
    buffer = io.StringIO()
 
    # 保存當前的標準輸出 (sys.stdout)
    original_stdout = sys.stdout
 
    try:
        # 將標準輸出重定向到字符串緩衝區
        sys.stdout = buffer
 
        # 估算内存需求
        deepspeed.runtime.zero.stage_1_and_2.estimate_zero2_model_states_mem_needs_all_live(
            model=model,
            num_gpus_per_node=num_gpus_per_node,
            num_nodes=num_nodes
        )
 
        deepspeed.runtime.zero.stage3.estimate_zero3_model_states_mem_needs_all_live(
            model=model,
            num_gpus_per_node=num_gpus_per_node,
            num_nodes=num_nodes
        )
 
 
        # 獲取緩衝區的內容
        output = buffer.getvalue()
 
    finally:
        # 恢復原本的標準輸出
        sys.stdout = original_stdout
 
    # 輸出捕獲的文字
    #print(output)
    json_result = content_to_json(output)
    #print(json.dumps(json_result, indent=2))
    return json_result


# Helper function to pretty-print message sizes
def convert_params(params):
    if params == 0:
        return "0"
    size_name = ("", "K", "M", "B", "T", "P", "E", "Z", "Y")
    i = int(math.floor(math.log(params, 1000)))
    p = math.pow(1000, i)
    s = round(params / p, 2)
    return "%s %s" % (s, size_name[i])    
    
def config_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument("--params", "-p",
                        type=int,
                        default=20000000000,
                        help='Number of Parameters')
    parser.add_argument("--num-gpus",
                        type=int,
                        default=1,
                        help='Number of GPUs used for training')
    parser.add_argument("--tensor-parallel-size", "-tp",
                        type=int,
                        default=1,
                        help='Tensor parallel degree (1 if not used)')
    parser.add_argument("--pipeline-parallel-size", "-pp",
                        type=int,
                        default=1,
                        help='Pipeline parallel degree (1 if not used)')
    parser.add_argument("--partition-activations", "-pa",
                        action="store_true",
                        help='Whether we use ZeRO-R to partition activation memory across tensor-parallel degree')
    parser.add_argument("--zero-stage", "-z",
                        type=int,
                        default=1,
                        choices=[0,1,2,3],
                        help='Stage of the ZeRO optimizer')
    parser.add_argument("--checkpoint-activations", "-ca",
                        action="store_true",
                        default=True,
                        help='Whether Megatron-style activation checkpointing is being used')
    parser.add_argument("--batch-size-per-gpu", "-b",
                        type=int,
                        default=1,
                        help='Batch size per GPU')
    parser.add_argument("--hidden-size", "-hs",
                        type=int,
                        default=6144,
                        help='Dimension of the model\'s hidden size')
    parser.add_argument("--num-attention-heads", "-a",
                        type=int,
                        default=64,
                        help='Number of attention heads used in model')
    parser.add_argument("--sequence-length", "-s",
                        type=int,
                        default=2048,
                        help='Sequence length used for training')
    parser.add_argument("--num-layers", "-l",
                        type=int,
                        default=44,
                        help='Number of transformer layers used in model')
    parser.add_argument("--fp32-model",
                        action="store_true",
                        help='Whether model is stored in fp32')
    parser.add_argument("--fp32-grads",
                        action="store_true",
                        help='Whether grads are stored in fp32')
    parser.add_argument("--zero-allgather-bucket-size", "-zbs",
                        type=int,
                        default=5e8,
                        help='Size of allgather buckets used by ZeRO')
    parser.add_argument("--zero3-max-live-params", "-zmlp",
                        type=int,
                        default=1e9,
                        help='Maximum number of parameters ZeRO3 keeps in GPU memory')
    parser.add_argument("--misc-mem-gb",
                        type=int,
                        default=0,
                        help='Miscellaneous memory overhead by DL framework(s), communication libraries, etc')
    parser.add_argument("--infer",
                        action="store_true",
                        help="whether we're doing inference")
    parser.add_argument("--model-path",
                        type=str,
                        default=0,
                        help='the model path to be trained')
    parser.add_argument("--used-memory",
                        type=float,
                        default=0,
                        help='used memory, unit:GB')
    parser.add_argument("--used-ram",
                        type=float,
                        default=0,
                        help='used ram, unit:GB')
    parser.add_argument("--used-ssd",
                        type=float,
                        default=0,
                        help='used ssd, unit:GB')
    parser.add_argument("--total-memory",
                        type=float,
                        default=0,
                        help='total memory, unit:GB')
    parser.add_argument("--total-ram",
                        type=float,
                        default=0,
                        help='total ram, unit:GB')
    parser.add_argument("--total-ssd",
                        type=float,
                        default=0,
                        help='total ssd, unit:GB')
    return parser

    
def calc_mem(args):


    dp_degree = args.num_gpus / (args.tensor_parallel_size * args.pipeline_parallel_size)

    # 4 bytes in fp32, 2 bytes in fp16/bf16
    if args.fp32_model:
        bytes_per_param = 4
    else:
        bytes_per_param = 2

    # Split the model with 3D parallelism
    model_mem = (args.params * bytes_per_param) / (args.tensor_parallel_size * args.pipeline_parallel_size)
    # ZeRO stage 3 shards the model parameters across GPUs (plus the gradients and optimizer states)
    if args.zero_stage == 3:
        model_mem /= args.num_gpus

    # 4 bytes in fp32, 2 bytes in fp16/bf16
    if args.fp32_grads:
        bytes_per_grad_element = 4
    else:
        bytes_per_grad_element = 2

    gradient_mem = args.params * bytes_per_grad_element
    # ZeRO stage 2 shards the gradients across GPUs (plus the optimizer states)
    if args.zero_stage >= 2:
        gradient_mem /= args.num_gpus
    gradient_mem /= args.pipeline_parallel_size

    # For fp32 Adam/AdamW, the optimizer just stores momentum and variance (4 + 4 = 8 bytes per optimizer parameter)
    # For mixed-precision Adam/AdamW, the optimizer must store fp32 copies of the parameters, momentum, and variance (4 + 4 + 4 = 12 bytes per optimizer parameter)
    # Feel free to change the multiplier for your optimizer (examples include SGD (4 + 4 = 8) and 8-bit ADAM (2 + 2 + 2 = 6)
    if args.fp32_model:
        optimizer_mem = args.params * 8
    else:
        optimizer_mem = args.params * 12
    # ZeRO stage 3 shards the optimizer states across GPUs
    if args.zero_stage >= 1:
        optimizer_mem /= args.num_gpus

    communication_mem = 0
    # The size of the communication buffer DeepSpeed uses to store ZeRO optimizer elements
    if args.zero_stage >= 1:
        communication_mem += args.zero_allgather_bucket_size * bytes_per_param
    # The number of parameters ZeRO-3 keeps alive in GPU memory at a time
    if args.zero_stage == 3:
        communication_mem += args.zero3_max_live_params * bytes_per_param

    # Taken from Table 2 in https://arxiv.org/pdf/1910.02054.pdf
    # We find these don't perfectly match with experiment, but are good approximations
    if args.checkpoint_activations:
        activation_mem = args.sequence_length * args.batch_size_per_gpu * args.hidden_size * args.num_layers * (10 + (24 / args.tensor_parallel_size))
    else:
        activation_mem = args.sequence_length * args.batch_size_per_gpu * args.hidden_size * args.num_layers * (10 + (24 / args.tensor_parallel_size) + 5 * ((args.num_attention_heads * args.sequence_length) / (args.hidden_size * args.tensor_parallel_size)))

    # DeepSpeed's ZeRO-R partitions activation memory across tensor-parallel GPUs
    if args.partition_activations:
        activation_mem /= args.tensor_parallel_size

    if args.infer:
        if args.fp32_model:
            bytes_per_param = 4
        else:
            bytes_per_param = 2
        kv_cache_mem = bytes_per_param * 2 * args.num_layers * args.num_attention_heads * (args.hidden_size / args.num_attention_heads) * args.sequence_length

    # We include a "Miscellaneous Memory" term because we find some 3D-parallel frameworks add a constant memory overhead (~5GB in our experiments with Megatron-DeepSpeed) that we cannot explain. If you know the source of this, add a comment!
    gradient_mem_gb = gradient_mem / 1024**3
    activation_mem_gb = activation_mem / 1024**3
    model_mem_gb = model_mem / 1024**3
    optimizer_mem_gb = optimizer_mem / 1024**3
    communication_mem_gb = communication_mem / 1024**3
    if args.infer:
        kv_cache_mem_gb = kv_cache_mem / 1024**3

    if args.infer:
        total_mem_gb = kv_cache_mem_gb + model_mem_gb + args.misc_mem_gb
    else:
        total_mem_gb = activation_mem_gb + gradient_mem_gb + model_mem_gb + optimizer_mem_gb + communication_mem_gb + args.misc_mem_gb
    #print(f'Calculating memory with training configuration: {vars(args)}\n')
    #print(f'Number of Parameters: {convert_params(args.params)}')
    #print(f'Model Memory: {model_mem_gb:.2f} GB')
    #if args.infer:
    #    print(f'KV Cache Memory: {kv_cache_mem_gb:.2f} GB')
    #else:
    #    print(f'Gradient Memory: {gradient_mem_gb:.2f} GB')
    #    print(f'Activation Memory: {activation_mem_gb:.2f} GB')
    #    print(f'Optimizer Memory: {optimizer_mem_gb:.2f} GB')
    #    print(f'Communication Memory: {communication_mem_gb:.2f} GB')
    #print(f'Miscellaneous Memory: {args.misc_mem_gb:.2f} GB')
    #if args.infer:
    #    print(f'Total Memory Required for Inference: {total_mem_gb:.2f} GB')
    #else:
    #    print(f'Total Memory Required for Training: {total_mem_gb:.2f} GB')
    
    
    memory_estimate = {
        "model_mem_gb": round(model_mem_gb, 2),
        "gradient_mem_gb": round(gradient_mem_gb, 2),
        "activation_mem_gb": round(activation_mem_gb, 2),
        "optimizer_mem_gb": round(optimizer_mem_gb, 2),
        "communication_mem_gb": round(communication_mem_gb, 2),
        "total_mem_gb": round(total_mem_gb, 2)
    }
    return memory_estimate

def select_strategy(args, model_path, system):
    # load model 
    model_config = AutoConfig.from_pretrained(model_path)
    model = AutoModelForCausalLM.from_pretrained(model_path)
    #print(model_config)
    model_size = sum(param.numel() for param in model.parameters())
    #print(f"Model size: {model_size} parameters")
    
    # deepspeed estimator
    total_gpu_memory_zero = cal_deepspeed_memory_consumption(model)
    
    # args setting
    args.params = model_size
    args.hidden_size = model_config.hidden_size
    args.num_attention_heads = model_config.num_attention_heads
    args.num_layers = model_config.num_hidden_layers
    args.fp32_grads = True
    
    print(args)
    #calc_mem(args)
    base_sequence_length = 1024
    for i in range(4):  # 外層迴圈執行 4 次
        for j in range(int(model_config.max_position_embeddings/base_sequence_length)):  
            if(i==0):
                #print("select all in gpu")
                args.zero_stage = 0
                args.sequence_length = base_sequence_length * (j+1)
                memory_estimate = calc_mem(args)
                memory_required = memory_estimate["total_mem_gb"]

                if(memory_required >= system["total_memory"] and j == 0):
                    break;
                elif(memory_required >= system["total_memory"] and j > 0):
                    result = {
                        "strategy": 0,
                        "describe": "all in gpu",
                        "batch_size": 1,
                        "sequence_length": base_sequence_length * j,
                        "memory_estimate": past_memory_estimate,
                        "memory_required": past_memory_required,
                        "ram_required": 0,
                        "nvme_ssd_required": 0
                    }
                    return result
                elif (j == (int(model_config.max_position_embeddings/base_sequence_length) - 1)):
                    result = {
                        "strategy": 0,
                        "describe": "all in gpu",
                        "batch_size": 1,
                        "sequence_length": base_sequence_length * (j+1),
                        "memory_estimate": memory_estimate,
                        "memory_required": memory_required,
                        "ram_required": 0,
                        "nvme_ssd_required": 0
                    }
                    return result
                past_memory_estimate = memory_estimate
                past_memory_required = memory_required
            elif(i==1):
                #print("select zero2-offload")
                ram_required = total_gpu_memory_zero[0]["per_CPU"] + system["used_ram"]
                if(ram_required >= system["total_ram"] ):
                    break
                args.zero_stage = 2
                args.sequence_length = base_sequence_length * (j+1)
                memory_estimate = calc_mem(args)
                memory_required = memory_estimate["model_mem_gb"] + memory_estimate["activation_mem_gb"] + memory_estimate["communication_mem_gb"] 
                if(memory_required >= system["total_memory"] and j == 0):
                    break;
                elif(memory_required >= system["total_memory"] and j > 0):
                    result = {
                        "strategy": 1,
                        "describe": "zero2-offload",
                        "batch_size": 1,
                        "sequence_length": base_sequence_length * j,
                        "memory_estimate": past_memory_estimate,
                        "memory_required": past_memory_required,
                        "ram_required": ram_required,
                        "nvme_ssd_required": 0
                    } 
                    return result
                elif (j == (int(model_config.max_position_embeddings/base_sequence_length) - 1)):
                    result = {
                        "strategy": 1,
                        "describe": "zero2-offload",
                        "batch_size": 1,
                        "sequence_length": base_sequence_length * (j+1),
                        "memory_estimate": memory_estimate,
                        "memory_required": memory_required,
                        "ram_required": ram_required,
                        "nvme_ssd_required": 0
                    }
                    return result
                past_memory_estimate = memory_estimate
                past_memory_required = memory_required
            elif(i==2):
                #print("select zero3-offload")    
                ram_required = total_gpu_memory_zero[2]["per_CPU"] + system["used_ram"]
                if(ram_required >= system["total_ram"] ):
                    break
                args.zero_stage = 3
                args.sequence_length = base_sequence_length * (j+1)
                memory_estimate = calc_mem(args)
                memory_required = memory_estimate["activation_mem_gb"] + memory_estimate["communication_mem_gb"]           
                if(memory_required >= system["total_memory"] and j == 0):
                    break;
                elif(memory_required >= system["total_memory"] and j > 0):
                    result = {
                        "strategy": 2,
                        "describe": "zero3-offload",
                        "batch_size": 1,
                        "sequence_length": base_sequence_length * j,
                        "memory_estimate": past_memory_estimate,
                        "memory_required": past_memory_required,
                        "ram_required": ram_required,
                        "nvme_ssd_required": 0
                    }
                    return result
                elif (j == (int(model_config.max_position_embeddings/base_sequence_length) - 1)):
                    result = {
                        "strategy": 2,
                        "describe": "zero3-offload",
                        "batch_size": 1,
                        "sequence_length": base_sequence_length * (j+1),
                        "memory_estimate": memory_estimate,
                        "memory_required": memory_required,
                        "ram_required": ram_required,
                        "nvme_ssd_required": 0
                    }
                    return result
                past_memory_estimate = memory_estimate
                past_memory_required = memory_required
            elif(i==3): 
                #print("select zero3-offload NVME")

                args.zero_stage = 3  
                args.sequence_length = base_sequence_length * (j+1)
                memory_estimate = calc_mem(args)
                memory_required = memory_estimate["activation_mem_gb"] + memory_estimate["communication_mem_gb"]
                nvme_ssd_required = memory_estimate["model_mem_gb"] + memory_estimate["gradient_mem_gb"] + memory_estimate["optimizer_mem_gb"]
                ram_required = total_gpu_memory_zero[2]["per_CPU"] + system["used_ram"] - nvme_ssd_required
                if(ram_required >= system["total_ram"] or nvme_ssd_required + system["used_ssd"] >= system["total_ssd"]):
                    break
                    
                if(memory_required >= system["total_memory"] and j == 0):
                    break;
                elif(memory_required >= system["total_memory"] and j > 0):
                    result = {
                        "strategy": 3,
                        "describe": "zero3-offload NVME",
                        "batch_size": 1,
                        "sequence_length": base_sequence_length * j,
                        "memory_estimate": past_memory_estimate,
                        "memory_required": past_memory_required,
                        "ram_required": ram_required,
                        "nvme_ssd_required": nvme_ssd_required
                    }
                    return result
                elif (j == (int(model_config.max_position_embeddings/base_sequence_length) - 1)):
                    result = {
                        "strategy": 3,
                        "describe": "zero3-offload NVME",
                        "batch_size": 1,
                        "sequence_length": base_sequence_length * (j+1),
                        "memory_estimate": memory_estimate,
                        "memory_required": memory_required,
                        "ram_required": ram_required,
                        "nvme_ssd_required": nvme_ssd_required
                    }
                    return result
                past_memory_estimate = memory_estimate
                past_memory_required = memory_required
                
    result = {
        "strategy": -1,
        "describe": "Need to upgrade hardware",
        "batch_size": 0,
        "sequence_length": 0,
        "memory_estimate": memory_estimate,
        "memory_required": memory_required,
        "ram_required": ram_required,
        "nvme_ssd_required": nvme_ssd_required
    }
    return result
                
def write_file(data):
    try:
        # 尝试将数据写入 JSON 文件
        with open(FILE_PATH, 'w') as file:
            json.dump(data, file, indent=4)
        print("數據已成功寫入" + FILE_NAME + ".json")
    except IOError as e:
        # 如果写入文件时发生错误，打印错误信息
        print(f"寫入 JSON 文件失敗: {e}")

    
#input
args = config_parser().parse_args()
system = {
    "used_memory": args.used_memory,
    "used_ram": args.used_ram,
    "used_ssd": args.used_ssd,
    "total_memory": args.total_memory,
    "total_ram": args.total_ram,
    "total_ssd": args.total_ssd,
}

model_path  = args.model_path


strategy = select_strategy(args, model_path, system)
write_file(strategy)
#with open('strategy.json', 'w') as json_file:
#    json.dump(strategy, json_file, indent=4)
print("========== strategy ===========")
print(strategy)


