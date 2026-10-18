import 'package:dashboard/features/movie/eyepetizer/eyepetizer_json.dart';

/// `author` on a 开眼 feed item (`common_item_model.dart:335`).
///
/// The source also parsed `shield` and `follow` sub-objects but never read
/// either; they are intentionally not ported.
class EyepetizerAuthor {
  const EyepetizerAuthor({
    this.icon = '',
    this.name = '',
    this.description = '',
    this.link = '',
    this.id = 0,
    this.videoNum = 0,
    this.expert = false,
    this.ifPgc = false,
    this.latestReleaseTime = 0,
    this.recSort = 0,
    this.approvedNotReadyVideoCount = 0,
  });

  factory EyepetizerAuthor.fromJson(Object? json) {
    final map = EyepetizerJson.asMap(json);
    return EyepetizerAuthor(
      icon: EyepetizerJson.asString(map['icon']),
      name: EyepetizerJson.asString(map['name']),
      description: EyepetizerJson.asString(map['description']),
      link: EyepetizerJson.asString(map['link']),
      id: EyepetizerJson.asInt(map['id']),
      videoNum: EyepetizerJson.asInt(map['videoNum']),
      expert: EyepetizerJson.asBool(map['expert']),
      ifPgc: EyepetizerJson.asBool(map['ifPgc']),
      latestReleaseTime: EyepetizerJson.asInt(map['latestReleaseTime']),
      recSort: EyepetizerJson.asInt(map['recSort']),
      approvedNotReadyVideoCount: EyepetizerJson.asInt(
        map['approvedNotReadyVideoCount'],
      ),
    );
  }

  final String icon;
  final String name;
  final String description;
  final String link;
  final int id;
  final int videoNum;
  final bool expert;
  final bool ifPgc;
  final int latestReleaseTime;
  final int recSort;
  final int approvedNotReadyVideoCount;
}
