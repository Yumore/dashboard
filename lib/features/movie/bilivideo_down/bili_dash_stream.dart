/// One track of the DASH manifest (`dash.video[]` / `dash.audio[]`).
///
/// The source app never read `dash` — its play-url call omitted `fnval`, so
/// bilibili answered with a progressive `durl` list. The DASH model exists here
/// because the module supports the `fnval`-enabled response shape as well.
class BiliDashStream {
  const BiliDashStream({
    required this.id,
    required this.baseUrl,
    required this.backupUrl,
    required this.bandwidth,
    required this.mimeType,
    required this.codecs,
    required this.width,
    required this.height,
    required this.frameRate,
    required this.sar,
    required this.startWithSap,
  });

  /// Quality code (`qn`) this track carries.
  final int id;
  final String baseUrl;
  final List<String> backupUrl;
  final int bandwidth;
  final String mimeType;
  final String codecs;
  final int width;
  final int height;
  final String frameRate;
  final String sar;
  final int startWithSap;

  bool get isPlayable => baseUrl.isNotEmpty;

  /// `1920x1080`-style label, empty for audio tracks.
  String get resolutionLabel =>
      (width > 0 && height > 0) ? '${width}x$height' : '';

  factory BiliDashStream.fromJson(Map<String, dynamic> json) => BiliDashStream(
    id: _asInt(json['id']),
    baseUrl: '${json['baseUrl'] ?? json['base_url'] ?? ''}',
    backupUrl: <String>[
      for (final entry
          in (json['backupUrl'] ?? json['backup_url'] ?? const <Object?>[])
              as List)
        if (entry != null) '$entry',
    ],
    bandwidth: _asInt(json['bandwidth']),
    mimeType: '${json['mimeType'] ?? json['mime_type'] ?? ''}',
    codecs: '${json['codecs'] ?? ''}',
    width: _asInt(json['width']),
    height: _asInt(json['height']),
    frameRate: '${json['frameRate'] ?? json['frame_rate'] ?? ''}',
    sar: '${json['sar'] ?? ''}',
    startWithSap: _asInt(json['startWithSap'] ?? json['start_with_sap']),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'baseUrl': baseUrl,
    'backupUrl': backupUrl,
    'bandwidth': bandwidth,
    'mimeType': mimeType,
    'codecs': codecs,
    'width': width,
    'height': height,
    'frameRate': frameRate,
    'sar': sar,
    'startWithSap': startWithSap,
  };
}

int _asInt(Object? value) => value is int ? value : int.tryParse('$value') ?? 0;
