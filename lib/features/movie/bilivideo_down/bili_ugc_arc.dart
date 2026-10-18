/// Per-episode metadata inside a `ugc_season` section.
///
/// Ports `Arc` from the source app's `video_sec_entity.dart`.
class BiliUgcArc {
  const BiliUgcArc({
    required this.pic,
    required this.pubdate,
    required this.ctime,
  });

  final String pic;
  final int pubdate;
  final int ctime;

  factory BiliUgcArc.fromJson(Map<String, dynamic> json) => BiliUgcArc(
    pic: '${json['pic'] ?? ''}',
    pubdate: _asInt(json['pubdate']),
    ctime: _asInt(json['ctime']),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'pic': pic,
    'pubdate': pubdate,
    'ctime': ctime,
  };
}

int _asInt(Object? value) => value is int ? value : int.tryParse('$value') ?? 0;
