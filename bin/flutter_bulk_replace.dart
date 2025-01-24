import 'dart:async';
import 'dart:io';

void main(List<String> args) async {
  if (args.length < 3) {
    logError('Usage: dart run <script.dart> <directory> <target> <replacement> [--regex] [--exclude=<pattern>] [--dry-run] [--log=<log_file>]');
    exit(1);
  }

  final directoryPath = args[0];
  final target = args[1];
  final replacement = args[2];

  final isRegex = args.contains('--regex');
  final isDryRun = args.contains('--dry-run');
  final logFilePath = args.firstWhere((arg) => arg.startsWith('--log='), orElse: () => "").substring(6);
  final excludePattern = args.firstWhere((arg) => arg.startsWith('--exclude='), orElse: () => "").substring(10);

  final rootDirectory = Directory(directoryPath);
  if (!rootDirectory.existsSync()) {
    logError('Error: Directory "$directoryPath" does not exist.');
    exit(1);
  }

  logInfo('Starting replacement in directory: $directoryPath');
  logInfo('Replacing "${isRegex ? "regex pattern" : "string"}" "$target" with "$replacement"');

  // 初始化日志文件
  final logFile = logFilePath.isNotEmpty ? File(logFilePath) : null;
  logFile?.writeAsStringSync('Replacement Log\n\n', mode: FileMode.write);

  final totalEntities = await _countEntities(rootDirectory, excludePattern);
  logInfo('Found $totalEntities items to process.');

  var processedCount = 0;
  await _replaceInDirectory(
    rootDirectory,
    target,
    replacement,
    isRegex,
    excludePattern,
    isDryRun,
    logFile,
    (processed) {
      processedCount = processed;
      _showProgress(processedCount, totalEntities);
    },
  );

  logSuccess('\nReplacement completed! Processed $processedCount items.');
}

/// 递归处理目录中的文件名、文件夹名和文件内容
Future<void> _replaceInDirectory(
  Directory directory,
  String target,
  String replacement,
  bool isRegex,
  String? excludePattern,
  bool isDryRun,
  File? logFile,
  void Function(int) onProgress,
) async {
  var processedCount = 0;

  await for (var entity in directory.list(recursive: true, followLinks: false)) {
    if (_shouldExclude(entity.path, excludePattern)) {
      continue;
    }

    if (entity is File) {
      await _processFile(entity, target, replacement, isRegex, isDryRun, logFile);
    } else if (entity is Directory) {
      await _processDirectory(entity, target, replacement, isRegex, isDryRun, logFile);
    }

    processedCount++;
    onProgress(processedCount); // 更新进度
  }
}

/// 检查是否需要排除路径
bool _shouldExclude(String path, String? excludePattern) {
  return excludePattern != null && RegExp(excludePattern).hasMatch(path);
}

/// 处理文件内容和文件名
Future<void> _processFile(File file, String target, String replacement, bool isRegex, bool isDryRun, File? logFile) async {
  final fileName = file.uri.pathSegments.last;

  if (isRegex ? RegExp(target).hasMatch(fileName) : fileName.contains(target)) {
    final newFileName = isRegex ? fileName.replaceAll(RegExp(target), replacement) : fileName.replaceAll(target, replacement);
    final newPath = file.parent.path + Platform.pathSeparator + newFileName;

    if (!isDryRun) {
      await file.rename(newPath);
    }
    logSuccess('Renamed file: $fileName -> $newFileName');
    logFile?.writeAsStringSync('Renamed file: $fileName -> $newFileName\n', mode: FileMode.append);
  }

  final content = await file.readAsString();
  if (isRegex ? RegExp(target).hasMatch(content) : content.contains(target)) {
    final updatedContent = isRegex ? content.replaceAll(RegExp(target), replacement) : content.replaceAll(target, replacement);

    if (!isDryRun) {
      await file.writeAsString(updatedContent);
    }
    logSuccess('Updated file content: ${file.path}');
    logFile?.writeAsStringSync('Updated file content: ${file.path}\n', mode: FileMode.append);
  }
}

/// 处理文件夹名称
Future<void> _processDirectory(Directory directory, String target, String replacement, bool isRegex, bool isDryRun, File? logFile) async {
  final dirName = directory.uri.pathSegments.last;

  if (isRegex ? RegExp(target).hasMatch(dirName) : dirName.contains(target)) {
    final newDirName = isRegex ? dirName.replaceAll(RegExp(target), replacement) : dirName.replaceAll(target, replacement);
    final newPath = directory.parent.path + Platform.pathSeparator + newDirName;

    if (!isDryRun) {
      await directory.rename(newPath);
    }
    logSuccess('Renamed directory: $dirName -> $newDirName');
    logFile?.writeAsStringSync('Renamed directory: $dirName -> $newDirName\n', mode: FileMode.append);
  }
}

/// 统计目录中所有文件和文件夹的数量
Future<int> _countEntities(Directory directory, String? excludePattern) async {
  var count = 0;
  await for (var entity in directory.list(recursive: true, followLinks: false)) {
    if (!_shouldExclude(entity.path, excludePattern)) {
      count++;
    }
  }
  return count;
}

/// 显示进度条
void _showProgress(int current, int total) {
  final percentage = (current / total * 100).toStringAsFixed(1);
  stdout.write('\rProgress: $current/$total ($percentage%)');
}

/// 日志输出工具（带颜色）
void logInfo(String message) {
  print('\x1B[34m[INFO] $message\x1B[0m'); // 蓝色
}

void logSuccess(String message) {
  print('\x1B[32m[SUCCESS] $message\x1B[0m'); // 绿色
}

void logWarning(String message) {
  print('\x1B[33m[WARNING] $message\x1B[0m'); // 黄色
}

void logError(String message) {
  print('\x1B[31m[ERROR] $message\x1B[0m'); // 红色
}
