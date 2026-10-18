import 'package:dashboard/features/movie/bilivideo_down/bili_ugc_episode.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_ugc_section.dart';

/// The `ugc_season` block of `x/web-interface/view`.
///
/// Ports `UgcSeason` from the source app's `video_sec_entity.dart`.
class BiliUgcSeason {
  const BiliUgcSeason({
    required this.id,
    required this.title,
    required this.cover,
    required this.mid,
    required this.intro,
    required this.signState,
    required this.attribute,
    required this.sections,
    required this.epCount,
  });

  final int id;
  final String title;
  final String cover;
  final int mid;
  final String intro;
  final int signState;
  final int attribute;
  final List<BiliUgcSection> sections;
  final int epCount;

  /// Every episode of every section, in the collection's own order.
  ///
  /// The source app only read `sections[0].episodes`; flattening all sections
  /// keeps the same first-section ordering while not silently dropping
  /// chapters that a collection happens to carry.
  List<BiliUgcEpisode> get episodes => <BiliUgcEpisode>[
    for (final section in sections) ...section.episodes,
  ];

  factory BiliUgcSeason.fromJson(Map<String, dynamic> json) => BiliUgcSeason(
    id: _asInt(json['id']),
    title: '${json['title'] ?? ''}',
    cover: '${json['cover'] ?? ''}',
    mid: _asInt(json['mid']),
    intro: '${json['intro'] ?? ''}',
    signState: _asInt(json['sign_state']),
    attribute: _asInt(json['attribute']),
    sections: <BiliUgcSection>[
      for (final entry in (json['sections'] as List? ?? const <Object?>[]))
        if (entry is Map)
          BiliUgcSection.fromJson(Map<String, dynamic>.from(entry)),
    ],
    epCount: _asInt(json['ep_count']),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'cover': cover,
    'mid': mid,
    'intro': intro,
    'sign_state': signState,
    'attribute': attribute,
    'sections': <dynamic>[for (final section in sections) section.toJson()],
    'ep_count': epCount,
  };
}

int _asInt(Object? value) => value is int ? value : int.tryParse('$value') ?? 0;
