/// Dart port of the two `flustars` date helpers the source used.
///
/// The source called `DateUtil.formatDateMsByMS` for the duration badge
/// (`rank_widget_item.dart:88`) and `DateUtil.formatDateMsByYMDHM` for the
/// detail screen's publish stamp (`video_detail_page.dart:138`). Host has no
/// `flustars`, so both are hand-written here.
class EyepetizerDuration {
  const EyepetizerDuration._();

  /// `formatDateMsByMS`: milliseconds to `mm:ss` (hours folded into minutes).
  static String mmss(int milliseconds) {
    if (milliseconds <= 0) return '00:00';
    final totalSeconds = milliseconds ~/ 1000;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// `formatDateMsByYMDHM`: milliseconds to local `yyyy/MM/dd HH:mm`.
  static String ymdHm(int milliseconds) {
    if (milliseconds <= 0) return '';
    final time = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    String two(int value) => value.toString().padLeft(2, '0');
    return '${time.year}/${two(time.month)}/${two(time.day)} '
        '${two(time.hour)}:${two(time.minute)}';
  }
}
