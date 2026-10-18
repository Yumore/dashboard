import 'package:dashboard/features/short_video/douyin/douyin_aweme.dart';
import 'package:dashboard/features/short_video/douyin/douyin_json.dart';

/// `GET /web/api/v2/aweme/iteminfo/?item_ids=...&dytk` 的响应。
class DouyinVideoListResponse {
  const DouyinVideoListResponse({
    this.statusCode = 0,
    this.items = const <DouyinAweme>[],
    this.extraNow = 0,
    this.logId = '',
  });

  factory DouyinVideoListResponse.fromJson(Object? json) {
    final map = DouyinJson.asMap(json);
    final extra = DouyinJson.asMap(map['extra']);
    return DouyinVideoListResponse(
      statusCode: DouyinJson.asInt(map['status_code']),
      items: DouyinJson.asList(map['item_list'])
          .map(DouyinAweme.fromJson)
          .toList(growable: false),
      extraNow: DouyinJson.asInt(extra['now']),
      logId: DouyinJson.asString(extra['logid']),
    );
  }

  final int statusCode;
  final List<DouyinAweme> items;
  final int extraNow;
  final String logId;

  bool get isSuccess => statusCode == 0;

  DouyinAweme? get first => items.isEmpty ? null : items.first;
}
