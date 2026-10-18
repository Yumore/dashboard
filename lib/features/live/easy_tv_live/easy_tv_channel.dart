/// One playable channel parsed from an easy_tv_live subscription.
///
/// Ports the source app's `Channel` entity: `id` is the XMLTV channel id
/// (`tvg-name` preferred over `tvg-id`), `title` is the display name and
/// `urls` are the alternative playback lines in playlist order.
class EasyTvChannel {
  const EasyTvChannel({
    required this.title,
    required this.urls,
    this.id,
    this.logo,
    this.serialNum = 0,
    this.groupIndex = 0,
    this.channelIndex = 0,
  });

  final String title;
  final List<Uri> urls;
  final String? id;
  final String? logo;

  /// 1-based position across the whole playlist, as assigned by the parser.
  final int serialNum;
  final int groupIndex;
  final int channelIndex;

  bool get hasPlayableUrl => urls.isNotEmpty;

  EasyTvChannel copyWith({
    String? title,
    List<Uri>? urls,
    String? id,
    String? logo,
    int? serialNum,
    int? groupIndex,
    int? channelIndex,
  }) {
    return EasyTvChannel(
      title: title ?? this.title,
      urls: urls ?? this.urls,
      id: id ?? this.id,
      logo: logo ?? this.logo,
      serialNum: serialNum ?? this.serialNum,
      groupIndex: groupIndex ?? this.groupIndex,
      channelIndex: channelIndex ?? this.channelIndex,
    );
  }
}
