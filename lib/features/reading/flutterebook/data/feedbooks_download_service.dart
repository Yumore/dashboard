import 'dart:io';

import 'package:dashboard/features/reading/flutterebook/data/feedbooks_download_record.dart';
import 'package:dashboard/features/reading/flutterebook/feedbooks_api.dart';
import 'package:dashboard/features/reading/flutterebook/feedbooks_format.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

/// 源工程 `DownloadAlert` 里真正的下载逻辑（去掉弹窗 UI）。
///
/// 保留的行为：
///  * 文件名把空格换成 `_`、把反斜杠转义的单引号还原成单引号
///    （源 `fileName` getter：`name.replaceAll(' ', '_').replaceAll(r"\'", "'")`）；
///  * 落盘目录是 `文档目录/OpenLeaf/`，扩展名 `.epub`；
///  * 目标文件已存在时先删掉再重建；
///  * 用 `Dio.download` 下载并回调进度，结束后按
///    `formatBytes(total, 1)` 记录体积。
///
/// 与源工程的两处差异（都是拿掉宿主没有的能力，见交付说明）：
///  * 源工程 Android 分支写的是外部存储根目录，依赖 `permission_handler`
///    申请 `Permission.storage/accessMediaLocation/manageExternalStorage`；
///    宿主 pubspec 没有该包，这里统一写应用文档目录，因此也不需要权限；
///  * 源工程平台判断里 macOS/Web 直接下载，其它平台先申请权限，这里统一
///    走同一路径。
class FeedbooksDownloadService {
  FeedbooksDownloadService({
    required Dio dio,
    Future<Directory> Function()? directoryProvider,
  }) : _dio = dio,
       _directoryProvider =
           directoryProvider ?? getApplicationDocumentsDirectory;

  /// 源工程 `appName`（`strings.dart`），决定下载子目录名。
  static const String appName = FeedbooksApi.appName;

  final Dio _dio;
  final Future<Directory> Function() _directoryProvider;

  /// 源 `DownloadAlert.fileName`。
  String fileNameFor(String name) =>
      name.replaceAll(' ', '_').replaceAll(r"\'", "'");

  /// 源 `createFile` 的落盘路径：`<documents>/OpenLeaf/<fileName>.epub`。
  Future<String> filePathFor(String name) async {
    final Directory directory = await _directoryProvider();
    final String root = directory.path.endsWith(Platform.pathSeparator)
        ? directory.path.substring(0, directory.path.length - 1)
        : directory.path;
    return '$root${Platform.pathSeparator}$appName'
        '${Platform.pathSeparator}${fileNameFor(name)}.epub';
  }

  /// 下载并返回一条与源工程 map 完全对应的记录。
  Future<FeedbooksDownloadRecord> download({
    required String url,
    required String id,
    required String name,
    required String image,
    void Function(int receivedBytes, int totalBytes)? onReceiveProgress,
  }) async {
    final String filePath = await filePathFor(name);
    final File file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
    await file.create(recursive: true);

    int totalBytes = 0;
    await _dio.download(
      url,
      filePath,
      onReceiveProgress: (int received, int total) {
        totalBytes = total;
        onReceiveProgress?.call(received, total);
      },
    );

    return FeedbooksDownloadRecord(
      id: id,
      path: filePath,
      image: image,
      // 源工程只在 `receivedBytes == totalBytes` 时算体积；拿不到总长度
      // （total == -1）时 `formatBytes` 会对负数取对数，这里记空串。
      size: totalBytes > 0
          ? FeedbooksFormat.formatBytes(totalBytes, 1)
          : '',
      name: name,
    );
  }
}
