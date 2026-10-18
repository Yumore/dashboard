import 'app_platform_kind.dart';
import 'app_platform_traits.dart';

/// Web 平台检测（编译期确定，无需运行时判断）。
AppPlatformTraits detectAppPlatformTraits() =>
    const AppPlatformTraits(AppPlatformKind.web);
