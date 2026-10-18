import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_follow.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';

/// `lib/model/person_mainpage.dart` → `UserInfo`.
///
/// The three fields the source explicitly null-guarded (`icon`,
/// `description`, `cover`) stay non-null `String`s with `''` defaults, because
/// the person header and the edit-data form print them unconditionally. Every
/// other field is nullable here, matching what a pre-null-safety read could
/// actually produce.
class EyepetizerFlutterUserInfo {
  const EyepetizerFlutterUserInfo({
    this.dataType,
    this.id,
    this.icon = '',
    this.name,
    this.brief,
    this.gender,
    this.description = '',
    this.actionUrl,
    this.followCount,
    this.follow,
    this.self,
    this.cover = '',
    this.videoCount,
    this.shareCount,
    this.collectCount,
    this.myFollowCount,
    this.videoCountActionUrl,
    this.myFollowCountActionUrl,
    this.followCountActionUrl,
    this.privateMessageActionUrl,
    this.medalsNum,
    this.medalsActionUrl,
    this.tagNameExport,
    this.worksRecCount,
    this.worksSelectedCount,
    this.birthday,
    this.city,
    this.university,
    this.job,
    this.expert,
  });

  factory EyepetizerFlutterUserInfo.fromJson(
    Map<String, dynamic> json,
  ) => EyepetizerFlutterUserInfo(
    dataType: EyepetizerFlutterJson.asNullableString(json['dataType']),
    id: EyepetizerFlutterJson.asNullableInt(json['id']),
    icon: json['icon'] == null
        ? ''
        : EyepetizerFlutterJson.asString(json['icon']),
    name: EyepetizerFlutterJson.asNullableString(json['name']),
    brief: EyepetizerFlutterJson.asNullableString(json['brief']),
    gender: EyepetizerFlutterJson.asNullableString(json['gender']),
    description: json['description'] == null
        ? ''
        : EyepetizerFlutterJson.asString(json['description']),
    actionUrl: EyepetizerFlutterJson.asNullableString(json['actionUrl']),
    followCount: EyepetizerFlutterJson.asNullableInt(json['followCount']),
    follow: json['follow'] is Map
        ? EyepetizerFlutterFollow.fromJson(
            EyepetizerFlutterJson.asMap(json['follow']),
          )
        : null,
    self: json['self'] is bool ? json['self'] as bool : null,
    cover: json['cover'] == null
        ? ''
        : EyepetizerFlutterJson.asString(json['cover']),
    videoCount: EyepetizerFlutterJson.asNullableInt(json['videoCount']),
    shareCount: EyepetizerFlutterJson.asNullableInt(json['shareCount']),
    collectCount: EyepetizerFlutterJson.asNullableInt(json['collectCount']),
    myFollowCount: EyepetizerFlutterJson.asNullableInt(json['myFollowCount']),
    videoCountActionUrl: EyepetizerFlutterJson.asNullableString(
      json['videoCountActionUrl'],
    ),
    myFollowCountActionUrl: EyepetizerFlutterJson.asNullableString(
      json['myFollowCountActionUrl'],
    ),
    followCountActionUrl: EyepetizerFlutterJson.asNullableString(
      json['followCountActionUrl'],
    ),
    privateMessageActionUrl: EyepetizerFlutterJson.asNullableString(
      json['privateMessageActionUrl'],
    ),
    medalsNum: EyepetizerFlutterJson.asNullableInt(json['medalsNum']),
    medalsActionUrl: EyepetizerFlutterJson.asNullableString(
      json['medalsActionUrl'],
    ),
    tagNameExport: EyepetizerFlutterJson.asNullableString(
      json['tagNameExport'],
    ),
    worksRecCount: EyepetizerFlutterJson.asNullableInt(json['worksRecCount']),
    worksSelectedCount: EyepetizerFlutterJson.asNullableInt(
      json['worksSelectedCount'],
    ),
    birthday: EyepetizerFlutterJson.asNullableInt(json['birthday']),
    city: EyepetizerFlutterJson.asNullableString(json['city']),
    university: EyepetizerFlutterJson.asNullableString(json['university']),
    job: EyepetizerFlutterJson.asNullableString(json['job']),
    expert: json['expert'] is bool ? json['expert'] as bool : null,
  );

  final String? dataType;
  final int? id;
  final String icon;
  final String? name;
  final String? brief;
  final String? gender;
  final String description;
  final String? actionUrl;
  final int? followCount;
  final EyepetizerFlutterFollow? follow;
  final bool? self;
  final String cover;
  final int? videoCount;
  final int? shareCount;
  final int? collectCount;
  final int? myFollowCount;
  final String? videoCountActionUrl;
  final String? myFollowCountActionUrl;
  final String? followCountActionUrl;
  final String? privateMessageActionUrl;
  final int? medalsNum;
  final String? medalsActionUrl;
  final String? tagNameExport;
  final int? worksRecCount;
  final int? worksSelectedCount;
  final int? birthday;
  final String? city;
  final String? university;
  final String? job;
  final bool? expert;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'dataType': dataType,
    'id': id,
    'icon': icon,
    'name': name,
    'brief': brief,
    'gender': gender,
    'description': description,
    'actionUrl': actionUrl,
    'followCount': followCount,
    'follow': follow?.toJson(),
    'self': self,
    'cover': cover,
    'videoCount': videoCount,
    'shareCount': shareCount,
    'collectCount': collectCount,
    'myFollowCount': myFollowCount,
    'videoCountActionUrl': videoCountActionUrl,
    'myFollowCountActionUrl': myFollowCountActionUrl,
    'followCountActionUrl': followCountActionUrl,
    'privateMessageActionUrl': privateMessageActionUrl,
    'medalsNum': medalsNum,
    'medalsActionUrl': medalsActionUrl,
    'tagNameExport': tagNameExport,
    'worksRecCount': worksRecCount,
    'worksSelectedCount': worksSelectedCount,
    'birthday': birthday,
    'city': city,
    'university': university,
    'job': job,
    'expert': expert,
  };
}
