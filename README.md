## 目录

- [结构](#结构)
- [使用](#使用)

## 结构

- **windows**：windows bat 批量脚本。
- **linux**：linux shell 脚本。
- **experiment**：实验性的文件

## 使用

- **安装**：安装顺序，**管理员身份**执行 install_wsl.bat 先装 wsl 系统，系统安装成功再装依赖包执行 copy_intall.bat。
- **卸载**：**管理员身份**执行 uninstall_wsl.bat 直接卸载即可。
- **运行**：执行 run.bat 即可运行 打开浏览器输入 http://localhost:7861 即可访问服务。
- **校验**：linux\check\check_packages.sh 这个脚本可以抓取相关依赖包版本安装情况。
