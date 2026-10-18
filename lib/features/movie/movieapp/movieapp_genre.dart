import 'package:dashboard/features/movie/movieapp/movieapp_json.dart';

/// A genre as returned inside `movie/{id}` / `tv/{id}` (`genres: [{id, name}]`).
class MovieAppGenre {
  const MovieAppGenre({required this.id, required this.name});

  final int id;
  final String name;

  factory MovieAppGenre.fromJson(Map<String, dynamic> json) => MovieAppGenre(
    id: MovieAppJson.asInt(json['id']),
    name: MovieAppJson.asString(json['name']),
  );
}
