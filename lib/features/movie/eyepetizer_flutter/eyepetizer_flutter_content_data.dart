import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_author.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_consumption.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_cover.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_owner.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_tag.dart';

/// `lib/model/content_data.dart` → `ContentData`.
///
/// This is what a community `ugc_picture` card hands to the picture-detail
/// page: `resourceType` decides the detail request's `resourceType` parameter
/// and `tags` defaults to an empty list exactly as the source did.
class EyepetizerFlutterContentData {
  const EyepetizerFlutterContentData({
    this.id,
    this.title,
    this.description,
    this.resourceType,
    this.category,
    this.author,
    this.cover,
    this.playUrl,
    this.duration,
    this.date,
    this.consumption,
    this.tags = const <EyepetizerFlutterTag>[],
    this.owner,
  });

  factory EyepetizerFlutterContentData.fromJson(
    Map<String, dynamic> json,
  ) => EyepetizerFlutterContentData(
    id: EyepetizerFlutterJson.asNullableInt(json['id']),
    title: EyepetizerFlutterJson.asNullableString(json['title']),
    description: EyepetizerFlutterJson.asNullableString(json['description']),
    resourceType: EyepetizerFlutterJson.asNullableString(json['resourceType']),
    category: EyepetizerFlutterJson.asNullableString(json['category']),
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
    playUrl: EyepetizerFlutterJson.asNullableString(json['playUrl']),
    duration: EyepetizerFlutterJson.asNullableInt(json['duration']),
    date: EyepetizerFlutterJson.asNullableInt(json['date']),
    consumption: json['consumption'] is Map
        ? EyepetizerFlutterConsumption.fromJson(
            EyepetizerFlutterJson.asMap(json['consumption']),
          )
        : null,
    tags: EyepetizerFlutterJson.asMapList(
      json['tags'],
    ).map(EyepetizerFlutterTag.fromJson).toList(growable: false),
    owner: json['owner'] is Map
        ? EyepetizerFlutterOwner.fromJson(
            EyepetizerFlutterJson.asMap(json['owner']),
          )
        : null,
  );

  final int? id;
  final String? title;
  final String? description;
  final String? resourceType;
  final String? category;
  final EyepetizerFlutterAuthor? author;
  final EyepetizerFlutterCover? cover;
  final String? playUrl;
  final int? duration;
  final int? date;
  final EyepetizerFlutterConsumption? consumption;
  final List<EyepetizerFlutterTag> tags;
  final EyepetizerFlutterOwner? owner;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'description': description,
    'resourceType': resourceType,
    'category': category,
    'author': author?.toJson(),
    'cover': cover?.toJson(),
    'playUrl': playUrl,
    'duration': duration,
    'date': date,
    'consumption': consumption?.toJson(),
    'tags': tags.map((tag) => tag.toJson()).toList(),
    'owner': owner?.toJson(),
  };
}
