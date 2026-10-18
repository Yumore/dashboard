import 'app_file_writer_stub.dart'
    if (dart.library.io) 'app_file_writer_io.dart';

/// 本地文件写入适配。
///
/// 无文件系统的平台（Web）返回 null，由调用方提示"当前平台不支持"，
/// 业务代码不再直接依赖 `dart:io` 与 path_provider。
abstract final class AppFileWriter {
  static Future<String?> writeBytes({
    required List<int> bytes,
    required String fileName,
  }) => writePlatformFile(bytes: bytes, fileName: fileName);
}
