import 'package:dashboard/features/movie/bilivideo_down/bili_ugc_arc.dart';

/// One episode of a multi-part (`ugc_season`) bilibili upload.
///
/// Ports `Episode` from the source app's `video_sec_entity.dart`; the source's
/// `checked` selection flag stayed in the UI layer and is not modelled here.
class BiliUgcEpisode {
  const BiliUgcEpisode({
    required this.aid,
    required this.cid,
    required this.title,
    required this.bvid,
    required this.arc,
  });

  final int aid;
  final int cid;
  final String title;
  final String bvid;
  final BiliUgcArc arc;

  factory BiliUgcEpisode.fromJson(Map<String, dynamic> json) => BiliUgcEpisode(
    aid: _asInt(json['aid']),
    cid: _asInt(json['cid']),
    title: '${json['title'] ?? ''}',
    bvid: '${json['bvid'] ?? ''}',
    arc: BiliUgcArc.fromJson(
      json['arc'] is Map
          ? Map<String, dynamic>.from(json['arc'] as Map)
          : const <String, dynamic>{},
    ),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'aid': aid,
    'cid': cid,
    'title': title,
    'bvid': bvid,
    'arc': arc.toJson(),
  };
}

int _asInt(Object? value) => value is int ? value : int.tryParse('$value') ?? 0;
