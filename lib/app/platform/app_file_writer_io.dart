import 'dart:io';

import 'app_directories.dart';

/// io 平台：写入应用文档目录，路径不可用时回退到临时目录。
Future<String?> writePlatformFile({
  required List<int> bytes,
  required String fileName,
}) async {
  final root = await AppDirectories.documentsPath() ??
      await AppDirectories.temporaryPath();
  if (root == null) return null;
  final file = File('$root${Platform.pathSeparator}$fileName');
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes, mode: FileMode.write);
  return file.path;
}
