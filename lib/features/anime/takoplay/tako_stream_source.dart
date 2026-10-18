import 'dart:convert';

/// A playable stream entry from the decrypted gogoplay payload, e.g.
/// `{"file":"https://.../index.m3u8","label":"1080p","type":"hls"}`.
class TakoStreamSource {
  const TakoStreamSource({
    required this.label,
    required this.url,
    this.type = 'unknown',
  });

  /// Hand-written parser for one `source` entry of the decrypted payload.
  factory TakoStreamSource.fromJson(Map<String, dynamic> json) {
    final file = json['file']?.toString() ?? '';
    if (file.isEmpty) {
      throw const FormatException('stream source has no file url');
    }
    return TakoStreamSource(
      label: json['label']?.toString() ?? '',
      url: Uri.parse(file),
      type: json['type']?.toString() ?? 'unknown',
    );
  }

  final String label;
  final Uri url;

  /// `hls` for m3u8 master playlists, `mp4` for progressive files.
  final String type;

  bool get isHls => type == 'hls' || url.path.endsWith('.m3u8');

  /// Decodes a full decrypted payload (`{"source":[...]}`) into sources.
  static List<TakoStreamSource> listFromJson(String payload) {
    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('stream payload is not a json object');
    }
    final source = decoded['source'];
    if (source is! List) {
      throw const FormatException('stream payload has no source list');
    }
    return source
        .whereType<Map<String, dynamic>>()
        .map(TakoStreamSource.fromJson)
        .toList();
  }

  @override
  String toString() => 'TakoStreamSource($label, $url)';
}
