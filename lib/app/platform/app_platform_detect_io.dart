import 'dart:io';

import 'app_platform_kind.dart';
import 'app_platform_traits.dart';

/// io 平台（移动端/桌面端/鸿蒙）的平台检测。
AppPlatformTraits detectAppPlatformTraits() =>
    AppPlatformTraits(_kindFor(Platform.operatingSystem));

AppPlatformKind _kindFor(String operatingSystem) => switch (operatingSystem) {
  'android' => AppPlatformKind.android,
  'ios' => AppPlatformKind.ios,
  'macos' => AppPlatformKind.macos,
  'windows' => AppPlatformKind.windows,
  'linux' => AppPlatformKind.linux,
  'ohos' => AppPlatformKind.ohos,
  _ => AppPlatformKind.unknown,
};
