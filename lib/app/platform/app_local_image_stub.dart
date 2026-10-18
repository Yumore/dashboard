import 'package:flutter/widgets.dart';

/// 兜底：把路径当成网络地址（Web 的 blob URL 可直接加载）。
ImageProvider createLocalImageProvider(String path) => NetworkImage(path);
