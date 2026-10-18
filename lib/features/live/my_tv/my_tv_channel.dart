/// A live channel parsed from an M3U or TVbox playlist.
class MyTvChannel {
  const MyTvChannel({
    required this.number,
    required this.name,
    required this.group,
    required this.tvgName,
    required this.urls,
    this.logo,
  });

  /// Sequential channel number (1-based) assigned after optional simplification.
  final int number;

  /// Display name shown in the channel list.
  final String name;

  /// Group / `group-title` this channel belongs to.
  final String group;

  /// Name used to match XMLTV `<display-name>` entries.
  final String tvgName;

  /// Playback URLs, in preference order.
  final List<Uri> urls;

  final Uri? logo;

  @override
  String toString() => 'MyTvChannel($number, $name, $group, $tvgName)';
}
