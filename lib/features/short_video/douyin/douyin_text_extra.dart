import 'package:dashboard/features/short_video/douyin/douyin_json.dart';

/// 话题（`text_extra`）。
class DouyinTextExtra {
  const DouyinTextExtra({
    this.hashtagName = '',
    this.hashtagId = 0,
    this.start = 0,
    this.end = 0,
    this.type = 0,
  });

  factory DouyinTextExtra.fromJson(Object? json) {
    final map = DouyinJson.asMap(json);
    return DouyinTextExtra(
      hashtagName: DouyinJson.asString(map['hashtag_name']),
      hashtagId: DouyinJson.asInt(map['hashtag_id']),
      start: DouyinJson.asInt(map['start']),
      end: DouyinJson.asInt(map['end']),
      type: DouyinJson.asInt(map['type']),
    );
  }

  final String hashtagName;
  final int hashtagId;
  final int start;
  final int end;
  final int type;

  String get label => hashtagName.isEmpty ? '' : '#$hashtagName';
}
