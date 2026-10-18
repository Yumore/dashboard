import 'package:dashboard/features/short_video/douyin/douyin_json.dart';

/// 风险提示（`risk_infos`），详情页在 `warn` 为真时展示 `content`。
class DouyinRiskInfo {
  const DouyinRiskInfo({this.warn = false, this.type = 0, this.content = ''});

  factory DouyinRiskInfo.fromJson(Object? json) {
    final map = DouyinJson.asMap(json);
    return DouyinRiskInfo(
      warn: DouyinJson.asBool(map['warn']),
      type: DouyinJson.asInt(map['type']),
      content: DouyinJson.asString(map['content']),
    );
  }

  final bool warn;
  final int type;
  final String content;
}
