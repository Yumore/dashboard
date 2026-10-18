import 'package:dashboard/features/movie/eyepetizer/eyepetizer_json.dart';

/// `header` on a 开眼 feed item (`common_item_model.dart:518`).
class EyepetizerHeader {
  const EyepetizerHeader({
    this.actionUrl = '',
    this.description = '',
    this.expert = false,
    this.icon = '',
    this.iconType = '',
    this.id = 0,
    this.ifPgc = false,
    this.ifShowNotificationIcon = false,
    this.title = '',
    this.uid = 0,
  });

  factory EyepetizerHeader.fromJson(Object? json) {
    final map = EyepetizerJson.asMap(json);
    return EyepetizerHeader(
      actionUrl: EyepetizerJson.asString(map['actionUrl']),
      description: EyepetizerJson.asString(map['description']),
      expert: EyepetizerJson.asBool(map['expert']),
      icon: EyepetizerJson.asString(map['icon']),
      iconType: EyepetizerJson.asString(map['iconType']),
      id: EyepetizerJson.asInt(map['id']),
      ifPgc: EyepetizerJson.asBool(map['ifPgc']),
      ifShowNotificationIcon: EyepetizerJson.asBool(
        map['ifShowNotificationIcon'],
      ),
      title: EyepetizerJson.asString(map['title']),
      uid: EyepetizerJson.asInt(map['uid']),
    );
  }

  final String actionUrl;
  final String description;
  final bool expert;
  final String icon;
  final String iconType;
  final int id;
  final bool ifPgc;
  final bool ifShowNotificationIcon;
  final String title;
  final int uid;
}
