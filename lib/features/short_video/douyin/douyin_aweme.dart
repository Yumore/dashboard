import 'package:dashboard/features/short_video/douyin/douyin_author.dart';
import 'package:dashboard/features/short_video/douyin/douyin_json.dart';
import 'package:dashboard/features/short_video/douyin/douyin_music.dart';
import 'package:dashboard/features/short_video/douyin/douyin_risk_info.dart';
import 'package:dashboard/features/short_video/douyin/douyin_statistics.dart';
import 'package:dashboard/features/short_video/douyin/douyin_text_extra.dart';
import 'package:dashboard/features/short_video/douyin/douyin_video.dart';

/// 一条作品。源工程分两级：`flutter_app_cn/lib/models/Douyin.Dart` 的
/// `Itemlist`（`/web/api/v2/aweme/iteminfo/`）与
/// `flutter_app/lib/models/Tiktok.dart` 的 `ItemListData`（`/share/item/list`）。
/// 宿主把两者共有的业务字段收敛到这一个模型，两个解析器都产出它。
class DouyinAweme {
  const DouyinAweme({
    this.awemeId = '',
    this.desc = '',
    this.createTime = 0,
    this.duration = 0,
    this.awemeType = 0,
    this.isPreview = false,
    this.shareUrl = '',
    this.author,
    this.music,
    this.video,
    this.statistics,
    this.hashtags = const <DouyinTextExtra>[],
    this.riskInfo,
  });

  factory DouyinAweme.fromJson(Object? json) {
    final map = DouyinJson.asMap(json);
    return DouyinAweme(
      awemeId: DouyinJson.asString(map['aweme_id']),
      desc: DouyinJson.asString(map['desc']),
      createTime: DouyinJson.asInt(map['create_time']),
      duration: DouyinJson.asInt(map['duration']),
      awemeType: DouyinJson.asInt(map['aweme_type']),
      isPreview: DouyinJson.asBool(map['is_preview']),
      shareUrl: DouyinJson.asString(map['share_url']),
      author: map['author'] == null ? null : DouyinAuthor.fromJson(map['author']),
      music: map['music'] == null ? null : DouyinMusic.fromJson(map['music']),
      video: map['video'] == null ? null : DouyinVideo.fromJson(map['video']),
      statistics: map['statistics'] == null
          ? null
          : DouyinStatistics.fromJson(map['statistics']),
      hashtags: DouyinJson.asList(map['text_extra'])
          .map(DouyinTextExtra.fromJson)
          .toList(growable: false),
      riskInfo: map['risk_infos'] == null
          ? null
          : DouyinRiskInfo.fromJson(map['risk_infos']),
    );
  }

  final String awemeId;
  final String desc;
  final int createTime;
  final int duration;
  final int awemeType;
  final bool isPreview;
  final String shareUrl;
  final DouyinAuthor? author;
  final DouyinMusic? music;
  final DouyinVideo? video;
  final DouyinStatistics? statistics;
  final List<DouyinTextExtra> hashtags;
  final DouyinRiskInfo? riskInfo;

  bool get isPlayable => video != null;

  String get displayDesc {
    final text = desc.trim();
    return text.isEmpty ? '无描述' : text;
  }

  String get authorHandle => author?.handle ?? '@未知用户';

  String get authorName => author?.displayName ?? '未知作者';

  String get musicLabel => music?.marqueeLabel ?? '原声 - 未知';

  int get diggCount => statistics?.diggCount ?? 0;

  int get commentCount => statistics?.commentCount ?? 0;

  int get shareCount => statistics?.shareCount ?? 0;

  int get playCount => statistics?.playCount ?? 0;

  String get hashtagLabel => hashtags
      .map((tag) => tag.label)
      .where((label) => label.isNotEmpty)
      .join(' ');

  String get riskLabel {
    final risk = riskInfo;
    if (risk == null || !risk.warn) {
      return '';
    }
    return risk.content.trim().isEmpty ? '该作品存在风险提示' : risk.content.trim();
  }
}
