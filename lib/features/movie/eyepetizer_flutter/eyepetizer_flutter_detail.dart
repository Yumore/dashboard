import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_author.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_consumption.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_cover.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_owner.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_tag.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_video_poster.dart';

/// `lib/model/detail.dart` → `Detail`.
///
/// Deliberate deviation: the source left `tags` and `urls` **null** when the
/// payload omitted them (while `ContentData` defaulted its tags to an empty
/// list). The picture-detail gallery indexes `urls.length` unconditionally, so
/// the port makes both non-null with empty-list defaults. That is the only
/// behaviour change in this model, and it removes a guaranteed null crash.
class EyepetizerFlutterDetail {
  const EyepetizerFlutterDetail({
    this.id,
    this.title,
    this.description,
    this.category,
    this.playUrl,
    this.duration,
    this.tags = const <EyepetizerFlutterTag>[],
    this.consumption,
    this.owner,
    this.author,
    this.cover,
    this.urls = const <String>[],
    this.videoPosterBean,
  });

  factory EyepetizerFlutterDetail.fromJson(Map<String, dynamic> json) =>
      EyepetizerFlutterDetail(
        id: EyepetizerFlutterJson.asNullableInt(json['id']),
        title: EyepetizerFlutterJson.asNullableString(json['title']),
        description: EyepetizerFlutterJson.asNullableString(
          json['description'],
        ),
        category: EyepetizerFlutterJson.asNullableString(json['category']),
        playUrl: EyepetizerFlutterJson.asNullableString(json['playUrl']),
        duration: EyepetizerFlutterJson.asNullableInt(json['duration']),
        tags: EyepetizerFlutterJson.asMapList(
          json['tags'],
        ).map(EyepetizerFlutterTag.fromJson).toList(growable: false),
        consumption: json['consumption'] is Map
            ? EyepetizerFlutterConsumption.fromJson(
                EyepetizerFlutterJson.asMap(json['consumption']),
              )
            : null,
        owner: json['owner'] is Map
            ? EyepetizerFlutterOwner.fromJson(
                EyepetizerFlutterJson.asMap(json['owner']),
              )
            : null,
        author: json['author'] is Map
            ? EyepetizerFlutterAuthor.fromJson(
                EyepetizerFlutterJson.asMap(json['author']),
              )
            : null,
        cover: json['cover'] is Map
            ? EyepetizerFlutterCover.fromJson(
                EyepetizerFlutterJson.asMap(json['cover']),
              )
            : null,
        urls: EyepetizerFlutterJson.asStringList(json['urls']),
        videoPosterBean: json['videoPosterBean'] is Map
            ? EyepetizerFlutterVideoPoster.fromJson(
                EyepetizerFlutterJson.asMap(json['videoPosterBean']),
              )
            : null,
      );

  final int? id;
  final String? title;
  final String? description;
  final String? category;
  final String? playUrl;
  final int? duration;
  final List<EyepetizerFlutterTag> tags;
  final EyepetizerFlutterConsumption? consumption;
  final EyepetizerFlutterOwner? owner;
  final EyepetizerFlutterAuthor? author;
  final EyepetizerFlutterCover? cover;
  final List<String> urls;
  final EyepetizerFlutterVideoPoster? videoPosterBean;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'playUrl': playUrl,
    'duration': duration,
    'tags': tags.map((tag) => tag.toJson()).toList(),
    'consumption': consumption?.toJson(),
    'owner': owner?.toJson(),
    'author': author?.toJson(),
    'cover': cover?.toJson(),
    'urls': urls,
    'videoPosterBean': videoPosterBean?.toJson(),
  };
}
