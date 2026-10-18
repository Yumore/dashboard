import 'package:dashboard/features/movie/fluttercinematic/cinematic_constants.dart';

/// Replaces the source `intl` usage (`sourceFormat = yyyy-MM-dd`,
/// `dateFormat = DateFormat.yMMMMd("en_US")`). `intl` is not a host
/// dependency, so the two conversions are hand-written and keep the same
/// fallback of an empty string on an unparseable value.
class CinematicDateFormat {
  const CinematicDateFormat._();

  static final RegExp _isoDate = RegExp(r'^(\d{4})-(\d{2})-(\d{2})');

  /// `"1999-10-15"` -> `"October 15, 1999"`.
  static String long(String? source) {
    final parts = _parse(source);
    if (parts == null) return '';
    return '${CinematicConstants.monthNames[parts.month - 1]} '
        '${parts.day}, ${parts.year}';
  }

  /// Source `formatDate`; kept for the search subtitle and episode air date.
  static String format(String? date) => long(date);

  static _YearMonthDay? _parse(String? source) {
    if (source == null) return null;
    final match = _isoDate.firstMatch(source);
    if (match == null) return null;
    final year = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final day = int.tryParse(match.group(3)!);
    if (year == null || month == null || day == null) return null;
    if (month < 1 || month > 12) return null;
    return _YearMonthDay(year, month, day);
  }

  /// `"2019-03-05"` -> `2019`; null for an absent/invalid year, mirroring
  /// `MediaItem.getReleaseYear` / `TvSeason.getReleaseYear`.
  static int? year(String? source) {
    if (source == null || source.length < 4) return null;
    return int.tryParse(source.substring(0, 4));
  }
}

class _YearMonthDay {
  const _YearMonthDay(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;
}
