import 'dart:io';

import 'package:flutter/widgets.dart';

/// io 平台：本地路径使用 FileImage。
ImageProvider createLocalImageProvider(String path) => FileImage(File(path));
