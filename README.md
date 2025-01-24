
工具功能
文件名替换：修改文件名中包含特定字符串的部分。
文件夹名替换：修改文件夹名中包含特定字符串的部分。
文件内容替换：替换文件内容中出现的目标字符串。
递归扫描：支持扫描子目录中的所有文件和文件夹。


使用：
flutter_bulk_replace <directory> <target> <replacement>

示例: 
 flutter_bulk_replace /path/to/directory "old_string" "new_string"



新增功能:

1.支持正则表达式：

使用 --regex 开启正则替换模式。

2.排除规则：

使用 --exclude=<pattern> 指定要忽略的文件或目录。

3.干运行模式：

使用 --dry-run 模式，仅显示计划替换内容，不实际修改文件。

4.日志文件：

使用 --log=<log_file> 将操作记录保存到文件。


使用示例：

flutter_bulk_replace ./my_project "old" "new" --regex --exclude=".*\.git.*" --dry-run --log=log.txt

