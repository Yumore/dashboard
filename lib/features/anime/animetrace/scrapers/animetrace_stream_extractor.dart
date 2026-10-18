/// Pulls a directly playable stream URL out of an anime episode page.
///
/// The four ported sites all embed a player object in the page
/// (`player_aaaa = {...}` / `"url":"https://.../index.m3u8"`) or link an m3u8
/// directly. Extraction is deliberately conservative: when nothing playable is
/// found the caller shows "未找到播放地址" rather than guessing.
class AnimeTraceStreamExtractor {
  const AnimeTraceStreamExtractor._();

  static final RegExp _quotedUrl = RegExp('"url"\\s*:\\s*"([^"]+)"');
  static final RegExp _singleQuotedUrl = RegExp("url\\s*[:=]\\s*'([^']+)'");
  static final RegExp _m3u8 = RegExp(
    r'''https?://[^\s"'<>\\]+\.m3u8[^\s"'<>\\]*''',
  );
  static final RegExp _mp4 = RegExp(
    r'''https?://[^\s"'<>\\]+\.mp4[^\s"'<>\\]*''',
  );

  /// Returns the first playable URL in [html], or `null`.
  static String? extract(String html) {
    for (final pattern in <RegExp>[_quotedUrl, _singleQuotedUrl]) {
      final match = pattern.firstMatch(html);
      final candidate = _unescape(match?.group(1));
      if (_isPlayable(candidate)) return candidate;
    }
    for (final pattern in <RegExp>[_m3u8, _mp4]) {
      final candidate = _unescape(pattern.firstMatch(html)?.group(0));
      if (_isPlayable(candidate)) return candidate;
    }
    return null;
  }

  static bool _isPlayable(String? value) {
    if (value == null) return false;
    final trimmed = value.trim();
    if (!trimmed.startsWith('http')) return false;
    if (trimmed == 'http://' || trimmed == 'https://') return false;
    return true;
  }

  /// Player objects JSON-escape slashes (`https:\/\/host\/x.m3u8`) and some
  /// sites escape them as `\u002F`.
  static String _unescape(String? value) {
    if (value == null) return '';
    return value
        .replaceAll(r'\/', '/')
        .replaceAll(r'\u002F', '/')
        .replaceAll(r'\u002f', '/')
        .replaceAll('&amp;', '&');
  }
}
