import 'package:dashboard/features/movie/eyepetizer/eyepetizer_json.dart';

/// `tags` on a 开眼 feed item (`common_item_model.dart:477`).
class EyepetizerTag {
  const EyepetizerTag({
    this.name = '',
    this.id = 0,
    this.tagRecType = '',
    this.headerImage = '',
    this.bgPicture = '',
    this.actionUrl = '',
    this.communityIndex = 0,
  });

  factory EyepetizerTag.fromJson(Object? json) {
    final map = EyepetizerJson.asMap(json);
    return EyepetizerTag(
      name: EyepetizerJson.asString(map['name']),
      id: EyepetizerJson.asInt(map['id']),
      tagRecType: EyepetizerJson.asString(map['tagRecType']),
      headerImage: EyepetizerJson.asString(map['headerImage']),
      bgPicture: EyepetizerJson.asString(map['bgPicture']),
      actionUrl: EyepetizerJson.asString(map['actionUrl']),
      communityIndex: EyepetizerJson.asInt(map['communityIndex']),
    );
  }

  final String name;
  final int id;
  final String tagRecType;
  final String headerImage;
  final String bgPicture;
  final String actionUrl;
  final int communityIndex;
}
