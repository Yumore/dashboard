import 'package:dashboard/features/movie/yyets/yyets_json.dart';

/// 电影的可播条目，对应源工程 `MovieResWidget` 的 `item`。
///
/// ```dart
/// Text(item['number']);
/// Text(item['name']);
/// item['play'] == 1 ? Text("边下边播") : Container();
/// ```
class YyetsResourceItem {
  const YyetsResourceItem({
    this.number = '',
    this.name = '',
    this.play = false,
  });

  /// `number` —— 例如 `HDTV-MP4` 版本号。
  final String number;

  /// `name` —— 条目名。
  final String name;

  /// `play` —— `1` 表示源工程支持边下边播（仅安卓）。
  final bool play;

  /// 源工程资源页取参数时对电影用 `itemid`。
  Map<String, String> resourceArguments({
    required String id,
    required String itemId,
    required String channel,
  }) => <String, String>{
    'id': id,
    if (itemId.isNotEmpty) 'itemid': itemId,
    'channel': channel,
  };

  factory YyetsResourceItem.fromJson(Map<String, dynamic> json) =>
      YyetsResourceItem(
        number: YyetsJson.asString(json['number']),
        name: YyetsJson.asString(json['name']),
        play: YyetsJson.asInt(json['play']) == 1,
      );
}
