import 'package:flutter/widgets.dart';

import 'app_local_image_stub.dart'
    if (dart.library.io) 'app_local_image_io.dart';

/// 本地图片适配：io 平台读文件，Web 使用 blob/网络地址。
abstract final class AppLocalImage {
  static ImageProvider provider(String path) => createLocalImageProvider(path);
}
