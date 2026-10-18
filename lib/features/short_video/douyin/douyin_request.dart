import 'package:dashboard/features/short_video/douyin/douyin_endpoint.dart';

/// 源工程里靠字符串拼接得到的 URL，统一在宿主构造为 [Uri]。
class DouyinRequest {
  DouyinRequest._();

  /// `host + "/aweme/v1/creator/data/billboard/?billboard_type=4"`。
  static Uri billboard({int billboardType = 4}) {
    return Uri.parse(DouyinEndpoint.billboardUrl)
        .replace(queryParameters: <String, String>{
      'billboard_type': '$billboardType',
    });
  }

  /// `api.video + id + "&dytk"`：注意源码的 `dytk` 没有值，这里保留原始
  /// 查询串而不走 `queryParameters`（后者会渲染成 `dytk=`）。
  static Uri videoList(Iterable<String> awemeIds) {
    final ids = awemeIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .join(',');
    return Uri.parse(DouyinEndpoint.itemInfoUrl).replace(
      query: 'item_ids=${Uri.encodeQueryComponent(ids)}&dytk',
    );
  }

  /// `host + "/share/item/list?secUid=&id=&type=5&count=30&minCursor=0
  ///  &maxCursor=0&shareUid=&lang=en&_signature=..."`。
  static Uri userPosts({
    required String signature,
    String secUid = '',
    String id = '',
    int count = 30,
    int minCursor = 0,
    int maxCursor = 0,
    String shareUid = '',
    String lang = 'en',
  }) {
    return Uri.parse(DouyinEndpoint.shareItemListUrl)
        .replace(queryParameters: <String, String>{
      'secUid': secUid,
      'id': id,
      'type': '5',
      'count': '$count',
      'minCursor': '$minCursor',
      'maxCursor': '$maxCursor',
      'shareUid': shareUid,
      'lang': lang,
      '_signature': signature,
    });
  }

  /// `player + video_id + "&ratio=720p&line=0&media_type=4..."`。
  static Uri play(String videoId) {
    return Uri.parse(DouyinEndpoint.playUrl)
        .replace(queryParameters: <String, String>{
      'video_id': videoId,
      ...DouyinEndpoint.playQuery,
    });
  }
}
