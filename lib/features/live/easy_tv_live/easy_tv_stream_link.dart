/// Stream-link helpers porting the source app's `M3uUtil.isLiveLink`.
class EasyTvStreamLink {
  const EasyTvStreamLink._();

  /// The source app treats a line as playable when it starts with one of
  /// `h` (http/https), `r` (rtmp/rtsp), `p` (p2p), `s` (srt) or `w` (ws/wss).
  static bool isLive(String value) {
    final trimmed = value.trim().toLowerCase();
    if (trimmed.isEmpty) return false;
    return 'hrpsw'.contains(trimmed[0]);
  }

  /// Splits a `#`-joined line into URIs, dropping empty fragments and anything
  /// that does not look like a stream link.
  static List<Uri> split(String value) {
    final urls = <Uri>[];
    for (final part in value.split('#')) {
      final candidate = part.trim();
      if (!isLive(candidate)) continue;
      final uri = Uri.tryParse(candidate);
      if (uri != null) urls.add(uri);
    }
    return urls;
  }
}
