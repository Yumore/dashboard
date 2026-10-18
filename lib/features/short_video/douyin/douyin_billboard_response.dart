import 'package:dashboard/features/short_video/douyin/douyin_billboard_entry.dart';
import 'package:dashboard/features/short_video/douyin/douyin_json.dart';

/// `GET /aweme/v1/creator/data/billboard/` 的响应。
class DouyinBillboardResponse {
  const DouyinBillboardResponse({
    this.statusCode = 0,
    this.statusMsg = '',
    this.entries = const <DouyinBillboardEntry>[],
    this.extraNow = 0,
  });

  factory DouyinBillboardResponse.fromJson(Object? json) {
    final map = DouyinJson.asMap(json);
    final extra = DouyinJson.asMap(map['extra']);
    return DouyinBillboardResponse(
      statusCode: DouyinJson.asInt(map['status_code']),
      statusMsg: DouyinJson.asString(map['status_msg']),
      entries: DouyinJson.asList(map['billboard_data'])
          .map(DouyinBillboardEntry.fromJson)
          .toList(growable: false),
      extraNow: DouyinJson.asInt(extra['now']),
    );
  }

  final int statusCode;
  final String statusMsg;
  final List<DouyinBillboardEntry> entries;
  final int extraNow;

  bool get isSuccess => statusCode == 0;

  bool get isEmpty => entries.isEmpty;
}
