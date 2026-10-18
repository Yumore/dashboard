/// One progressive stream entry of the play-url `durl` array.
///
/// Ports `Durl` from the source app's `entities/video_play_info_entity.dart`.
/// Both [length] and [size] are only populated by the `fnval: 1` (FLV/MP4)
/// response; DASH responses leave `durl` empty.
class BiliDurlSegment {
  const BiliDurlSegment({
    required this.order,
    required this.length,
    required this.size,
    required this.url,
  });

  /// 1-based segment index (`order`); `> 1` means the stream is split and would
  /// need segment concatenation, which the source app never implemented.
  final int order;

  /// Duration in **milliseconds**.
  final int length;

  /// Size in **bytes**.
  final int size;

  final String url;

  bool get isFirstSegment => order <= 1;

  factory BiliDurlSegment.fromJson(Map<String, dynamic> json) =>
      BiliDurlSegment(
        order: _asInt(json['order']),
        length: _asInt(json['length']),
        size: _asInt(json['size']),
        url: '${json['url'] ?? ''}',
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'order': order,
    'length': length,
    'size': size,
    'url': url,
  };
}

int _asInt(Object? value) => value is int ? value : int.tryParse('$value') ?? 0;
