import 'package:dashboard/features/movie/movieapp/movieapp_image.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_json.dart';

/// One entry of `credits.cast`.
class MovieAppCastMember {
  const MovieAppCastMember({
    required this.id,
    required this.name,
    this.character = '',
    this.profilePath,
    this.order = 0,
  });

  final int id;
  final String name;
  final String character;
  final String? profilePath;
  final int order;

  factory MovieAppCastMember.fromJson(Map<String, dynamic> json) =>
      MovieAppCastMember(
        id: MovieAppJson.asInt(json['id']),
        name: MovieAppJson.asString(json['name']),
        character: MovieAppJson.asString(json['character']),
        profilePath: MovieAppJson.asNullableString(json['profile_path']),
        order: MovieAppJson.asInt(json['order']),
      );

  String? get profileUrl =>
      MovieAppImage.url(profilePath, size: MovieAppImage.thumbnail);
}
