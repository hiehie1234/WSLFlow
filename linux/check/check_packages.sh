#!/bin/bash

# Function to check package version using pip
check_pip_package() {
    package=$1
    installed_version=$(pip show $package | grep Version | awk '{print $2}')
    if [ -z "$installed_version" ]; then
        echo "$package is not installed"
    else
        echo "$package version: $installed_version"
    fi
}

# Function to check package version using conda
check_conda_package() {
    package=$1
    installed_versions=$(conda list | grep "^$package" | awk '{print $1 " version: " $2}')
    if [ -z "$installed_versions" ]; then
        return 1
    else
        echo "$installed_versions"
        return 0
    fi
}

# List of packages to check
packages=(
    "transformers"
    "datasets"
    "accelerate"
    "peft"
    "trl"
    "gradio"
    "pandas"
    "scipy"
    "einops"
    "sentencepiece"
    "tiktoken"
    "protobuf"
    "uvicorn"
    "pydantic"
    "fastapi"
    "sse-starlette"
    "matplotlib"
    "fire"
    "packaging"
    "pyyaml"
    "numpy"
    "torch"
    "deepspeed"
    "bitsandbytes"
    # "vllm"
    # "flash-attn"
)

# Check each package
for package in "${packages[@]}"; do
    if [[ $package == *">="* || $package == *"<="* || $package == *"=="* ]]; then
        pkg_name=$(echo $package | cut -d'=' -f1)
    else
        pkg_name=$package
    fi

    # Check with conda first
    check_conda_package $pkg_name
    conda_status=$?

    # If not found with conda, check with pip
    if [ $conda_status -ne 0 ]; then
        check_pip_package $pkg_name
    fi
done
