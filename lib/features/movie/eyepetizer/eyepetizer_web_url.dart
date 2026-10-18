import 'package:dashboard/features/movie/eyepetizer/eyepetizer_json.dart';

/// `webUrl` on a 开眼 feed item (`common_item_model.dart:277`).
///
/// The source never opened it; the port uses [raw] as the external-launch
/// fallback when a video has no playable stream URL.
class EyepetizerWebUrl {
  const EyepetizerWebUrl({this.raw = '', this.forWeibo = ''});

  factory EyepetizerWebUrl.fromJson(Object? json) {
    final map = EyepetizerJson.asMap(json);
    return EyepetizerWebUrl(
      raw: EyepetizerJson.asString(map['raw']),
      forWeibo: EyepetizerJson.asString(map['forWeibo']),
    );
  }

  /// Absolute `www.kaiyanapp.com` share page.
  final String raw;

  final String forWeibo;
}
