/// A subscription source entry, porting the source app's `SubScribeModel`.
///
/// `link` is either an HTTP(S) playlist URL or a `default` sentinel that
/// resolves to the app's public default playlist. `local` marks a source
/// imported from the device file system by the mobile app.
class EasyTvSource {
  const EasyTvSource({
    required this.link,
    this.time = '',
    this.selected = false,
    this.local = false,
  });

  /// Sentinel link used by the app's built-in public playlist.
  static const defaultLink = 'default';

  final String time;
  final String link;
  final bool selected;
  final bool local;

  bool get isDefault => link == defaultLink;

  /// Human-readable label used in the source list.
  String get displayLink => isDefault ? '默认公共源' : link;

  EasyTvSource copyWith({
    String? time,
    String? link,
    bool? selected,
    bool? local,
  }) {
    return EasyTvSource(
      time: time ?? this.time,
      link: link ?? this.link,
      selected: selected ?? this.selected,
      local: local ?? this.local,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'time': time,
    'link': link,
    'selected': selected,
    'local': local,
  };

  factory EasyTvSource.fromJson(Map<String, dynamic> json) {
    return EasyTvSource(
      time: json['time'] as String? ?? '',
      link: json['link'] as String? ?? '',
      selected: json['selected'] as bool? ?? false,
      local: json['local'] as bool? ?? false,
    );
  }
}
