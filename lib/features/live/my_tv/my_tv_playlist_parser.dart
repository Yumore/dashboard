import 'package:dashboard/features/live/live_playlist_parser.dart';
import 'package:dashboard/features/live/my_tv/my_tv_channel.dart';
import 'package:dashboard/features/live/my_tv/my_tv_group.dart';

/// Extends the host [LivePlaylistParser] with the my_tv specifics:
///
/// * TVbox `#genre#` sections and full-width `，` separators (handled by the
///   host parser once commas are normalised),
/// * `tvg-name` capture for XMLTV matching,
/// * the CCTV / 卫视 simplification filter,
/// * sequential channel numbering over the surviving channels.
class MyTvPlaylistParser {
  const MyTvPlaylistParser();

  List<MyTvGroup> parse(String source, {bool simplify = false}) {
    final normalized = source.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    if (normalized.trim().isEmpty) return const [];

    final isM3u = normalized.contains('#EXTINF:');
    final prepared = isM3u ? normalized : normalized.replaceAll('，', ',');
    final parsed = const LivePlaylistParser().parse(prepared);
    final tvgNames = isM3u
        ? _collectTvgNames(prepared)
        : const <String, String>{};

    final channels = <MyTvChannel>[];
    for (final channel in parsed) {
      if (simplify && !_keepUnderSimplify(channel.name)) continue;
      channels.add(
        MyTvChannel(
          number: channels.length + 1,
          name: channel.name,
          group: channel.group,
          tvgName: tvgNames[channel.name] ?? channel.id ?? channel.name,
          urls: channel.urls,
          logo: channel.logo,
        ),
      );
    }
    return _groupChannels(channels);
  }

  /// Maps channel display name to its `tvg-name` attribute, if present.
  Map<String, String> _collectTvgNames(String source) {
    final names = <String, String>{};
    for (final line in source.split('\n')) {
      if (!line.startsWith('#EXTINF:')) continue;
      final comma = line.indexOf(',');
      if (comma < 0) continue;
      final name = line.substring(comma + 1).trim();
      final tvgName = _attribute(line, 'tvg-name');
      if (name.isNotEmpty && tvgName != null && tvgName.isNotEmpty) {
        names[name] = tvgName;
      }
    }
    return names;
  }

  String? _attribute(String line, String name) {
    final quoted = RegExp(
      '${RegExp.escape(name)}="([^"]*)"',
    ).firstMatch(line)?.group(1);
    if (quoted != null) return quoted;
    return RegExp(
      '${RegExp.escape(name)}=([^\\s,]+)',
    ).firstMatch(line)?.group(1);
  }

  bool _keepUnderSimplify(String name) {
    if (name.toLowerCase().startsWith('cctv')) return true;
    return name.endsWith('卫视');
  }

  List<MyTvGroup> _groupChannels(List<MyTvChannel> channels) {
    final grouped = <String, List<MyTvChannel>>{};
    for (final channel in channels) {
      grouped.putIfAbsent(channel.group, () => <MyTvChannel>[]).add(channel);
    }
    final groups = <MyTvGroup>[];
    for (final entry in grouped.entries) {
      groups.add(
        MyTvGroup(index: groups.length, name: entry.key, channels: entry.value),
      );
    }
    return groups;
  }
}
