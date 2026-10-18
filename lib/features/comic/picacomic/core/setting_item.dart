import 'package:dashboard/features/comic/picacomic/core/setting_type.dart';

/// Ports PicaComic's `SettingItem`.
class SettingItem {
  final String name;
  final String iconName;
  final SettingType type;
  final List<String>? options;

  const SettingItem(this.name, this.iconName, this.type, this.options);
}
