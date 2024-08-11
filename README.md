## 目录

- [结构](#结构)
- [详情](#详情)
- [说明](#说明)

## 结构

- **windows**：windows bat 批量脚本。
- **linux**：linux shell 脚本。
- **experiment**：实验性的文件

## 详情

- install_wsl.bat：安装 wsl 系统。
- copy_install.bat：复制 shell 脚本到 wsl 环境，并执行依赖包安装。
- uninstall_wsl.bat: 卸载相关依赖包和 wsl 系统。

## 说明

- **安装**：安装顺序，**管理员身份**执行 install_wsl.bat 先装 wsl 系统，系统安装成功再装依赖包执行 copy_intall.bat。
- **卸载**：**管理员身份**执行 uninstall_wsl.bat 直接卸载即可。
- **运行**：执行 run.bat 即可运行 打开浏览器输入 http://localhost:7861 即可访问服务。
- **校验**：linux\check\check_packages.sh 这个脚本可以抓取相关依赖包版本安装情况。
