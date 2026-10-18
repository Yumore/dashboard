import 'package:dashboard/features/live/easy_tv_live/easy_tv_catalog.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_channel.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_channel_group.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_playlist_type.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_stream_link.dart';

/// Parses easy_tv_live subscriptions, porting `M3uUtil._parseM3u`.
///
/// Two dialects are supported, exactly like the source app:
///
/// * `#EXTM3U` / `#EXTINF` playlists, including `x-tvg-url`, `group-title`,
///   `tvg-name`/`tvg-id`, `tvg-logo` and `#UA-Hint`,
/// * comma-separated TXT lists where a non-URL line names the next group.
///
/// Deviations from the source app, both data-loss bugs that a golden port must
/// not keep: the last playlist line is parsed (the source loops to
/// `lines.length - 1` and drops it) and channel names keep commas after the
/// first separator (the source takes only the last comma segment).
class EasyTvCatalogParser {
  const EasyTvCatalogParser();

  /// Group used when an entry has no usable `group-title`/section header.
  static const defaultGroupName = '默认';

  EasyTvCatalog parse(String source, {String uaHint = ''}) {
    final text = source.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final head = text.trimLeft();
    if (head.isEmpty) {
      return const EasyTvCatalog(
        type: EasyTvPlaylistType.txt,
        groups: <EasyTvChannelGroup>[],
      );
    }
    final isM3u = head.startsWith('#EXTM3U') || head.startsWith('#EXTINF');
    final groups = <String, List<EasyTvChannel>>{};
    var epgUrl = '';
    var capturedUa = '';

    if (isM3u) {
      final result = _parseM3u(text, groups, uaHint);
      epgUrl = result.epgUrl;
      capturedUa = result.uaHint;
    } else {
      _parseTxt(text, groups);
    }

    return EasyTvCatalog(
      type: isM3u ? EasyTvPlaylistType.m3u : EasyTvPlaylistType.txt,
      groups: _number(groups),
      epgUrl: epgUrl.isEmpty ? null : epgUrl,
      uaHint: uaHint.isNotEmpty ? uaHint : capturedUa,
    );
  }

  ({String epgUrl, String uaHint}) _parseM3u(
    String text,
    Map<String, List<EasyTvChannel>> groups,
    String uaHint,
  ) {
    final lines = text.split('\n');
    var epgUrl = '';
    var capturedUa = '';
    var group = defaultGroupName;
    var title = '';

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      if (line.startsWith('#EXTM3U')) {
        final tvgUrl = _attribute(line, 'x-tvg-url');
        if (tvgUrl != null && tvgUrl.isNotEmpty) epgUrl = tvgUrl;
        continue;
      }

      if (line.startsWith('#EXTINF:')) {
        final info = _extInf(line);
        if (info == null) continue;
        group = info.group;
        title = info.title;
        final channel = _channelFor(groups, group, title, info.id, info.logo);

        final next = i + 1 < lines.length ? lines[i + 1].trim() : '';
        if (EasyTvStreamLink.isLive(next)) {
          channel.urls.addAll(EasyTvStreamLink.split(next));
          i += 1;
          continue;
        }
        final after = i + 2 < lines.length ? lines[i + 2].trim() : '';
        if (EasyTvStreamLink.isLive(after)) {
          channel.urls.addAll(EasyTvStreamLink.split(after));
          i += 2;
          continue;
        }
        continue;
      }

      if (line.startsWith('#UA-Hint')) {
        if (uaHint.isEmpty) capturedUa = _uaHintValue(line);
        continue;
      }

      if (line.startsWith('#')) continue;

      // A bare stream line after an entry adds another playback line.
      if (title.isEmpty) continue;
      final channel = _findChannel(groups, group, title);
      if (channel == null) continue;
      channel.urls.addAll(EasyTvStreamLink.split(line));
    }

    return (epgUrl: epgUrl, uaHint: capturedUa);
  }

  void _parseTxt(String text, Map<String, List<EasyTvChannel>> groups) {
    final lines = text.split('\n');
    var group = defaultGroupName;
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      final comma = line.indexOf(',');
      if (comma < 0) continue;
      final name = line.substring(0, comma).trim();
      final rest = line.substring(comma + 1).trim();
      // The source app reads only the segment between the first two commas.
      final value = rest.split(',').first.trim();

      if (EasyTvStreamLink.isLive(value)) {
        final channel = _channelFor(groups, group, name, null, null);
        channel.urls.addAll(EasyTvStreamLink.split(value));
      } else {
        group = name.isEmpty ? '$defaultGroupName${i + 1}' : name;
        groups.putIfAbsent(group, () => <EasyTvChannel>[]);
      }
    }
  }

  /// Finds or creates the channel, appending backup lines to an existing entry
  /// just like the source app's `firstWhere(..., orElse: create)`.
  EasyTvChannel _channelFor(
    Map<String, List<EasyTvChannel>> groups,
    String group,
    String title,
    String? id,
    String? logo,
  ) {
    final channels = groups.putIfAbsent(group, () => <EasyTvChannel>[]);
    final existing = _indexOfTitle(channels, title);
    if (existing >= 0) {
      final channel = channels[existing];
      final merged = channel.copyWith(
        id: channel.id ?? id,
        logo: channel.logo ?? logo,
      );
      channels[existing] = merged;
      return merged;
    }
    final channel = EasyTvChannel(
      title: title,
      urls: <Uri>[],
      id: id,
      logo: logo,
    );
    channels.add(channel);
    return channel;
  }

  EasyTvChannel? _findChannel(
    Map<String, List<EasyTvChannel>> groups,
    String group,
    String title,
  ) {
    final channels = groups[group];
    if (channels == null) return null;
    final index = _indexOfTitle(channels, title);
    return index < 0 ? null : channels[index];
  }

  int _indexOfTitle(List<EasyTvChannel> channels, String title) =>
      channels.indexWhere((channel) => channel.title == title);

  List<EasyTvChannelGroup> _number(Map<String, List<EasyTvChannel>> groups) {
    final result = <EasyTvChannelGroup>[];
    var serial = 1;
    var groupIndex = 0;
    for (final entry in groups.entries) {
      final channels = <EasyTvChannel>[];
      var channelIndex = 0;
      for (final channel in entry.value) {
        channels.add(
          channel.copyWith(
            serialNum: serial,
            groupIndex: groupIndex,
            channelIndex: channelIndex,
          ),
        );
        serial += 1;
        channelIndex += 1;
      }
      result.add(
        EasyTvChannelGroup(
          name: entry.key,
          channels: channels,
          index: groupIndex,
        ),
      );
      groupIndex += 1;
    }
    return result;
  }

  ({String group, String title, String? id, String? logo})? _extInf(
    String line,
  ) {
    final body = line.substring('#EXTINF:'.length);
    final comma = _firstCommaOutsideQuotes(body);
    if (comma < 0) return null;
    final attributes = body.substring(0, comma);
    final title = body.substring(comma + 1).trim();
    if (title.isEmpty) return null;
    final group = _attribute(attributes, 'group-title');
    final id =
        _attribute(attributes, 'tvg-name') ?? _attribute(attributes, 'tvg-id');
    final logo = _attribute(attributes, 'tvg-logo');
    return (
      group: group == null || group.isEmpty ? defaultGroupName : group,
      title: title,
      id: _nullIfEmpty(id),
      logo: _nullIfEmpty(logo),
    );
  }

  int _firstCommaOutsideQuotes(String value) {
    var inQuotes = false;
    for (var i = 0; i < value.length; i++) {
      final char = value[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        return i;
      }
    }
    return -1;
  }

  String? _attribute(String line, String name) {
    final quoted = RegExp(
      '${RegExp.escape(name)}\\s*=\\s*"([^"]*)"',
    ).firstMatch(line);
    if (quoted != null) return quoted.group(1);
    return RegExp(
      '${RegExp.escape(name)}\\s*=\\s*([^\\s,]+)',
    ).firstMatch(line)?.group(1);
  }

  String _uaHintValue(String line) {
    for (final token in line.trim().split(RegExp(r'\s+'))) {
      if (token.contains('/')) return token;
    }
    return '';
  }

  String? _nullIfEmpty(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }
}
