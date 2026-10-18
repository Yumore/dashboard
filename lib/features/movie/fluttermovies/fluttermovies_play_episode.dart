import 'package:dashboard/features/movie/fluttermovies/fluttermovies_json.dart';

/// `urls[]` 中的一集（源站字段名：name / url / from / nid）。
class FlutterMoviesPlayEpisode {
  const FlutterMoviesPlayEpisode({
    this.name = '',
    this.url = '',
    this.from = '',
    this.nid = 0,
  });

  factory FlutterMoviesPlayEpisode.fromJson(Map<String, dynamic> json) =>
      FlutterMoviesPlayEpisode(
        name: FlutterMoviesJson.asString(json['name']),
        url: FlutterMoviesJson.asString(json['url']),
        from: FlutterMoviesJson.asString(json['from']),
        nid: FlutterMoviesJson.asInt(json['nid']),
      );

  final String name;
  final String url;
  final String from;
  final int nid;

  /// 只接受 http/https 的播放地址；解析失败即不可播。
  Uri? get uri {
    final parsed = Uri.tryParse(url.trim());
    if (parsed == null) return null;
    if (parsed.scheme != 'http' && parsed.scheme != 'https') return null;
    return parsed;
  }

  bool get isPlayable => uri != null;

  /// 源站的按钮文案清理：去掉 '-' 与 '期'。
  String get label {
    final cleaned = name.replaceAll('-', '').replaceAll('期', '').trim();
    return cleaned.isNotEmpty ? cleaned : name.trim();
  }
}
