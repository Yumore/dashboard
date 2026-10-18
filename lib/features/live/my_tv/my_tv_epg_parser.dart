import 'package:dashboard/features/live/my_tv/my_tv_programme.dart';

/// Parses an XMLTV document into programmes keyed by channel display name.
///
/// The source app keys the EPG result by the XMLTV `<display-name>`, then
/// matches channels by `tvgName`, which is what [channels] filters on.
class MyTvEpgParser {
  const MyTvEpgParser();

  static final _channelPattern = RegExp(
    r'<channel\b[^>]*\bid="([^"]*)"[^>]*>(.*?)</channel>',
    dotAll: true,
  );
  static final _programmePattern = RegExp(
    r'<programme\b([^>]*)>(.*?)</programme>',
    dotAll: true,
  );
  static final _displayNamePattern = RegExp(
    r'<display-name[^>]*>(.*?)</display-name>',
    dotAll: true,
  );
  static final _titlePattern = RegExp(
    r'<title[^>]*>(.*?)</title>',
    dotAll: true,
  );

  /// Returns display-name to programmes, optionally limited to [channels].
  Map<String, List<MyTvProgramme>> parse(String xml, {Set<String>? channels}) {
    if (xml.isEmpty) return const {};

    final namesById = <String, String>{};
    for (final match in _channelPattern.allMatches(xml)) {
      final id = match.group(1);
      if (id == null) continue;
      final display = _displayNamePattern.firstMatch(match.group(2) ?? '');
      final name = _decode(display?.group(1) ?? '').trim();
      if (name.isNotEmpty) namesById[id] = name;
    }

    final programmes = <String, List<MyTvProgramme>>{};
    for (final match in _programmePattern.allMatches(xml)) {
      final attributes = match.group(1) ?? '';
      final channelId = _attribute(attributes, 'channel');
      if (channelId == null) continue;
      final name = namesById[channelId];
      if (name == null) continue;
      if (channels != null && !channels.contains(name)) continue;
      final start = _parseTime(_attribute(attributes, 'start'));
      final stop = _parseTime(_attribute(attributes, 'stop'));
      if (start == null || stop == null) continue;
      final title = _decode(
        _titlePattern.firstMatch(match.group(2) ?? '')?.group(1) ?? '',
      ).trim();
      programmes
          .putIfAbsent(name, () => <MyTvProgramme>[])
          .add(MyTvProgramme(start: start, stop: stop, title: title));
    }

    for (final list in programmes.values) {
      list.sort((a, b) => a.start.compareTo(b.start));
    }
    return programmes;
  }

  String? _attribute(String attributes, String name) => RegExp(
    '(?:^|\\s)${RegExp.escape(name)}="([^"]*)"',
  ).firstMatch(attributes)?.group(1);

  /// Parses the `YYYYMMDDHHMMSS` prefix of an XMLTV timestamp.
  ///
  /// The trailing timezone offset is ignored, mirroring the source app, so the
  /// value is interpreted in local time.
  int? _parseTime(String? value) {
    if (value == null) return null;
    final match = RegExp(r'^(\d{14})').firstMatch(value.trim());
    if (match == null) return null;
    final digits = match.group(1)!;
    return DateTime(
      int.parse(digits.substring(0, 4)),
      int.parse(digits.substring(4, 6)),
      int.parse(digits.substring(6, 8)),
      int.parse(digits.substring(8, 10)),
      int.parse(digits.substring(10, 12)),
      int.parse(digits.substring(12, 14)),
    ).millisecondsSinceEpoch;
  }

  String _decode(String value) => value
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&nbsp;', ' ')
      .replaceAllMapped(
        RegExp(r'&#(\d+);'),
        (match) => String.fromCharCode(int.parse(match.group(1)!)),
      )
      .replaceAll('&amp;', '&');
}
