import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_content.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_cover.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_header.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_item_banner.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_item_detail.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';

/// `lib/model/item_data.dart` → `ItemData`.
///
/// Faithful quirks worth naming, because the local cache round trip depends on
/// them:
/// * `duration` defaults to `0` when the payload omits it;
/// * `itemList` defaults to an empty list;
/// * **`toJson` omits `duration`** (the source map simply never listed the
///   key), so a cached item comes back with `duration == 0`. The port keeps
///   that so a cache read and a cache write agree with the source's bytes.
class EyepetizerFlutterItemData {
  EyepetizerFlutterItemData({
    this.dataType,
    this.id,
    this.text,
    this.title,
    this.description,
    this.image,
    this.icon,
    this.actionUrl,
    this.category,
    this.duration = 0,
    this.cover,
    this.header,
    this.content,
    this.detail,
    this.itemList = const <EyepetizerFlutterItemBanner>[],
  });

  factory EyepetizerFlutterItemData.fromJson(Map<String, dynamic> json) =>
      EyepetizerFlutterItemData(
        dataType: EyepetizerFlutterJson.asNullableString(json['dataType']),
        id: EyepetizerFlutterJson.asNullableInt(json['id']),
        text: EyepetizerFlutterJson.asNullableString(json['text']),
        title: EyepetizerFlutterJson.asNullableString(json['title']),
        description: EyepetizerFlutterJson.asNullableString(
          json['description'],
        ),
        image: EyepetizerFlutterJson.asNullableString(json['image']),
        icon: EyepetizerFlutterJson.asNullableString(json['icon']),
        actionUrl: EyepetizerFlutterJson.asNullableString(json['actionUrl']),
        category: EyepetizerFlutterJson.asNullableString(json['category']),
        duration: json['duration'] == null
            ? 0
            : EyepetizerFlutterJson.asInt(json['duration']),
        cover: json['cover'] is Map
            ? EyepetizerFlutterCover.fromJson(
                EyepetizerFlutterJson.asMap(json['cover']),
              )
            : null,
        header: json['header'] is Map
            ? EyepetizerFlutterHeader.fromJson(
                EyepetizerFlutterJson.asMap(json['header']),
              )
            : null,
        content: json['content'] is Map
            ? EyepetizerFlutterContent.fromJson(
                EyepetizerFlutterJson.asMap(json['content']),
              )
            : null,
        detail: json['detail'] is Map
            ? EyepetizerFlutterItemDetail.fromJson(
                EyepetizerFlutterJson.asMap(json['detail']),
              )
            : null,
        itemList: EyepetizerFlutterJson.asMapList(
          json['itemList'],
        ).map(EyepetizerFlutterItemBanner.fromJson).toList(growable: false),
      );

  final String? dataType;
  final int? id;
  final String? text;
  final String? title;
  final String? description;
  final String? image;
  final String? icon;
  final String? actionUrl;
  final String? category;
  final int duration;
  final EyepetizerFlutterCover? cover;
  final EyepetizerFlutterHeader? header;
  final EyepetizerFlutterContent? content;
  final EyepetizerFlutterItemDetail? detail;

  /// Mutable on purpose: `PersonRepository.getPersonHomePageData` assigned the
  /// rebuilt banner list onto the first item of the parsed page
  /// (`baseListData.itemList[0].data.itemList = banners`), and the port keeps
  /// that exact write instead of copying the tree.
  List<EyepetizerFlutterItemBanner> itemList;

  /// Key-for-key with the source's map, including the missing `duration`.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'dataType': dataType,
    'id': id,
    'text': text,
    'title': title,
    'description': description,
    'image': image,
    'icon': icon,
    'category': category,
    'actionUrl': actionUrl,
    'cover': cover?.toJson(),
    'header': header?.toJson(),
    'content': content?.toJson(),
    'detail': detail?.toJson(),
    'itemList': itemList.map((banner) => banner.toJson()).toList(),
  };
}
