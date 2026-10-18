/// `lib/utils/date_util.dart`, with `intl` replaced by hand-written padding.
///
/// The source's `DateFormat("mm:ss")` printed the **minute of the hour** and
/// the second, not a duration, and the port reproduces that reading rather
/// than "fixing" the display of any timestamp whose minute is not the elapsed
/// minute.
class EyepetizerFlutterDateUtil {
  const EyepetizerFlutterDateUtil._();

  /// `DateUtil.format` — `DateFormat("mm:ss")` of the epoch millisecond
  /// [time] in the local zone.
  static String format(int time) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    return '${_pad(dateTime.minute)}:${_pad(dateTime.second)}';
  }

  /// `DateUtil.getDuration` — `[h:]mm:ss`, hours omitted when zero, minutes
  /// and seconds zero-padded, hours never padded.
  static String getDuration(int seconds) {
    final hour = seconds ~/ 3600;
    final min = (seconds - hour * 3600) ~/ 60;
    final second = seconds - hour * 3600 - min * 60;
    final buffer = StringBuffer();
    if (hour > 0) {
      buffer.write('$hour:');
    }
    buffer.write(_pad(min));
    buffer.write(':');
    buffer.write(_pad(second));
    return buffer.toString();
  }

  /// `yyyy/MM/dd` for the profile form's birthday field.
  ///
  /// Faithful to `formatDate(DateTime.fromMicrosecondsSinceEpoch(birthday *
  /// 1000), [yyyy, '/', mm, '/', dd])`: the source treated a value that is
  /// almost certainly a **seconds** timestamp as microseconds, so the printed
  /// date is about 1970. Preserved deliberately — changing it would silently
  /// disagree with what the app has already written into profiles.
  static String formatBirthdaySeconds(int? birthdaySeconds) {
    if (birthdaySeconds == null) return '';
    final dateTime = DateTime.fromMicrosecondsSinceEpoch(
      birthdaySeconds * 1000,
    );
    return '${dateTime.year.toString().padLeft(4, '0')}/'
        '${_pad(dateTime.month)}/${_pad(dateTime.day)}';
  }

  static String _pad(int value) => value.toString().padLeft(2, '0');
}
