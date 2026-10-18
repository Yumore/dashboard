import 'package:dashboard/features/movie/inkino/inkino_clock.dart';
import 'package:dashboard/features/movie/inkino/inkino_dates.dart';
import 'package:dashboard/features/movie/inkino/inkino_schedule.dart';
import 'package:dashboard/features/movie/inkino/inkino_show.dart';

/// The source's showtime filtering + grouping rules, extracted from Redux so
/// they are pure and injectable-clock testable.
class InKinoShowGrouper {
  const InKinoShowGrouper._();

  /// Port of `ShowMiddleware._fetchShows`:
  ///
  /// > Return only show times that haven't started yet.
  ///
  /// The filter is date-scoped exactly like the source: it applies to *today*
  /// only. Once another day is selected, every showtime on that day is listed
  /// (a 10:30 show on a future date is still upcoming).
  static List<InKinoShow> visibleShows(
    InKinoSchedule? schedule,
    DateTime selectedDate, {
    DateTime Function()? clock,
  }) {
    if (schedule == null) return const [];
    final now = (clock ?? InKinoClock.currentTime)();
    if (!InKinoDates.isSameDay(selectedDate, now)) {
      return List<InKinoShow>.unmodifiable(schedule.shows);
    }
    return List<InKinoShow>.unmodifiable(
      schedule.shows.where((show) => show.start.isAfter(now)),
    );
  }

  /// Groups the visible shows by theatre name, each theatre's shows ordered by
  /// start time. Ids such as `"sali 6"` (auditorium) stay on the show itself.
  static Map<String, List<InKinoShow>> byTheater(
    InKinoSchedule? schedule,
    DateTime selectedDate, {
    DateTime Function()? clock,
  }) {
    final visible = visibleShows(schedule, selectedDate, clock: clock);
    final grouped = <String, List<InKinoShow>>{};
    for (final show in visible) {
      final theater = show.theaterName.isEmpty ? '未指定影院' : show.theaterName;
      grouped.putIfAbsent(theater, () => <InKinoShow>[]).add(show);
    }
    for (final shows in grouped.values) {
      shows.sort(_byStartTime);
    }
    final sortedKeys = grouped.keys.toList()..sort();
    return {
      for (final key in sortedKeys)
        key: List<InKinoShow>.unmodifiable(grouped[key]!),
    };
  }

  /// The auditorium buckets of one theatre, ordered by name for stable output.
  static Map<String, List<InKinoShow>> byAuditorium(
    Iterable<InKinoShow> shows,
  ) {
    final grouped = <String, List<InKinoShow>>{};
    for (final show in shows) {
      final auditorium = show.auditorium.isEmpty ? '未指定影厅' : show.auditorium;
      grouped.putIfAbsent(auditorium, () => <InKinoShow>[]).add(show);
    }
    for (final bucket in grouped.values) {
      bucket.sort(_byStartTime);
    }
    final sortedKeys = grouped.keys.toList()..sort();
    return {
      for (final key in sortedKeys)
        key: List<InKinoShow>.unmodifiable(grouped[key]!),
    };
  }

  /// Groups by the *calendar day* each show starts on. Finnkino's `Schedule`
  /// response is already date-scoped, but a "today + tomorrow" window or a
  /// post-midnight show can span days, and this keeps that unambiguous.
  static Map<String, List<InKinoShow>> byDate(Iterable<InKinoShow> shows) {
    final grouped = <String, List<InKinoShow>>{};
    for (final show in shows) {
      grouped
          .putIfAbsent(InKinoDates.dateKey(show.start), () => <InKinoShow>[])
          .add(show);
    }
    for (final bucket in grouped.values) {
      bucket.sort(_byStartTime);
    }
    final sortedKeys = grouped.keys.toList()..sort();
    return {
      for (final key in sortedKeys)
        key: List<InKinoShow>.unmodifiable(grouped[key]!),
    };
  }

  static int _byStartTime(InKinoShow a, InKinoShow b) =>
      a.start.compareTo(b.start);
}
