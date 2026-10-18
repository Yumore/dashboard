/// The source `lib/util/utils.dart` genre table, copied id-for-id (including
/// the odd `10763: ''` entry) so labels and ordering match the original.
class CinematicGenres {
  const CinematicGenres._();

  static const Map<int, String> genreMap = <int, String>{
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    10762: 'Kids',
    10759: 'Action & Adventure',
    14: 'Fantasy',
    36: 'History',
    27: 'Horror',
    10402: 'Music',
    9648: 'Mystery',
    10749: 'Romance',
    878: 'Science Fiction',
    10770: 'TV Movie',
    53: 'Thriller',
    10752: 'War',
    37: 'Western',
    10763: '',
    10764: 'Reality',
    10765: 'Sci-Fi & Fantasy',
    10766: 'Soap',
    10767: 'Talk',
    10768: 'War & Politics',
  };

  static List<String> forIds(List<int> genreIds) =>
      genreIds.map((id) => genreMap[id]).whereType<String>().toList();

  /// Source `getGenreString`: joins known labels with `", "`.
  static String label(List<int> genreIds) {
    final buffer = StringBuffer();
    buffer.writeAll(forIds(genreIds), ', ');
    return buffer.toString();
  }

  /// Source `concatListToString(data, mapKey)`; used for `created_by`,
  /// `networks` and a person's `known_for`.
  static String joinKey(List<dynamic> data, String mapKey) {
    final buffer = StringBuffer();
    buffer.writeAll(data.map<String>((row) => '${row[mapKey]}').toList(), ', ');
    return buffer.toString();
  }
}
