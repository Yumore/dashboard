/// Injected time source, mirroring inKino's `Clock` utility.
///
/// Showtime logic is date-scoped ("only show today's showtimes that have not
/// started yet"), so tests swap [currentTime] instead of depending on the real
/// wall clock.
class InKinoClock {
  const InKinoClock._();

  /// Returns the current local time. Replace in tests
  /// (`InKinoClock.currentTime = () => DateTime(2018, 2, 21, 11);`).
  static DateTime Function() currentTime = _systemNow;

  static DateTime _systemNow() => DateTime.now();

  /// Restores the real clock; call from `tearDown` in tests.
  static void reset() => currentTime = _systemNow;
}
