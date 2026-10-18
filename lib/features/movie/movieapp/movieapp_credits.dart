import 'package:dashboard/features/movie/movieapp/movieapp_cast_member.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_json.dart';

/// `movie/{id}/credits` | `tv/{id}/credits` payload.
class MovieAppCredits {
  const MovieAppCredits({this.cast = const []});

  final List<MovieAppCastMember> cast;

  bool get isEmpty => cast.isEmpty;

  factory MovieAppCredits.fromJson(Map<String, dynamic> json) =>
      MovieAppCredits(
        cast: MovieAppJson.asMapList(
          json['cast'],
        ).map(MovieAppCastMember.fromJson).toList(),
      );
}
