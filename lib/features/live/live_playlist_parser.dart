import 'package:dashboard/features/live/live_channel.dart';

/// Adapted from easy_tv_live's M3uUtil: supports EXTINF and grouped TXT lists.
class LivePlaylistParser {
  const LivePlaylistParser();

  List<LiveChannel> parse(String source) {
    final lines = source.split(RegExp(r'\r?\n'));
    final isM3u = lines.any((line) => line.trimLeft().startsWith('#EXTINF:'));
    return isM3u ? _parseM3u(lines) : _parseTxt(lines);
  }

  List<LiveChannel> _parseM3u(List<String> lines) {
    final channels = <LiveChannel>[];
    String? info;
    for (final raw in lines) {
      final line = raw.trim();
      if (line.startsWith('#EXTINF:')) {
        info = line;
        continue;
      }
      if (line.isEmpty || line.startsWith('#') || info == null) continue;
      if (!info.contains(',')) {
        info = null;
        continue;
      }
      final urls = _parseUrls(line);
      if (urls.isNotEmpty) {
        final name = info.substring(info.indexOf(',') + 1).trim();
        if (name.isNotEmpty) {
          channels.add(
            LiveChannel(
              name: name,
              group: _attribute(info, 'group-title') ?? '未分组',
              logo: Uri.tryParse(_attribute(info, 'tvg-logo') ?? ''),
              id: _attribute(info, 'tvg-id') ?? _attribute(info, 'tvg-name'),
              urls: urls,
            ),
          );
        }
      }
      info = null;
    }
    return _mergeChannels(channels);
  }

  List<LiveChannel> _parseTxt(List<String> lines) {
    final channels = <LiveChannel>[];
    var group = '未分组';
    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      final comma = line.indexOf(',');
      if (comma < 0) continue;
      final name = line.substring(0, comma).trim();
      final value = line.substring(comma + 1).trim();
      if (value == '#genre#') {
        group = name.isEmpty ? '未分组' : name;
        continue;
      }
      final urls = _parseUrls(value);
      if (name.isNotEmpty && urls.isNotEmpty) {
        channels.add(LiveChannel(name: name, group: group, urls: urls));
      }
    }
    return _mergeChannels(channels);
  }

  String? _attribute(String line, String name) {
    final quoted = RegExp('${RegExp.escape(name)}="([^"]*)"').firstMatch(line);
    if (quoted != null) return quoted.group(1);
    return RegExp(
      '${RegExp.escape(name)}=([^\\s,]+)',
    ).firstMatch(line)?.group(1);
  }

  List<Uri> _parseUrls(String value) {
    return value
        .split('#')
        .map((part) => Uri.tryParse(part.trim()))
        .whereType<Uri>()
        .where(
          (uri) =>
              uri.hasScheme &&
              <String>{
                'http',
                'https',
                'rtmp',
                'rtsp',
                'p2p',
                'srt',
                'udp',
              }.contains(uri.scheme.toLowerCase()),
        )
        .toList();
  }

  List<LiveChannel> _mergeChannels(List<LiveChannel> channels) {
    final merged = <String, LiveChannel>{};
    for (final channel in channels) {
      final key = '${channel.group}\u0000${channel.name}';
      final previous = merged[key];
      merged[key] = previous == null
          ? channel
          : LiveChannel(
              name: previous.name,
              group: previous.group,
              id: previous.id ?? channel.id,
              logo: previous.logo ?? channel.logo,
              urls: {...previous.urls, ...channel.urls}.toList(),
            );
    }
    return merged.values.toList();
  }
}
