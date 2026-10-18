import 'package:dashboard/features/movie/bilivideo_down/bili_ugc_episode.dart';

/// A chapter of a bilibili `ugc_season` collection.
///
/// The source app only ever read `sections[0].episodes`; [episodes] is exposed
/// whole here so callers decide.
class BiliUgcSection {
  const BiliUgcSection({required this.seasonId, required this.episodes});

  final int seasonId;
  final List<BiliUgcEpisode> episodes;

  factory BiliUgcSection.fromJson(Map<String, dynamic> json) => BiliUgcSection(
    seasonId: _asInt(json['season_id']),
    episodes: <BiliUgcEpisode>[
      for (final entry in (json['episodes'] as List? ?? const <Object?>[]))
        if (entry is Map)
          BiliUgcEpisode.fromJson(Map<String, dynamic>.from(entry)),
    ],
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'season_id': seasonId,
    'episodes': <dynamic>[for (final episode in episodes) episode.toJson()],
  };
}

int _asInt(Object? value) => value is int ? value : int.tryParse('$value') ?? 0;
