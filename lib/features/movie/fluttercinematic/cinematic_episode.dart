import 'package:dashboard/features/movie/fluttercinematic/cinematic_date_format.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_image_url.dart';

/// Port of the source `lib/model/episode.dart` (`tv/{id}/season/{n}` rows):
/// `name`, `overview`, `still_path`, `vote_average`, `episode_number`,
/// `air_date`.
class CinematicEpisode {
  CinematicEpisode({
    required this.title,
    required this.overview,
    required this.stillPath,
    required this.voteAverage,
    required this.episodeNumber,
    required this.airDate,
  });

  factory CinematicEpisode.fromJson(Map jsonMap) => CinematicEpisode(
    title: '${jsonMap['name'] ?? ''}',
    overview: '${jsonMap['overview'] ?? ''}',
    stillPath: '${jsonMap['still_path'] ?? ''}',
    voteAverage: _asDouble(jsonMap['vote_average']),
    episodeNumber: _asInt(jsonMap['episode_number']),
    airDate: '${jsonMap['air_date'] ?? ''}',
  );

  final String title;
  final String overview;
  final String stillPath;
  final double voteAverage;
  final int episodeNumber;
  final String airDate;

  String get stillUrl => CinematicImageUrl.medium(stillPath);

  /// Formatted air date, matching the source `EpisodeCard` subtitle.
  String get formattedAirDate => CinematicDateFormat.format(airDate);

  static int _asInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse('${value ?? ''}') ?? 0;
  }

  static double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse('${value ?? ''}') ?? 0;
  }
}
