MD5SUM_FILE=md5sum.txt
CUDA_DEB=cuda-repo-wsl-ubuntu-12-1-local_12.1.1-1_amd64.deb
# 从 MD5 校验值文件中获取 CUDA_DEB 对应的 MD5 校验值
EXPECTED_MD5=$(grep "$CUDA_DEB" $MD5SUM_FILE | awk '{ print $1 }')
echo $EXPECTED_MD5
# 对 CUDA 安装包做 md5sum 得到当前下载档的 MD5 值
ACTUAL_MD5=$(md5sum $CUDA_DEB | awk '{ print $1 }')
# 比较 MD5 校验值，如果不匹配，则退出并警告用户
if [ "$EXPECTED_MD5" != "$ACTUAL_MD5" ]; then
    echo "MD5 校验值不匹配，下载的文件可能已损坏。"
    exit 1
fi
echo "MD5 校验值不匹配，下载的 $CUDA_DEB 文件可能已损坏。"