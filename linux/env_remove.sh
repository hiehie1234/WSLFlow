#!/bin/bash
ISME=${SUDO_USER:-$(id -un)}
HOUSE="`cat /etc/passwd |grep ^${SUDO_USER:-$(id -un)}: | cut -d: -f 6`"
HOUSE=${HOUSE:-$HOME}

# 以普通用户身份检查是否安装了 Conda
sudo -u $ISME bash -c "
    if ! command -v $HOUSE/miniconda3/bin/conda &> /dev/null
    then
        echo "Conda is not installed."
        exit 1
    fi
"
CHECK_CONDA_STATUS=$?

if [ $CHECK_CONDA_STATUS -ne 0 ]; then
    echo "Conda uninstalled."
    exit 1
fi

# 指定要删除的 conda 环境名称
ENV_NAME=FlexTuner

# 以普通用户身份卸载选定的环境
sudo -u $ISME bash -c "
    source $HOUSE/.bashrc
    eval \"\$($HOUSE/miniconda3/bin/conda shell.bash hook)\"
    conda env remove -n \"$ENV_NAME\"
"
REMOVE_ENV_STATUS=$?

# 检查卸载是否成功
if [ $REMOVE_ENV_STATUS -eq 0 ]; then
    echo "Execution completed."
else
    echo "Execution failed."
    exit 1
fi