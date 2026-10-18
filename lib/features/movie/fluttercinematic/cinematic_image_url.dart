import 'package:dashboard/features/movie/fluttercinematic/cinematic_constants.dart';

/// Builds TMDb image URLs exactly like the source `lib/util/utils.dart`:
/// `getMediumPictureUrl` -> `w300`, `getLargePictureUrl` -> `w500`.
///
/// The source concatenated blindly, so a null path produced a dangling base
/// URL. This port returns an empty string in that case and labels the size.
class CinematicImageUrl {
  const CinematicImageUrl._();

  static String medium(String? path) =>
      _build(CinematicConstants.posterSize, path);

  static String large(String? path) =>
      _build(CinematicConstants.backdropSize, path);

  static String _build(String size, String? path) {
    final value = path ?? '';
    if (value.isEmpty) return '';
    return '${CinematicConstants.imageBaseUrl}$size$value';
  }
}
