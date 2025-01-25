
工具功能：批量替换当前目录中的所有文件名、文件夹名；

新增功能:

1.支持正则表达式：

使用 --regex 开启正则替换模式。

2.排除规则：

使用 --exclude=<pattern> 指定要忽略的文件或目录。

3.干运行模式：

使用 --dry-run 模式，仅显示计划替换内容，不实际修改文件。

4.日志文件：

使用 --log=<log_file> 将操作记录保存到文件。



使用： 安装到本地：(需要Flutter环境)
dart pub global activate -sgit https://github.com/Dxc123/flutter_bulk_replace.git

本地移除：dart pub global deactivate flutter_bulk_replace

使用示例：

在当前目录运行替换：

flutter_bulk_replace "old" "new"

flutter_bulk_replace "old" "new" --regex --exclude=".*\.git.*" --log=log.txt

指定目录替换：

flutter_bulk_replace /target_directory "old" "new"

flutter_bulk_replace /target_directory "old" "new" --regex --exclude=".*\.git.*" --log=log.txt



