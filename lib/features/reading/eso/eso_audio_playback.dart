import 'dart:convert';

import 'package:dashboard/features/media/media_stream_source.dart';

/// 音频正文 → 播放源（移植 eso `lib/page/audio_page_refactor.dart`
/// 的 `loadChapter` 对正文列表的解释规则）。
///
/// 源实现在 `ContentProvider` 拿到正文列表后这样用：
/// - `result[0]` 是播放地址，地址后面可以跟 `@headers{...}` 附加请求头；
/// - 其余以 `@cover` 开头的是封面、以 `@lrc` 开头的是歌词。
///
/// 宿主播放器（[MediaStreamSource]）只吃地址 + 请求头，没有歌词接口，
/// 因此 `@cover` / `@lrc` 条目被忽略。
class EsoAudioPlayback {
  /// 源实现在地址后用 `@headers` 拼接请求头 JSON。
  static const String headerMarker = '@headers';

  static List<MediaStreamSource> sourcesFor(
      List<String> content, String label) {
    final sources = <MediaStreamSource>[];
    for (final line in content) {
      final text = line.trim();
      if (text.isEmpty) continue;
      if (text.startsWith('@cover') || text.startsWith('@lrc')) continue;
      final parsed = splitHeaders(text);
      if (parsed.url.isEmpty) continue;
      final uri = Uri.tryParse(parsed.url);
      if (uri == null) continue;
      sources.add(MediaStreamSource(
        label: label,
        url: uri,
        headers: parsed.headers,
      ));
    }
    return sources;
  }

  /// 把 `地址@headers{"referer":"..."}` 拆成地址与请求头。
  static ({String url, Map<String, String> headers}) splitHeaders(String raw) {
    final index = raw.indexOf(headerMarker);
    if (index < 0) {
      return (url: raw, headers: const <String, String>{});
    }
    return (
      url: raw.substring(0, index),
      headers: parseHeaders(raw.substring(index + headerMarker.length)),
    );
  }

  /// 解析请求头 JSON；空串或坏 JSON 返回空表（源实现同样吞掉异常）。
  static Map<String, String> parseHeaders(String payload) {
    final text = payload.trim();
    if (text.isEmpty) return const <String, String>{};
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry('$key', '$value'));
      }
    } catch (_) {
      // 坏 JSON 当作没有请求头
    }
    return const <String, String>{};
  }
}
