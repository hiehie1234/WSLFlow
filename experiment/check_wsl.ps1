# 获取 WSL 发行版列表
$wslList =  wslconfig /list

# 输出调试信息
Write-Output "调试信息：WSL 发行版列表："
Write-Output $wslList

# 初始化标志变量
$ubuntuInstalled = $false
Write-Output "for："
# 检查每一行是否包含 Ubuntu
foreach ($line in $wslList) {
  Write-Output $line
  if ($line -match "Ubuntu") {
    $ubuntuInstalled = $true
    break
  }
}

# 输出结果
if ($ubuntuInstalled) {
  Write-Output "WSL2 Ubuntu 已安装。"
} else {
  Write-Output "WSL2 Ubuntu 发行版未安装。"
}