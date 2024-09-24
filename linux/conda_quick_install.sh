#!/bin/bash
ISME=${SUDO_USER:-$(id -un)}
echo "user: $ISME"
HOUSE="`cat /etc/passwd |grep ^${SUDO_USER:-$(id -un)}: | cut -d: -f 6`"
HOUSE=${HOUSE:-$HOME}
echo "home: $HOUSE"

# 创建目录并下载 Miniconda 安装脚本
mkdir -p $HOUSE/miniconda3
if ! wget --tries=10 --timeout=60 --waitretry=5 --no-check-certificate https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $HOUSE/miniconda3/miniconda.sh; then
    echo "downloading miniconda.sh failed."
    exit 1
fi

# 安装 Miniconda
if ! bash $HOUSE/miniconda3/miniconda.sh -b -u -p $HOUSE/miniconda3; then
    echo "Miniconda installed failed."
    exit 1
fi

# 删除安装脚本
rm -rf $HOUSE/miniconda3/miniconda.sh

if ! sudo -u $ISME $HOUSE/miniconda3/bin/conda init bash; then
    echo "Conda init bash failed."
    exit 1
fi

if ! sudo -u $ISME $HOUSE/miniconda3/bin/conda init zsh; then
    echo "Conda init zsh failed."
    exit 1
fi
# $HOUSE/miniconda3/bin/conda init bash
# $HOUSE/miniconda3/bin/conda init zsh
exit 0