/// 详情页 `downloadUrl` 里的一条地址。
///
/// 源站把多集地址用 `;` 拼成一个字符串，条目可能是 `ftp://`、`ed2k://`
/// 或 `https://`。宿主播放器只能直接播 HTTP(S)，所以这里保留原始地址与
/// 解析后的 [uri]，并把可播放性判断集中在 [isPlayable]。
class DyttPlayUrl {
  DyttPlayUrl._({required this.raw, required this.uri});

  factory DyttPlayUrl.parse(String raw) {
    final trimmed = raw.trim();
    final uri = Uri.tryParse(trimmed);
    if (trimmed.isEmpty || uri == null || uri.scheme.isEmpty) {
      throw FormatException('无法解析播放地址：$trimmed');
    }
    return DyttPlayUrl._(raw: trimmed, uri: uri);
  }

  /// 去掉首尾空白后的原始地址。
  final String raw;

  final Uri uri;

  String get scheme => uri.scheme;

  bool get isPlayable => scheme == 'http' || scheme == 'https';

  /// 取路径最后一段作为展示名，例如
  /// `[阳光电影-www.ygdy8.com]致亲爱的法官大人-01+02.mp4`。
  String get fileName {
    if (uri.pathSegments.isEmpty) return raw;
    return uri.pathSegments.last;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DyttPlayUrl && other.raw == raw && other.uri == uri;

  @override
  int get hashCode => Object.hash(raw, uri);

  @override
  String toString() => raw;
}
