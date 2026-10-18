import 'package:dashboard/features/movie/fluttercinematic/cinematic_image_url.dart';

/// Port of the source `lib/model/cast.dart`: `character`, `name`,
/// `profile_path`, `id`.
class CinematicActor {
  CinematicActor({
    required this.character,
    required this.name,
    required this.profilePicture,
    required this.id,
  });

  factory CinematicActor.fromJson(Map jsonMap) => CinematicActor(
    character: '${jsonMap['character'] ?? ''}',
    name: '${jsonMap['name'] ?? ''}',
    profilePicture: '${jsonMap['profile_path'] ?? ''}',
    id: _asInt(jsonMap['id']),
  );

  final String character;
  final String name;
  final String profilePicture;
  final int id;

  String get profilePictureUrl => CinematicImageUrl.medium(profilePicture);

  static int _asInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse('${value ?? ''}') ?? 0;
  }
}
