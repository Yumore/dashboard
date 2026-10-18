import 'package:dashboard/features/movie/eyepetizer/eyepetizer_json.dart';

/// `provider` on a 开眼 feed item (`common_item_model.dart:593`).
///
/// The source's list rows fell back to `provider.icon` whenever a video had no
/// author (`rank_widget_item.dart:99-103`).
class EyepetizerProvider {
  const EyepetizerProvider({this.icon = '', this.name = '', this.alias = ''});

  factory EyepetizerProvider.fromJson(Object? json) {
    final map = EyepetizerJson.asMap(json);
    return EyepetizerProvider(
      icon: EyepetizerJson.asString(map['icon']),
      name: EyepetizerJson.asString(map['name']),
      alias: EyepetizerJson.asString(map['alias']),
    );
  }

  final String icon;
  final String name;
  final String alias;
}
