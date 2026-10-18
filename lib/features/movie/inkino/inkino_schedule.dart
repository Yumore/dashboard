import 'package:dashboard/features/movie/inkino/inkino_dates.dart';
import 'package:dashboard/features/movie/inkino/inkino_show.dart';

/// One `(area, date)` slice of Finnkino's schedule — the cache unit.
///
/// inKino keyed its store with `DateTheaterPair`; this is the same idea without
/// the Redux store, so an already-fetched day is re-displayed instead of
/// re-requested.
class InKinoSchedule {
  const InKinoSchedule({
    required this.areaId,
    required this.date,
    required this.shows,
  });

  final String areaId;

  /// Local midnight of the day this schedule was requested for.
  final DateTime date;
  final List<InKinoShow> shows;

  bool get isEmpty => shows.isEmpty;

  bool get isNotEmpty => shows.isNotEmpty;

  String get key => '$areaId@${InKinoDates.dateKey(date)}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InKinoSchedule &&
          runtimeType == other.runtimeType &&
          areaId == other.areaId &&
          date == other.date &&
          _sameShows(shows, other.shows);

  @override
  int get hashCode => Object.hash(areaId, date, shows.length);

  static bool _sameShows(List<InKinoShow> a, List<InKinoShow> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  @override
  String toString() => 'InKinoSchedule($areaId, $date, ${shows.length} shows)';
}
