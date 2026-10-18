import 'package:dashboard/features/movie/bilivideo_down/bili_dash.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_durl_segment.dart';

/// The `data` object of `GET /x/player/playurl`.
///
/// Ports `VideoPlayInfoEntity` from the source app. The source read only
/// `quality`, `format`, `timelength` and `durl[0]`; the `accept_*` and
/// `support_formats` blocks are kept because the UI offers a quality picker.
class BiliPlayInfo {
  const BiliPlayInfo({
    required this.quality,
    required this.format,
    required this.timelength,
    required this.acceptQuality,
    required this.acceptFormat,
    required this.durl,
    this.supportFormats = const <BiliPlaySupportFormat>[],
    this.dash,
  });

  /// Quality the server actually answered with (may be lower than requested).
  final int quality;

  /// `mp4` / `flv` for progressive responses, `mp4` also for DASH.
  final String format;

  /// Duration in **milliseconds**.
  final int timelength;

  /// Every quality the server is willing to serve, highest first.
  final List<int> acceptQuality;

  /// Accepted container names, e.g. `['mp4', 'flv']`.
  final List<String> acceptFormat;

  /// Progressive segments; empty when the response is DASH-only.
  final List<BiliDurlSegment> durl;

  /// `[{quality, format, new_description, …}]` — only the display strings are
  /// kept; used to label the quality picker.
  final List<BiliPlaySupportFormat> supportFormats;

  final BiliDash? dash;

  bool get hasProgressiveStream =>
      durl.any((segment) => segment.url.isNotEmpty);

  bool get hasDashStream => dash?.hasVideo ?? false;

  /// First progressive segment — the exact value the source app downloaded
  /// (`infoData.durl[0]`).
  BiliDurlSegment? get primarySegment =>
      hasProgressiveStream ? durl.firstWhere((s) => s.url.isNotEmpty) : null;

  /// Number of progressive segments. `> 1` means bilibili split the stream and
  /// the segments would need concatenating; the source app silently downloaded
  /// only the first one, and so does this port.
  int get segmentCount => durl.where((s) => s.url.isNotEmpty).length;

  /// Highest quality the server offers.
  int get maxQuality => acceptQuality.isEmpty
      ? quality
      : acceptQuality.reduce((a, b) => a > b ? a : b);

  factory BiliPlayInfo.fromJson(Map<String, dynamic> json) => BiliPlayInfo(
    quality: _asInt(json['quality']),
    format: '${json['format'] ?? ''}',
    timelength: _asInt(json['timelength']),
    acceptQuality: <int>[
      for (final entry in _intList(json['accept_quality']))
        if (entry > 0) entry,
    ],
    acceptFormat: _stringList(json['accept_format']),
    durl: <BiliDurlSegment>[
      for (final entry in (json['durl'] as List? ?? const <Object?>[]))
        if (entry is Map)
          BiliDurlSegment.fromJson(Map<String, dynamic>.from(entry)),
    ],
    supportFormats: <BiliPlaySupportFormat>[
      for (final entry
          in (json['support_formats'] as List? ?? const <Object?>[]))
        if (entry is Map)
          BiliPlaySupportFormat.fromJson(Map<String, dynamic>.from(entry)),
    ],
    dash: json['dash'] is Map
        ? BiliDash.fromJson(Map<String, dynamic>.from(json['dash'] as Map))
        : null,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'quality': quality,
    'format': format,
    'timelength': timelength,
    'accept_quality': acceptQuality,
    'accept_format': acceptFormat,
    'durl': <dynamic>[for (final segment in durl) segment.toJson()],
    'support_formats': <dynamic>[
      for (final entry in supportFormats)
        <String, dynamic>{
          'quality': entry.quality,
          'format': entry.format,
          'description': entry.description,
          'new_description': entry.newDescription,
        },
    ],
    if (dash != null) 'dash': dash!.toJson(),
  };
}

/// Entry of the play-url `support_formats` array.
///
/// Declared here rather than in its own file because the source app never read
/// it; it is only used to label the quality picker.
class BiliPlaySupportFormat {
  const BiliPlaySupportFormat({
    required this.quality,
    required this.format,
    required this.description,
    required this.newDescription,
  });

  final int quality;
  final String format;
  final String description;
  final String newDescription;

  String get label => newDescription.isNotEmpty ? newDescription : description;

  factory BiliPlaySupportFormat.fromJson(Map<String, dynamic> json) =>
      BiliPlaySupportFormat(
        quality: _asInt(json['quality']),
        format: '${json['format'] ?? ''}',
        description: '${json['description'] ?? ''}',
        newDescription: '${json['new_description'] ?? ''}',
      );
}

int _asInt(Object? value) => value is int ? value : int.tryParse('$value') ?? 0;

/// Reads a JSON array of strings, or a comma-separated string.
///
/// The real `x/player/playurl` response (which is what the source app parsed)
/// carries `accept_format` as a **string** — `"flv720,flv,mp4"` — so casting it
/// to `List` would crash on every live response. `accept_quality` is normally a
/// JSON array, but both shapes are accepted so neither field can break mapping.
List<String> _stringList(Object? value) {
  if (value is List) return <String>[for (final entry in value) '$entry'];
  if (value is String) {
    return <String>[
      for (final part in value.split(','))
        if (part.trim().isNotEmpty) part.trim(),
    ];
  }
  return const <String>[];
}

List<int> _intList(Object? value) {
  if (value is List) return <int>[for (final entry in value) _asInt(entry)];
  if (value is String) {
    return <int>[
      for (final part in value.split(','))
        if (part.trim().isNotEmpty) _asInt(part.trim()),
    ];
  }
  return const <int>[];
}
