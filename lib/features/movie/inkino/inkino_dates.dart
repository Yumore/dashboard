/// Date helpers for the showtime flow.
///
/// inKino used `intl`'s `DateFormat('dd.MM.yyyy')` for the API's `dt` parameter.
/// This host does not depend on `intl`, so the handful of formats the flow
/// needs are hand-written, local-time based (never `toIso8601String`, which
/// would shift the day across timezones / DST).
class InKinoDates {
  const InKinoDates._();

  static const List<String> weekdaysZh = [
    '周一',
    '周二',
    '周三',
    '周四',
    '周五',
    '周六',
    '周日',
  ];

  /// Midnight on the same local calendar day.
  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  /// Finnkino's schedule `/xml/Schedule?dt=` format, e.g. `21.02.2018`.
  static String apiDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}.'
      '${value.month.toString().padLeft(2, '0')}.'
      '${value.year}';

  /// `2018-02-21`, usable as a stable map key.
  static String dateKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  /// True when [candidate] falls on the same local day as [reference].
  ///
  /// Compares calendar fields on purpose: `Difference.inDays` is wrong across
  /// DST changes, where two "consecutive" midnights are 23 or 25 hours apart.
  static bool isSameDay(DateTime candidate, DateTime reference) =>
      candidate.year == reference.year &&
      candidate.month == reference.month &&
      candidate.day == reference.day;

  /// The [length]-day window starting at [from] (source default: 7 days).
  static List<DateTime> upcomingDays(DateTime from, {int length = 7}) =>
      List.generate(
        length,
        (index) => dateOnly(from).add(Duration(days: index)),
      );

  /// `2018-02-21` -> `21.02`, the date-chip label.
  static String chipLabel(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}.'
      '${value.month.toString().padLeft(2, '0')}';

  /// `(2018-02-21, 2018-02-21)` -> `今天`; anything else -> `周三`.
  static String dayLabel(DateTime value, DateTime today) =>
      isSameDay(value, today) ? '今天' : weekdaysZh[value.weekday - 1];
}
