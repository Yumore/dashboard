/// Web 没有可写的本地文件系统：明确返回 null 让调用方降级提示。
Future<String?> writePlatformFile({
  required List<int> bytes,
  required String fileName,
}) async => null;
