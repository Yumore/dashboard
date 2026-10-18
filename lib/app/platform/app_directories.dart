import 'package:path_provider/path_provider.dart';

import 'app_platform.dart';

/// 应用目录访问。
///
/// Web 没有文件系统，统一返回 null，调用方据此降级而不是抛异常。
abstract final class AppDirectories {
  static Future<String?> documentsPath() async {
    if (!AppPlatform.supportsFileSystem) return null;
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String?> temporaryPath() async {
    if (!AppPlatform.supportsFileSystem) return null;
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  static Future<String?> supportPath() async {
    if (!AppPlatform.supportsFileSystem) return null;
    final directory = await getApplicationSupportDirectory();
    return directory.path;
  }
}
