#!/bin/bash
HOUSE="`cat /etc/passwd |grep ^${SUDO_USER:-$(id -un)}: | cut -d: -f 6`"
HOUSE=${HOUSE:-$HOME}
# 卸载 CUDA 和 CUDNN
# https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#removing-cuda-toolkit-and-driver
# 检查并卸载 CUDA
if dpkg-query -W cuda-toolkit-12-1 &> /dev/null; then
    echo "Uninstalling CUDA..."
    sudo apt-get --purge remove "*cuda*" "*cublas*" "*cufft*" "*cufile*" "*curand*" \
"*cusolver*" "*cusparse*" "*gds-tools*" "*npp*" "*nvjpeg*" "nsight*" "*nvvm*" -y
    sudo apt-get autoremove --purge -y
    sudo apt-get autoclean
else
    echo "CUDA not installed."
fi

# 删除 CUDA 环境变量
# 删除 CUDA 环境变量
sed -i '/\/usr\/local\/cuda\/bin/d' $HOUSE/.bashrc
sed -i '/\/usr\/local\/cuda\/lib64/d' $HOUSE/.bashrc

sed -i '/\/usr\/local\/cuda\/bin/d' $HOUSE/.zshrc
sed -i '/\/usr\/local\/cuda\/lib64/d' $HOUSE/.zshrc


# 重新加载 .bashrc 和 .zshrc 以使更改生效
source $HOUSE/.bashrc
source $HOUSE/.zshrc