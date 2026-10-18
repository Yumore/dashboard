import 'package:dashboard/features/movie/eyepetizer/eyepetizer_author.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_consumption.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_cover.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_header.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_item.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_json.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_play_info.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_provider.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_tag.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_web_url.dart';

/// `Data` — the payload of one 开眼 feed item
/// (`module_common/lib/model/common_item_model.dart:55`).
///
/// This is the object the source's list rows and detail screen all share, so it
/// is also the only thing `EyepetizerVideoDetailPage` needs in order to play.
///
/// Two source fields are deliberately absent: `time` (a local
/// `DateTime.now().toString()` stamp used only for `Hero` tags, which the port
/// does not use) and the `shield`/`follow` author sub-objects (parsed but never
/// read).
class EyepetizerData {
  const EyepetizerData({
    this.id = 0,
    this.title = '',
    this.description = '',
    this.category = '',
    this.playUrl = '',
    this.cover,
    this.duration = 0,
    this.author,
    this.consumption,
    this.provider,
    this.webUrl,
    this.playInfo = const <EyepetizerPlayInfo>[],
    this.tags = const <EyepetizerTag>[],
    this.header,
    this.type = '',
    this.dataType = '',
    this.resourceType = '',
    this.text = '',
    this.remark = '',
    this.ad = false,
    this.collected = false,
    this.played = false,
    this.ifLimitVideo = false,
    this.date = 0,
    this.releaseTime = 0,
    this.idx = 0,
    this.searchWeight = 0,
    this.descriptionEditor = '',
    this.library = '',
    this.itemList = const <EyepetizerItem>[],
  });

  factory EyepetizerData.fromJson(Object? json) {
    final map = EyepetizerJson.asMap(json);
    return EyepetizerData(
      id: EyepetizerJson.asInt(map['id']),
      title: EyepetizerJson.asString(map['title']),
      description: EyepetizerJson.asString(map['description']),
      category: EyepetizerJson.asString(map['category']),
      playUrl: EyepetizerJson.asString(map['playUrl']),
      cover: map['cover'] == null
          ? null
          : EyepetizerCover.fromJson(map['cover']),
      duration: EyepetizerJson.asInt(map['duration']),
      author: map['author'] == null
          ? null
          : EyepetizerAuthor.fromJson(map['author']),
      consumption: map['consumption'] == null
          ? null
          : EyepetizerConsumption.fromJson(map['consumption']),
      provider: map['provider'] == null
          ? null
          : EyepetizerProvider.fromJson(map['provider']),
      webUrl: map['webUrl'] == null
          ? null
          : EyepetizerWebUrl.fromJson(map['webUrl']),
      playInfo: EyepetizerJson.asMapList(
        map['playInfo'],
      ).map(EyepetizerPlayInfo.fromJson).toList(growable: false),
      tags: EyepetizerJson.asMapList(
        map['tags'],
      ).map(EyepetizerTag.fromJson).toList(growable: false),
      header: map['header'] == null
          ? null
          : EyepetizerHeader.fromJson(map['header']),
      type: EyepetizerJson.asString(map['type']),
      dataType: EyepetizerJson.asString(map['dataType']),
      resourceType: EyepetizerJson.asString(map['resourceType']),
      text: EyepetizerJson.asString(map['text']),
      remark: EyepetizerJson.asString(map['remark']),
      ad: EyepetizerJson.asBool(map['ad']),
      collected: EyepetizerJson.asBool(map['collected']),
      played: EyepetizerJson.asBool(map['played']),
      ifLimitVideo: EyepetizerJson.asBool(map['ifLimitVideo']),
      date: EyepetizerJson.asInt(map['date']),
      releaseTime: EyepetizerJson.asInt(map['releaseTime']),
      idx: EyepetizerJson.asInt(map['idx']),
      searchWeight: EyepetizerJson.asInt(map['searchWeight']),
      descriptionEditor: EyepetizerJson.asString(map['descriptionEditor']),
      library: EyepetizerJson.asString(map['library']),
      itemList: EyepetizerJson.asMapList(
        map['itemList'],
      ).map(EyepetizerItem.fromJson).toList(growable: false),
    );
  }

  final int id;
  final String title;
  final String description;
  final String category;

  /// The stream the source's `VideoWidget` played first.
  final String playUrl;

  /// Null for text headers and some ad rows; the search screen filters on it.
  final EyepetizerCover? cover;

  /// Milliseconds.
  final int duration;

  final EyepetizerAuthor? author;
  final EyepetizerConsumption? consumption;
  final EyepetizerProvider? provider;
  final EyepetizerWebUrl? webUrl;

  /// Alternate quality streams — the port turns these into player sources.
  final List<EyepetizerPlayInfo> playInfo;

  final List<EyepetizerTag> tags;
  final EyepetizerHeader? header;
  final String type;
  final String dataType;
  final String resourceType;

  /// `textHeader` rows carry their section title here.
  final String text;

  final String remark;
  final bool ad;
  final bool collected;
  final bool played;
  final bool ifLimitVideo;
  final int date;
  final int releaseTime;
  final int idx;
  final int searchWeight;
  final String descriptionEditor;

  /// JSON key `library`.
  final String library;

  /// Nested items (horizontal scroll cards).
  final List<EyepetizerItem> itemList;

  /// The author line the list rows print: `author.name`, else `description`.
  String get authorLine {
    final name = author?.name ?? '';
    return name.isNotEmpty ? name : description;
  }

  /// Small round icon the list rows print: `author.icon`, else `provider.icon`.
  String get authorIcon {
    final icon = author?.icon ?? '';
    return icon.isNotEmpty ? icon : (provider?.icon ?? '');
  }

  /// `yyyy/MM/dd` of [date] (`20181025` in the wild), or empty when absent.
  String get dateLabel {
    final raw = date.toString();
    if (raw.length != 8) return '';
    return '${raw.substring(0, 4)}/${raw.substring(4, 6)}/${raw.substring(6)}';
  }
}
