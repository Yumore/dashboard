/// Builds `https://image.tmdb.org/t/p/<size><path>` URLs.
///
/// The source app only ever used the `original` size; the other sizes are the
/// real TMDb sizes used for list thumbnails.
class MovieAppImage {
  const MovieAppImage._();

  static const String baseUrl = 'https://image.tmdb.org/t/p/';
  static const String original = 'original';
  static const String poster = 'w500';
  static const String thumbnail = 'w185';
  static const String backdrop = 'w780';

  /// Returns null when TMDb omits the path (a real possibility for
  /// `poster_path` / `backdrop_path` / `profile_path`).
  static String? url(String? path, {String size = original}) {
    final value = path?.trim() ?? '';
    if (value.isEmpty) return null;
    return '$baseUrl$size$value';
  }
}
